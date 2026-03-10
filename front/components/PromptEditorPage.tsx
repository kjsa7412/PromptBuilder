'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import { useRouter } from 'next/navigation';

// ─── Types ────────────────────────────────────────────────────────────────────
interface TextBlock {
  id: string;
  type: 'text';
  content: string; // raw markdown — user types markdown directly
}

interface PromptBlock {
  id: string;
  type: 'prompt';
  postPromptId?: string; // for edit mode: existing server ID
  title: string;
  templateBody: string;
  status: 'draft' | 'in_progress' | 'complete';
  variableDescriptions: Record<string, string>;
}

type Block = TextBlock | PromptBlock;
type EditorMode = 'simple' | 'advanced';

interface Props {
  promptId?: string;
  token: string;
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
let _id = 0;
const uid = () => `b${++_id}-${Date.now()}`;

const PLACEHOLDER_RE = /\{\{\s*([a-zA-Z0-9_가-힣]+)\s*\}\}/g;
function extractVarKeys(template: string): string[] {
  const keys = new Set<string>();
  let m;
  const re = new RegExp(PLACEHOLDER_RE.source, 'g');
  while ((m = re.exec(template)) !== null) keys.add(m[1]);
  return Array.from(keys);
}

// ─── Constants ────────────────────────────────────────────────────────────────
const STATUS_LABELS = { draft: '초안', in_progress: '작성중', complete: '완성' } as const;
const STATUS_COLORS = {
  draft: 'bg-gray-100 dark:bg-white/10 text-gray-500 dark:text-white/50',
  in_progress: 'bg-yellow-100 dark:bg-yellow-500/20 text-yellow-600 dark:text-yellow-300',
  complete: 'bg-green-100 dark:bg-green-500/20 text-green-600 dark:text-green-300',
} as const;

// Slash commands: selecting one INSERTS the markdown prefix into the textarea
const SLASH_COMMANDS = [
  { name: 'h1',        label: '제목 1',     icon: 'H1',  insert: '# ',      desc: '큰 제목' },
  { name: 'h2',        label: '제목 2',     icon: 'H2',  insert: '## ',     desc: '중간 제목' },
  { name: 'h3',        label: '제목 3',     icon: 'H3',  insert: '### ',    desc: '작은 제목' },
  { name: 'list',      label: '목록',       icon: '•',   insert: '- ',      desc: '불릿 리스트' },
  { name: 'checklist', label: '체크리스트', icon: '☑',   insert: '- [ ] ', desc: '체크박스 목록' },
  { name: 'code',      label: '코드 블록',  icon: '</>',  insert: '```\n',   desc: '코드 블록' },
  { name: 'quote',     label: '인용문',     icon: '"',   insert: '> ',      desc: '인용 블록' },
  { name: 'divider',   label: '구분선',     icon: '—',   insert: '---\n',   desc: '수평선' },
] as const;

type SlashCmd = typeof SLASH_COMMANDS[number];

interface SlashState {
  blockId: string;
  query: string;
  slashPos: number; // index in content string where '/' is
  selectedIdx: number;
}

// ─── SlashCommandMenu ─────────────────────────────────────────────────────────
function SlashCommandMenu({
  state,
  onSelect,
}: {
  state: SlashState;
  onSelect: (cmd: SlashCmd) => void;
}) {
  const filtered = SLASH_COMMANDS.filter(
    (c) => c.name.startsWith(state.query.toLowerCase()) || c.label.includes(state.query)
  );
  if (filtered.length === 0) return null;

  return (
    <div className="absolute left-0 z-50 mt-1 w-64 rounded-xl bg-white dark:bg-[#1a1a2e] border border-gray-200 dark:border-white/10 shadow-2xl shadow-black/20 overflow-hidden">
      <div className="px-3 py-1.5 text-[10px] font-semibold text-gray-400 dark:text-white/30 uppercase tracking-wider border-b border-gray-100 dark:border-white/5">
        슬래시 명령어
      </div>
      {filtered.map((cmd, i) => {
        const selected = i === (state.selectedIdx % filtered.length);
        return (
          <button
            key={cmd.name}
            onMouseDown={(e) => { e.preventDefault(); onSelect(cmd); }}
            className={`w-full flex items-center gap-3 px-3 py-2 text-left transition-colors ${
              selected
                ? 'bg-violet-500/10 text-violet-600 dark:text-violet-300'
                : 'text-gray-700 dark:text-white/70 hover:bg-gray-50 dark:hover:bg-white/5'
            }`}
          >
            <span className="w-8 h-8 flex items-center justify-center rounded-lg bg-gray-100 dark:bg-white/5 text-xs font-bold text-gray-500 dark:text-white/40 flex-shrink-0">
              {cmd.icon}
            </span>
            <span>
              <span className="block text-sm font-medium">{cmd.label}</span>
              <span className="block text-xs text-gray-400 dark:text-white/30">{cmd.desc}</span>
            </span>
          </button>
        );
      })}
      <div className="px-3 py-1.5 text-[10px] text-gray-400 dark:text-white/20 border-t border-gray-100 dark:border-white/5">
        ↑↓ 이동 · Enter 선택 · Esc 닫기
      </div>
    </div>
  );
}

// ─── PromptBlockModal ─────────────────────────────────────────────────────────
function PromptBlockModal({
  block,
  onUpdate,
  onDelete,
  onClose,
}: {
  block: PromptBlock;
  onUpdate: (updates: Partial<PromptBlock>) => void;
  onDelete: () => void;
  onClose: () => void;
}) {
  const varKeys = extractVarKeys(block.templateBody);

  useEffect(() => {
    const handler = (e: KeyboardEvent) => { if (e.key === 'Escape') onClose(); };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [onClose]);

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm"
      onClick={onClose}
    >
      <div
        className="w-full max-w-lg rounded-2xl bg-white dark:bg-[#1a1a2e] border border-gray-200 dark:border-white/10 shadow-2xl p-6 space-y-4"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between">
          <h2 className="text-sm font-semibold text-gray-500 dark:text-white/60 uppercase tracking-wider">
            프롬프트 편집
          </h2>
          <button
            onClick={onClose}
            className="w-7 h-7 flex items-center justify-center rounded-full bg-gray-100 dark:bg-white/10 text-gray-500 dark:text-white/50 hover:bg-gray-200 dark:hover:bg-white/20 transition-all text-sm"
          >
            ×
          </button>
        </div>

        <div>
          <label className="block text-xs font-medium text-gray-500 dark:text-white/50 mb-1">제목</label>
          <input
            type="text"
            value={block.title}
            onChange={(e) => onUpdate({ title: e.target.value })}
            className="w-full bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-lg px-3 py-2 text-sm text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-500/50 transition-all"
          />
        </div>

        <div>
          <label className="block text-xs font-medium text-gray-500 dark:text-white/50 mb-1">
            템플릿 본문 <span className="text-gray-400 dark:text-white/30">{'{{변수명}}'}</span>
          </label>
          <textarea
            value={block.templateBody}
            onChange={(e) => onUpdate({ templateBody: e.target.value })}
            rows={8}
            placeholder={'{{role}}로서 {{topic}}에 대해 설명해주세요.'}
            className="w-full bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-lg px-3 py-2 text-xs font-mono text-gray-900 dark:text-white placeholder-gray-300 dark:placeholder-white/20 focus:outline-none focus:ring-2 focus:ring-violet-500/50 transition-all resize-y"
          />
        </div>

        {varKeys.length > 0 && (
          <div className="space-y-2">
            <label className="block text-xs font-medium text-gray-500 dark:text-white/50">변수 설명</label>
            {varKeys.map((k) => (
              <div key={k}>
                <code className="block text-xs text-violet-500 dark:text-violet-400 bg-violet-500/10 px-1.5 py-0.5 rounded font-mono mb-1">
                  {'{{' + k + '}}'}
                </code>
                <input
                  type="text"
                  value={block.variableDescriptions[k] || ''}
                  onChange={(e) =>
                    onUpdate({
                      variableDescriptions: { ...block.variableDescriptions, [k]: e.target.value },
                    })
                  }
                  placeholder="변수 설명..."
                  className="w-full bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-lg px-3 py-1.5 text-xs text-gray-900 dark:text-white placeholder-gray-300 dark:placeholder-white/20 focus:outline-none focus:ring-1 focus:ring-violet-500/50 transition-all"
                />
              </div>
            ))}
          </div>
        )}

        <div>
          <label className="block text-xs font-medium text-gray-500 dark:text-white/50 mb-1">상태</label>
          <select
            value={block.status}
            onChange={(e) => onUpdate({ status: e.target.value as PromptBlock['status'] })}
            className="w-full bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-lg px-3 py-2 text-sm text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-500/50 transition-all dark:[color-scheme:dark]"
          >
            <option value="draft">초안</option>
            <option value="in_progress">작성중</option>
            <option value="complete">완성</option>
          </select>
        </div>

        <div className="flex gap-2 pt-1">
          <button
            onClick={() => { onDelete(); onClose(); }}
            className="flex-1 py-2 text-sm text-red-500 border border-red-500/20 rounded-lg hover:bg-red-500/10 transition-all"
          >
            삭제
          </button>
          <button
            onClick={onClose}
            className="flex-1 py-2 text-sm bg-violet-600 text-white rounded-lg hover:bg-violet-700 transition-all"
          >
            완료
          </button>
        </div>
      </div>
    </div>
  );
}

// ─── TextBlockRenderer ────────────────────────────────────────────────────────
// Always renders a single <textarea>. Slash command inserts markdown prefix.
function TextBlockRenderer({
  block,
  slashActive,
  slashState,
  onSlashSelect,
  textareaRef,
  onChangeText,
  onKeyDown,
  onBlur,
  onRemove,
  showRemove,
}: {
  block: TextBlock;
  slashActive: boolean;
  slashState: SlashState | null;
  onSlashSelect: (cmd: SlashCmd) => void;
  textareaRef: (el: HTMLTextAreaElement | null) => void;
  onChangeText: (val: string, cursor: number) => void;
  onKeyDown: (e: React.KeyboardEvent<HTMLTextAreaElement>) => void;
  onBlur: () => void;
  onRemove: () => void;
  showRemove: boolean;
}) {
  return (
    <div className="group relative" onClick={(e) => e.stopPropagation()}>
      <div className="relative">
        <textarea
          ref={textareaRef}
          value={block.content}
          onChange={(e) => onChangeText(e.target.value, e.target.selectionStart ?? 0)}
          onKeyDown={onKeyDown}
          onBlur={onBlur}
          onClick={(e) => e.stopPropagation()}
          rows={4}
          className="w-full bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-sm text-gray-700 dark:text-white/80 placeholder-gray-300 dark:placeholder-white/20 focus:outline-none focus:ring-2 focus:ring-violet-500/30 focus:border-violet-500/40 transition-all resize-y font-mono"
          placeholder="내용을 입력하세요 (/ 로 서식 삽입)..."
        />
        {slashActive && slashState && (
          <SlashCommandMenu state={slashState} onSelect={onSlashSelect} />
        )}
      </div>
      {showRemove && (
        <button
          onClick={onRemove}
          className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 w-6 h-6 flex items-center justify-center rounded-full bg-red-500/20 text-red-500 hover:bg-red-500/30 text-xs transition-all"
        >
          ×
        </button>
      )}
    </div>
  );
}

// ─── SimpleModeEditor ─────────────────────────────────────────────────────────
function SimpleModeEditor({
  templateBody,
  varDescriptions,
  onTemplateChange,
  onVarDescChange,
}: {
  templateBody: string;
  varDescriptions: Record<string, string>;
  onTemplateChange: (val: string) => void;
  onVarDescChange: (key: string, val: string) => void;
}) {
  const varKeys = extractVarKeys(templateBody);

  return (
    <div className="space-y-5">
      {/* Template body */}
      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <label className="text-sm font-medium text-gray-600 dark:text-white/60">프롬프트 템플릿</label>
          <span className="text-xs text-gray-400 dark:text-white/30">
            <code className="bg-violet-500/10 text-violet-500 dark:text-violet-400 px-1.5 py-0.5 rounded font-mono">
              {'{{변수명}}'}
            </code>
            {' '}으로 변수를 만들 수 있어요
          </span>
        </div>
        <textarea
          value={templateBody}
          onChange={(e) => onTemplateChange(e.target.value)}
          rows={12}
          placeholder={`당신은 {{role}} 전문가입니다.\n\n{{topic}}에 대해 {{audience}}가 이해하기 쉽게 설명해주세요.\n\n조건:\n- 핵심만 간결하게\n- 예시 2개 이상 포함`}
          className="w-full bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-sm font-mono text-gray-900 dark:text-white placeholder-gray-300 dark:placeholder-white/20 focus:outline-none focus:ring-2 focus:ring-violet-500/30 focus:border-violet-500/40 transition-all resize-y"
        />
      </div>

      {/* Auto-detected variables */}
      {varKeys.length > 0 && (
        <div className="space-y-3">
          <div className="flex items-center gap-2">
            <div className="h-px flex-1 bg-gray-200 dark:bg-white/10" />
            <span className="text-xs text-gray-400 dark:text-white/30 px-2 flex items-center gap-1">
              <span className="w-1.5 h-1.5 rounded-full bg-violet-400 inline-block" />
              감지된 변수 {varKeys.length}개
            </span>
            <div className="h-px flex-1 bg-gray-200 dark:bg-white/10" />
          </div>
          <div className="grid gap-2">
            {varKeys.map((k) => (
              <div
                key={k}
                className="flex items-center gap-3 bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 transition-all focus-within:border-violet-400/50 focus-within:ring-1 focus-within:ring-violet-500/20"
              >
                <code className="text-xs text-violet-500 dark:text-violet-400 bg-violet-500/10 px-2 py-1 rounded font-mono flex-shrink-0 whitespace-nowrap">
                  {'{{' + k + '}}'}
                </code>
                <input
                  type="text"
                  value={varDescriptions[k] || ''}
                  onChange={(e) => onVarDescChange(k, e.target.value)}
                  placeholder="사용자에게 보여줄 설명 (선택사항)"
                  className="flex-1 bg-transparent text-sm text-gray-700 dark:text-white/70 placeholder-gray-300 dark:placeholder-white/30 outline-none min-w-0"
                />
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────
export default function PromptEditorPage({ promptId, token }: Props) {
  const router = useRouter();
  const isEdit = !!promptId;

  // ─── Shared state ────────────────────────────────────────────────────────────
  const [mode, setMode] = useState<EditorMode>('simple');
  const [postTitle, setPostTitle] = useState('');
  const [postDesc, setPostDesc] = useState('');
  const [tags, setTags] = useState<string[]>([]);
  const [tagInput, setTagInput] = useState('');
  const [visibility, setVisibility] = useState<'private' | 'public'>('public');
  const [saving, setSaving] = useState(false);
  const [loading, setLoading] = useState(isEdit);
  const [error, setError] = useState<string | null>(null);
  const [modeError, setModeError] = useState<string | null>(null);

  // ─── Simple mode state ───────────────────────────────────────────────────────
  const [simpleTemplateBody, setSimpleTemplateBody] = useState('');
  const [simpleVarDescriptions, setSimpleVarDescriptions] = useState<Record<string, string>>({});
  // Preserves existing server ID for edit mode (needed for DELETE on save)
  const [simplePostPromptId, setSimplePostPromptId] = useState<string | undefined>(undefined);

  // ─── Advanced mode state ─────────────────────────────────────────────────────
  const [blocks, setBlocks] = useState<Block[]>([{ id: uid(), type: 'text', content: '' }]);
  const [slashState, setSlashState] = useState<SlashState | null>(null);
  const [activeModalId, setActiveModalId] = useState<string | null>(null);

  const textareaRefs = useRef<Record<string, HTMLTextAreaElement | null>>({});
  const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

  // ─── Edit mode: load existing data ─────────────────────────────────────────
  useEffect(() => {
    if (!isEdit || !promptId) return;

    const load = async () => {
      setLoading(true);
      try {
        const [detailRes, postPromptsRes] = await Promise.all([
          fetch(`${API_BASE}/api/me/prompts/${promptId}/detail`, {
            headers: { Authorization: `Bearer ${token}` },
          }),
          fetch(`${API_BASE}/api/me/prompts/${promptId}/post-prompts`, {
            headers: { Authorization: `Bearer ${token}` },
          }),
        ]);

        if (!detailRes.ok) { setError('프롬프트를 불러올 수 없습니다.'); setLoading(false); return; }

        const detailJson = await detailRes.json();
        const p = detailJson.data || {};
        setPostTitle(p.title || '');
        setPostDesc(p.description || '');
        setTags(p.tags || []);
        setVisibility(p.visibility === 'private' ? 'private' : 'public');

        // Backend returns snake_case — support both for safety
        const bodyMarkdown: string = p.body_markdown || p.bodyMarkdown || '';
        const postPromptsJson = postPromptsRes.ok ? await postPromptsRes.json() : { data: [] };
        const serverPrompts: Array<{
          id: string;
          title: string;
          template_body?: string; templateBody?: string;
          status: 'draft' | 'in_progress' | 'complete';
          variables?: Array<{ key: string; description?: string }>;
          sort_order?: number; sortOrder?: number;
        }> = (postPromptsJson.data || []).sort(
          (a: { sort_order?: number; sortOrder?: number }, b: { sort_order?: number; sortOrder?: number }) =>
            (a.sort_order ?? a.sortOrder ?? 0) - (b.sort_order ?? b.sortOrder ?? 0)
        );

        // Reconstruct blocks from bodyMarkdown using [[PROMPT:N]] markers
        const reconstructedBlocks: Block[] = [];
        const segments = bodyMarkdown.split(/\[\[PROMPT:(\d+)\]\]/);
        for (let i = 0; i < segments.length; i++) {
          if (i % 2 === 0) {
            // Text segment — store raw markdown as-is
            const seg = segments[i].trim();
            if (seg) {
              reconstructedBlocks.push({ id: uid(), type: 'text', content: seg });
            }
          } else {
            // Prompt index
            const idx = parseInt(segments[i], 10);
            const sp = serverPrompts[idx];
            if (sp) {
              const varDescs: Record<string, string> = {};
              (sp.variables || []).forEach((v) => {
                if (v.description) varDescs[v.key] = v.description;
              });
              reconstructedBlocks.push({
                id: uid(),
                type: 'prompt',
                postPromptId: sp.id,
                title: sp.title,
                templateBody: sp.template_body || sp.templateBody || '',
                status: sp.status,
                variableDescriptions: varDescs,
              });
            }
          }
        }

        if (reconstructedBlocks.length === 0) {
          reconstructedBlocks.push({ id: uid(), type: 'text', content: '' });
        }

        // Auto-detect mode: simple if exactly 1 prompt block and no text content
        const promptBlocksOnly = reconstructedBlocks.filter((b) => b.type === 'prompt') as PromptBlock[];
        const textBlocksWithContent = reconstructedBlocks.filter(
          (b) => b.type === 'text' && (b as TextBlock).content.trim()
        );

        if (promptBlocksOnly.length === 1 && textBlocksWithContent.length === 0) {
          const pb = promptBlocksOnly[0];
          setSimpleTemplateBody(pb.templateBody);
          setSimpleVarDescriptions(pb.variableDescriptions);
          setSimplePostPromptId(pb.postPromptId);
          setMode('simple');
        } else {
          setBlocks(reconstructedBlocks);
          setMode('advanced');
        }
      } catch {
        setError('오류가 발생했습니다.');
      }
      setLoading(false);
    };

    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [promptId]);

  // ─── Mode switch ─────────────────────────────────────────────────────────────
  const canSwitchToSimple = (() => {
    const promptBlocks = blocks.filter((b) => b.type === 'prompt');
    const textBlocksWithContent = blocks.filter(
      (b) => b.type === 'text' && (b as TextBlock).content.trim()
    );
    return promptBlocks.length <= 1 && textBlocksWithContent.length === 0;
  })();

  const switchToAdvanced = () => {
    // Carry simple state into a single PromptBlock
    const newBlock: PromptBlock = {
      id: uid(),
      type: 'prompt',
      postPromptId: simplePostPromptId,
      title: postTitle || '프롬프트',
      templateBody: simpleTemplateBody,
      status: 'complete',
      variableDescriptions: simpleVarDescriptions,
    };
    setBlocks([newBlock]);
    setMode('advanced');
    setModeError(null);
  };

  const switchToSimple = () => {
    if (!canSwitchToSimple) {
      setModeError('간단 모드는 프롬프트 블록이 1개이고 텍스트 블록 내용이 없을 때만 전환할 수 있습니다.');
      return;
    }
    const pb = blocks.find((b) => b.type === 'prompt') as PromptBlock | undefined;
    if (pb) {
      setSimpleTemplateBody(pb.templateBody);
      setSimpleVarDescriptions(pb.variableDescriptions);
      setSimplePostPromptId(pb.postPromptId);
    }
    setMode('simple');
    setModeError(null);
  };

  // ─── Block operations ───────────────────────────────────────────────────────
  const updateBlock = useCallback((id: string, updates: Partial<Block>) => {
    setBlocks((prev) => prev.map((b) => (b.id === id ? ({ ...b, ...updates } as Block) : b)));
  }, []);

  const removeBlock = (id: string) => {
    setBlocks((prev) => prev.filter((b) => b.id !== id));
    if (activeModalId === id) setActiveModalId(null);
  };

  const addTextBlock = () => {
    setBlocks((prev) => [...prev, { id: uid(), type: 'text', content: '' }]);
  };

  const addPromptBlock = () => {
    const newBlock: PromptBlock = {
      id: uid(),
      type: 'prompt',
      title: '새 프롬프트',
      templateBody: '',
      status: 'draft',
      variableDescriptions: {},
    };
    setBlocks((prev) => [...prev, newBlock]);
    setActiveModalId(newBlock.id);
  };

  // ─── Slash command handlers ─────────────────────────────────────────────────
  const applySlashCommand = useCallback(
    (blockId: string, cmd: SlashCmd) => {
      const block = blocks.find((b) => b.id === blockId) as TextBlock | undefined;
      if (!block || !slashState) { setSlashState(null); return; }

      const slashPos = slashState.slashPos;
      const endPos = slashPos + 1 + slashState.query.length;
      const newContent = block.content.slice(0, slashPos) + cmd.insert + block.content.slice(endPos);
      const newCursorPos = slashPos + cmd.insert.length;

      updateBlock(blockId, { content: newContent });
      setSlashState(null);

      setTimeout(() => {
        const el = textareaRefs.current[blockId];
        if (el) {
          el.focus();
          el.setSelectionRange(newCursorPos, newCursorPos);
        }
      }, 10);
    },
    [blocks, updateBlock, slashState]
  );

  const handleInputChange = (blockId: string, val: string, cursorPos: number) => {
    updateBlock(blockId, { content: val });

    const textBeforeCursor = val.slice(0, cursorPos);
    const lastNewline = textBeforeCursor.lastIndexOf('\n');
    const lineStart = lastNewline + 1;
    const lineBeforeCursor = textBeforeCursor.slice(lineStart);

    if (lineBeforeCursor.startsWith('/') && !lineBeforeCursor.includes(' ')) {
      const query = lineBeforeCursor.slice(1);
      setSlashState((prev) => ({
        blockId,
        query,
        slashPos: lineStart,
        selectedIdx: prev?.blockId === blockId ? prev.selectedIdx : 0,
      }));
    } else {
      if (slashState?.blockId === blockId) setSlashState(null);
    }
  };

  const handleInputKeyDown = (
    blockId: string,
    e: React.KeyboardEvent<HTMLTextAreaElement>
  ) => {
    if (!slashState || slashState.blockId !== blockId) return;

    const filtered = SLASH_COMMANDS.filter(
      (c) => c.name.startsWith(slashState.query.toLowerCase()) || c.label.includes(slashState.query)
    );
    if (filtered.length === 0) return;

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      setSlashState((s) => s && { ...s, selectedIdx: (s.selectedIdx + 1) % filtered.length });
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      setSlashState((s) => s && { ...s, selectedIdx: (s.selectedIdx - 1 + filtered.length) % filtered.length });
    } else if (e.key === 'Enter') {
      e.preventDefault();
      const cmd = filtered[slashState.selectedIdx % filtered.length];
      if (cmd) applySlashCommand(blockId, cmd);
    } else if (e.key === 'Escape') {
      e.preventDefault();
      setSlashState(null);
    }
  };

  // ─── Assemble bodyMarkdown (advanced mode only) ──────────────────────────────
  const assembleBodyMarkdown = () => {
    const parts: string[] = [];
    let promptIndex = 0;
    for (const block of blocks) {
      if (block.type === 'text') {
        const content = (block as TextBlock).content;
        if (content.trim()) parts.push(content);
      } else {
        parts.push(`[[PROMPT:${promptIndex}]]`);
        promptIndex++;
      }
    }
    return parts.join('\n\n');
  };

  // ─── Tags helpers ───────────────────────────────────────────────────────────
  const addTag = (val: string) => {
    const clean = val.trim().replace(/,/g, '');
    if (clean && !tags.includes(clean) && tags.length < 10) setTags((p) => [...p, clean]);
  };

  // ─── Save handler ───────────────────────────────────────────────────────────
  const handleSave = async (saveVisibility: 'draft' | 'private' | 'public') => {
    const effectiveTitle = postTitle.trim() ||
      (saveVisibility === 'draft'
        ? `임시저장 ${new Date().toLocaleDateString('ko-KR', { month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' })}`
        : '');
    if (!effectiveTitle) { setError('제목을 입력하세요'); return; }

    // Determine effective prompt blocks based on mode
    const effectivePromptBlocks: PromptBlock[] =
      mode === 'simple'
        ? [{
            id: uid(),
            type: 'prompt',
            postPromptId: simplePostPromptId,
            title: effectiveTitle,
            templateBody: simpleTemplateBody,
            status: 'complete',
            variableDescriptions: simpleVarDescriptions,
          }]
        : (blocks.filter((b) => b.type === 'prompt') as PromptBlock[]);

    // Validate advanced mode: all blocks must be complete before publish
    if (saveVisibility !== 'draft' && mode === 'advanced') {
      const incomplete = effectivePromptBlocks.filter((pb) => pb.status !== 'complete');
      if (incomplete.length > 0) {
        setError(
          `모든 프롬프트 블록이 '완성' 상태여야 발행할 수 있습니다. 현재 미완성 블록: ${incomplete.length}개`
        );
        return;
      }
    }

    setSaving(true);
    setError(null);

    try {
      const bodyMarkdown = mode === 'simple' ? '[[PROMPT:0]]' : assembleBodyMarkdown();
      const firstPrompt = effectivePromptBlocks[0];

      if (isEdit && promptId) {
        const res = await fetch(`${API_BASE}/api/me/prompts/${promptId}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
          body: JSON.stringify({
            title: effectiveTitle,
            description: postDesc,
            tags,
            visibility: saveVisibility,
            bodyMarkdown,
            templateBody: firstPrompt?.templateBody || '',
          }),
        });
        if (!res.ok) throw new Error('저장 실패');

        // Delete all existing post-prompts then recreate
        const existingIds = effectivePromptBlocks
          .map((pb) => pb.postPromptId)
          .filter(Boolean) as string[];

        await Promise.allSettled(
          existingIds.map((ppId) =>
            fetch(`${API_BASE}/api/me/prompts/${promptId}/post-prompts/${ppId}`, {
              method: 'DELETE',
              headers: { Authorization: `Bearer ${token}` },
            })
          )
        );

        if (effectivePromptBlocks.length > 0) {
          await Promise.allSettled(
            effectivePromptBlocks.map((pb, i) =>
              fetch(`${API_BASE}/api/me/prompts/${promptId}/post-prompts`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
                body: JSON.stringify({
                  title: pb.title,
                  templateBody: pb.templateBody,
                  status: pb.status,
                  sortOrder: i,
                  variables: extractVarKeys(pb.templateBody).map((key) => ({
                    key,
                    label: key,
                    description: pb.variableDescriptions[key] || undefined,
                    type: 'text',
                  })),
                }),
              })
            )
          );
        }
      } else {
        const res = await fetch(`${API_BASE}/api/me/prompts`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
          body: JSON.stringify({
            title: effectiveTitle,
            description: postDesc,
            templateBody: firstPrompt?.templateBody || '',
            bodyMarkdown,
            visibility: saveVisibility,
            tags,
          }),
        });
        if (!res.ok) throw new Error('저장 실패');
        const created = await res.json();
        const newId = created.data?.id;

        if (newId && effectivePromptBlocks.length > 0) {
          await Promise.allSettled(
            effectivePromptBlocks.map((pb, i) =>
              fetch(`${API_BASE}/api/me/prompts/${newId}/post-prompts`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
                body: JSON.stringify({
                  title: pb.title,
                  templateBody: pb.templateBody,
                  status: pb.status,
                  sortOrder: i,
                  variables: extractVarKeys(pb.templateBody).map((key) => ({
                    key,
                    label: key,
                    description: pb.variableDescriptions[key] || undefined,
                    type: 'text',
                  })),
                }),
              })
            )
          );
        }
      }

      router.push('/me/library');
    } catch {
      setError('저장 중 오류가 발생했습니다');
    } finally {
      setSaving(false);
    }
  };

  // ─── Loading state ──────────────────────────────────────────────────────────
  if (loading) {
    return (
      <div className="flex-1 bg-white dark:bg-[#0a0a0f] flex items-center justify-center">
        <div className="text-gray-400 dark:text-white/40">로딩 중...</div>
      </div>
    );
  }

  const activeModalBlock = activeModalId
    ? (blocks.find((b) => b.id === activeModalId && b.type === 'prompt') as PromptBlock | undefined)
    : undefined;

  // ─── Render ─────────────────────────────────────────────────────────────────
  return (
    <div
      className="bg-white dark:bg-[#0a0a0f]"
      onClick={() => slashState && setSlashState(null)}
    >
      {/* Top bar */}
      <div className="sticky top-0 z-20 bg-white/90 dark:bg-[#0a0a0f]/90 backdrop-blur-md border-b border-gray-200 dark:border-white/10">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 py-2 sm:py-3 flex flex-wrap items-center gap-2">
          <h1 className="text-base font-semibold text-gray-900 dark:text-white flex-shrink-0 mr-auto sm:mr-0">
            {isEdit ? '프롬프트 수정' : '새 프롬프트 작성'}
          </h1>

          {/* Mode toggle */}
          <div className="flex items-center gap-1 bg-gray-100 dark:bg-white/10 rounded-lg p-0.5 text-xs flex-shrink-0">
            <button
              onClick={mode === 'advanced' ? switchToSimple : undefined}
              title={mode === 'advanced' && !canSwitchToSimple ? '블록이 여러 개일 때는 전환할 수 없습니다' : undefined}
              className={`px-3 py-1.5 rounded-md transition-all ${
                mode === 'simple'
                  ? 'bg-white dark:bg-white/20 text-gray-900 dark:text-white shadow-sm font-medium'
                  : canSwitchToSimple
                    ? 'text-gray-500 dark:text-white/50 hover:text-gray-700 dark:hover:text-white/70 cursor-pointer'
                    : 'text-gray-300 dark:text-white/20 cursor-not-allowed'
              }`}
            >
              간단히
            </button>
            <button
              onClick={mode === 'simple' ? switchToAdvanced : undefined}
              className={`px-3 py-1.5 rounded-md transition-all ${
                mode === 'advanced'
                  ? 'bg-white dark:bg-white/20 text-gray-900 dark:text-white shadow-sm font-medium'
                  : 'text-gray-500 dark:text-white/50 hover:text-gray-700 dark:hover:text-white/70 cursor-pointer'
              }`}
            >
              자세히
            </button>
          </div>

          <div className="flex items-center gap-2 flex-wrap">
            <select
              value={visibility}
              onChange={(e) => setVisibility(e.target.value as 'private' | 'public')}
              className="px-3 py-1.5 text-sm rounded-lg bg-gray-100 dark:bg-white/10 text-gray-600 dark:text-white/70 border border-gray-200 dark:border-white/10 focus:outline-none focus:ring-2 focus:ring-violet-500/30 transition-all dark:[color-scheme:dark]"
            >
              <option value="public">공개</option>
              <option value="private">비공개</option>
            </select>
            <button
              onClick={() => handleSave('draft')}
              disabled={saving}
              className="px-3 py-1.5 text-sm rounded-lg bg-gray-100 dark:bg-white/10 text-gray-600 dark:text-white/70 hover:bg-gray-200 dark:hover:bg-white/20 transition-all disabled:opacity-40 whitespace-nowrap"
            >
              임시저장
            </button>
            <button
              onClick={() => handleSave(visibility)}
              disabled={saving}
              className="px-3 py-1.5 text-sm rounded-lg bg-gradient-to-r from-violet-600 to-pink-600 text-white font-medium hover:opacity-90 transition-all disabled:opacity-40 whitespace-nowrap"
            >
              {saving ? '저장 중...' : '발행하기'}
            </button>
          </div>
        </div>
      </div>

      {/* Error banner */}
      {error && (
        <div className="max-w-4xl mx-auto px-6 pt-4">
          <div className="flex items-start gap-3 text-sm text-pink-600 dark:text-pink-300 bg-pink-50 dark:bg-pink-500/10 border border-pink-200 dark:border-pink-500/20 rounded-xl p-3">
            <svg className="w-4 h-4 mt-0.5 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z" />
            </svg>
            <span>{error}</span>
            <button
              onClick={() => setError(null)}
              className="ml-auto flex-shrink-0 text-pink-400 hover:text-pink-600 dark:text-pink-400 dark:hover:text-pink-200"
            >
              ×
            </button>
          </div>
        </div>
      )}

      {/* Mode error banner */}
      {modeError && (
        <div className="max-w-4xl mx-auto px-6 pt-4">
          <div className="flex items-start gap-3 text-sm text-amber-600 dark:text-amber-300 bg-amber-50 dark:bg-amber-500/10 border border-amber-200 dark:border-amber-500/20 rounded-xl p-3">
            <span className="flex-1">{modeError}</span>
            <button
              onClick={() => setModeError(null)}
              className="ml-auto flex-shrink-0 text-amber-400 hover:text-amber-600"
            >
              ×
            </button>
          </div>
        </div>
      )}

      {/* Main content */}
      <div className="max-w-4xl mx-auto px-6 py-8 space-y-5">
        {/* Post meta — shared across both modes */}
        <div className="space-y-3">
          <input
            type="text"
            value={postTitle}
            onChange={(e) => setPostTitle(e.target.value)}
            placeholder="제목을 입력하세요"
            className="w-full text-3xl font-bold bg-transparent border-none outline-none text-gray-900 dark:text-white placeholder-gray-300 dark:placeholder-white/20"
          />
          {/* Description only shown in advanced mode */}
          {mode === 'advanced' && (
            <input
              type="text"
              value={postDesc}
              onChange={(e) => setPostDesc(e.target.value)}
              placeholder="설명 (선택사항)"
              className="w-full text-base bg-transparent border-none outline-none text-gray-500 dark:text-white/50 placeholder-gray-300 dark:placeholder-white/20"
            />
          )}
          {/* Tags */}
          <div className="flex flex-wrap gap-1.5 min-h-[32px] items-center">
            {tags.map((tag) => (
              <span
                key={tag}
                className="inline-flex items-center gap-1 bg-violet-500/20 text-violet-600 dark:text-violet-300 text-xs px-2.5 py-1 rounded-full border border-violet-500/30"
              >
                #{tag}
                <button
                  type="button"
                  onClick={() => setTags((p) => p.filter((t) => t !== tag))}
                  className="hover:text-violet-800 dark:hover:text-violet-100 font-bold ml-0.5"
                >
                  ×
                </button>
              </span>
            ))}
            <input
              type="text"
              value={tagInput}
              onChange={(e) => setTagInput(e.target.value)}
              onKeyDown={(e) => {
                if (e.nativeEvent.isComposing) return;
                if (e.key === 'Enter' || e.key === ',') {
                  e.preventDefault();
                  addTag(tagInput);
                  setTagInput('');
                } else if (e.key === 'Backspace' && tagInput === '' && tags.length > 0) {
                  setTags((p) => p.slice(0, -1));
                }
              }}
              onBlur={() => {
                if (tagInput.trim()) { addTag(tagInput); setTagInput(''); }
              }}
              placeholder={tags.length === 0 ? '태그 추가 (Enter)...' : ''}
              className="text-sm bg-transparent outline-none text-gray-500 dark:text-white/50 placeholder-gray-400 dark:placeholder-white/30 min-w-[120px]"
            />
          </div>
          <div className="border-b border-gray-200 dark:border-white/10" />
        </div>

        {/* ── Simple mode content ── */}
        {mode === 'simple' && (
          <SimpleModeEditor
            templateBody={simpleTemplateBody}
            varDescriptions={simpleVarDescriptions}
            onTemplateChange={setSimpleTemplateBody}
            onVarDescChange={(k, v) =>
              setSimpleVarDescriptions((prev) => ({ ...prev, [k]: v }))
            }
          />
        )}

        {/* ── Advanced mode content ── */}
        {mode === 'advanced' && (
          <>
            {/* Content blocks */}
            <div className="space-y-3">
              {blocks.map((block) => {
                if (block.type === 'text') {
                  const tb = block as TextBlock;
                  const isSlashActive = slashState?.blockId === tb.id;
                  return (
                    <TextBlockRenderer
                      key={tb.id}
                      block={tb}
                      slashActive={isSlashActive}
                      slashState={slashState}
                      onSlashSelect={(cmd) => applySlashCommand(tb.id, cmd)}
                      textareaRef={(el) => { textareaRefs.current[tb.id] = el; }}
                      onChangeText={(val, cursor) => handleInputChange(tb.id, val, cursor)}
                      onKeyDown={(e) => handleInputKeyDown(tb.id, e)}
                      onBlur={() => setTimeout(() => setSlashState(null), 150)}
                      onRemove={() => removeBlock(tb.id)}
                      showRemove={blocks.length > 1}
                    />
                  );
                }

                const pb = block as PromptBlock;
                const varKeys = extractVarKeys(pb.templateBody);
                return (
                  <div
                    key={pb.id}
                    onClick={() => setActiveModalId(pb.id)}
                    className="group relative rounded-xl border-2 border-dashed border-gray-300 dark:border-white/20 hover:border-violet-400/50 bg-gray-50 dark:bg-white/5 cursor-pointer transition-all"
                  >
                    <div className="p-4 space-y-2">
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-mono text-violet-500 dark:text-violet-400 bg-violet-500/10 px-2 py-0.5 rounded">
                          PROMPT
                        </span>
                        <span className="text-sm font-medium text-gray-700 dark:text-white/80">
                          {pb.title || '제목 없음'}
                        </span>
                        <span className={`ml-auto text-xs px-2 py-0.5 rounded-full ${STATUS_COLORS[pb.status]}`}>
                          {STATUS_LABELS[pb.status]}
                        </span>
                      </div>
                      {pb.templateBody && (
                        <p className="text-xs text-gray-400 dark:text-white/30 font-mono truncate pl-1">
                          {pb.templateBody.slice(0, 80)}{pb.templateBody.length > 80 ? '...' : ''}
                        </p>
                      )}
                      {varKeys.length > 0 && (
                        <div className="flex flex-wrap gap-1 pt-1">
                          {varKeys.map((k) => (
                            <span key={k} className="text-xs bg-violet-500/20 text-violet-500 dark:text-violet-400 px-1.5 py-0.5 rounded font-mono">
                              {'{{' + k + '}}'}
                            </span>
                          ))}
                        </div>
                      )}
                      <p className="text-xs text-gray-400 dark:text-white/30 pt-1">클릭하여 편집</p>
                    </div>
                    <button
                      onClick={(e) => { e.stopPropagation(); removeBlock(pb.id); }}
                      className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 w-6 h-6 flex items-center justify-center rounded-full bg-red-500/20 text-red-500 hover:bg-red-500/30 text-xs transition-all"
                    >
                      ×
                    </button>
                  </div>
                );
              })}
            </div>

            {/* Add block buttons */}
            <div className="flex gap-3">
              <button
                onClick={addTextBlock}
                className="flex items-center gap-2 px-4 py-2 text-sm text-gray-500 dark:text-white/40 border border-dashed border-gray-300 dark:border-white/20 rounded-xl hover:border-gray-400 dark:hover:border-white/40 hover:text-gray-700 dark:hover:text-white/60 transition-all"
              >
                + 텍스트 블록
              </button>
              <button
                onClick={addPromptBlock}
                className="flex items-center gap-2 px-4 py-2 text-sm text-violet-500 dark:text-violet-400 border border-dashed border-violet-400/50 rounded-xl hover:border-violet-500 hover:bg-violet-500/5 transition-all"
              >
                + 프롬프트 추가
              </button>
            </div>
          </>
        )}
      </div>

      {/* Prompt block modal (advanced mode only) */}
      {activeModalBlock && (
        <PromptBlockModal
          block={activeModalBlock}
          onUpdate={(updates) => updateBlock(activeModalBlock.id, updates)}
          onDelete={() => removeBlock(activeModalBlock.id)}
          onClose={() => setActiveModalId(null)}
        />
      )}
    </div>
  );
}
