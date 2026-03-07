'use client';

import { useState, useEffect, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';

const PLACEHOLDER_RE = /\{\{\s*([a-zA-Z0-9_]+)\s*\}\}/g;

function extractVarKeys(template: string): string[] {
  const keys = new Set<string>();
  let m;
  const re = new RegExp(PLACEHOLDER_RE.source, 'g');
  while ((m = re.exec(template)) !== null) keys.add(m[1]);
  return Array.from(keys);
}

let _id = 0;
const uid = () => `b${++_id}-${Date.now()}`;

interface TextBlock {
  id: string;
  type: 'text';
  content: string;
}

interface PromptBlock {
  id: string;
  type: 'prompt';
  title: string;
  templateBody: string;
  status: 'draft' | 'in_progress' | 'complete';
  variableDescriptions: Record<string, string>;
}

type Block = TextBlock | PromptBlock;

const STATUS_LABELS = { draft: '초안', in_progress: '작성중', complete: '완성' } as const;
const STATUS_COLORS = {
  draft: 'bg-gray-100 dark:bg-white/10 text-gray-500 dark:text-white/50',
  in_progress: 'bg-yellow-100 dark:bg-yellow-500/20 text-yellow-600 dark:text-yellow-300',
  complete: 'bg-green-100 dark:bg-green-500/20 text-green-600 dark:text-green-300',
} as const;

export default function NewPromptPage() {
  const router = useRouter();
  const [postTitle, setPostTitle] = useState('');
  const [postDesc, setPostDesc] = useState('');
  const [tags, setTags] = useState<string[]>([]);
  const [tagInput, setTagInput] = useState('');
  const [blocks, setBlocks] = useState<Block[]>([{ id: uid(), type: 'text', content: '' }]);
  const [activeId, setActiveId] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (!data.session) router.push('/login');
      else setToken(data.session.access_token);
    });
  }, [router]);

  const activePrompt = activeId
    ? (blocks.find((b) => b.id === activeId && b.type === 'prompt') as PromptBlock | undefined)
    : null;

  const updateBlock = useCallback((id: string, updates: Partial<Block>) => {
    setBlocks((prev) => prev.map((b) => (b.id === id ? ({ ...b, ...updates } as Block) : b)));
  }, []);

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
    setActiveId(newBlock.id);
  };

  const removeBlock = (id: string) => {
    setBlocks((prev) => prev.filter((b) => b.id !== id));
    if (activeId === id) setActiveId(null);
  };

  // 텍스트/프롬프트 블록 순서를 [[PROMPT:N]] 마커로 bodyMarkdown에 인코딩
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

  const handleSave = async (visibility: 'draft' | 'public') => {
    if (!postTitle.trim()) {
      setError('제목을 입력하세요');
      return;
    }
    if (!token) {
      router.push('/login');
      return;
    }
    setSaving(true);
    setError(null);
    try {
      const bodyMarkdown = assembleBodyMarkdown();
      const promptBlocks = blocks.filter((b) => b.type === 'prompt') as PromptBlock[];
      const firstPrompt = promptBlocks[0];

      const res = await fetch(`${API_BASE}/api/me/prompts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({
          title: postTitle,
          description: postDesc,
          templateBody: firstPrompt?.templateBody || '',
          bodyMarkdown,
          visibility,
          tags,
        }),
      });
      if (!res.ok) throw new Error('저장 실패');
      const created = await res.json();
      const promptId = created.data?.id;

      if (promptId && promptBlocks.length > 0) {
        await Promise.allSettled(
          promptBlocks.map((pb, i) =>
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
      router.push('/me/library');
    } catch {
      setError('저장 중 오류가 발생했습니다');
    } finally {
      setSaving(false);
    }
  };

  const addTag = (val: string) => {
    const clean = val.trim().replace(/,/g, '');
    if (clean && !tags.includes(clean) && tags.length < 10) setTags((p) => [...p, clean]);
  };

  return (
    <div className="bg-white dark:bg-[#0a0a0f] min-h-screen">
      {/* Top bar */}
      <div className="sticky top-0 z-20 bg-white/90 dark:bg-[#0a0a0f]/90 backdrop-blur-md border-b border-gray-200 dark:border-white/10">
        <div className="max-w-7xl mx-auto px-6 py-3 flex items-center justify-between">
          <h1 className="text-base font-semibold text-gray-900 dark:text-white">새 프롬프트 작성</h1>
          <div className="flex gap-2">
            <button
              onClick={() => handleSave('draft')}
              disabled={saving}
              className="px-4 py-1.5 text-sm rounded-lg bg-gray-100 dark:bg-white/10 text-gray-600 dark:text-white/70 hover:bg-gray-200 dark:hover:bg-white/20 transition-all disabled:opacity-40"
            >
              임시저장
            </button>
            <button
              onClick={() => handleSave('public')}
              disabled={saving}
              className="px-4 py-1.5 text-sm rounded-lg bg-gradient-to-r from-violet-600 to-pink-600 text-white font-medium hover:opacity-90 transition-all disabled:opacity-40"
            >
              {saving ? '발행 중...' : '발행하기'}
            </button>
          </div>
        </div>
      </div>

      {error && (
        <div className="max-w-7xl mx-auto px-6 pt-4">
          <div className="text-sm text-pink-600 dark:text-pink-300 bg-pink-50 dark:bg-pink-500/10 border border-pink-200 dark:border-pink-500/20 rounded-xl p-3">
            {error}
          </div>
        </div>
      )}

      <div className="max-w-7xl mx-auto px-6 py-8 flex gap-8">
        {/* Left: Content editor */}
        <div className="flex-1 min-w-0 space-y-5">
          {/* Post meta */}
          <div className="space-y-3">
            <input
              type="text"
              value={postTitle}
              onChange={(e) => setPostTitle(e.target.value)}
              placeholder="제목을 입력하세요"
              className="w-full text-3xl font-bold bg-transparent border-none outline-none text-gray-900 dark:text-white placeholder-gray-300 dark:placeholder-white/20"
            />
            <input
              type="text"
              value={postDesc}
              onChange={(e) => setPostDesc(e.target.value)}
              placeholder="설명 (선택사항)"
              className="w-full text-base bg-transparent border-none outline-none text-gray-500 dark:text-white/50 placeholder-gray-300 dark:placeholder-white/20"
            />
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
                  if (e.key === 'Enter' || e.key === ',') {
                    e.preventDefault();
                    addTag(tagInput);
                    setTagInput('');
                  } else if (e.key === 'Backspace' && tagInput === '' && tags.length > 0) {
                    setTags((p) => p.slice(0, -1));
                  }
                }}
                onBlur={() => {
                  if (tagInput.trim()) {
                    addTag(tagInput);
                    setTagInput('');
                  }
                }}
                placeholder={tags.length === 0 ? '태그 추가 (Enter)...' : ''}
                className="text-sm bg-transparent outline-none text-gray-500 dark:text-white/50 placeholder-gray-400 dark:placeholder-white/30 min-w-[120px]"
              />
            </div>
            <div className="border-b border-gray-200 dark:border-white/10" />
          </div>

          {/* Content blocks */}
          <div className="space-y-3">
            {blocks.map((block) => {
              if (block.type === 'text') {
                return (
                  <div key={block.id} className="group relative">
                    <textarea
                      value={(block as TextBlock).content}
                      onChange={(e) => updateBlock(block.id, { content: e.target.value })}
                      placeholder="내용을 입력하세요 (Markdown 지원)..."
                      rows={4}
                      className="w-full bg-gray-50 dark:bg-white/3 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-sm text-gray-700 dark:text-white/80 placeholder-gray-300 dark:placeholder-white/20 focus:outline-none focus:ring-2 focus:ring-violet-500/30 focus:border-violet-500/40 transition-all resize-y"
                    />
                    {blocks.length > 1 && (
                      <button
                        onClick={() => removeBlock(block.id)}
                        className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 w-6 h-6 flex items-center justify-center rounded-full bg-red-500/20 text-red-500 hover:bg-red-500/30 text-xs transition-all"
                      >
                        ×
                      </button>
                    )}
                  </div>
                );
              }

              const pb = block as PromptBlock;
              const isActive = activeId === pb.id;
              const varKeys = extractVarKeys(pb.templateBody);
              return (
                <div
                  key={pb.id}
                  onClick={() => setActiveId(pb.id)}
                  className={`group relative rounded-xl border-2 cursor-pointer transition-all ${
                    isActive
                      ? 'border-violet-500/60 bg-violet-500/5 dark:bg-violet-500/10'
                      : 'border-dashed border-gray-300 dark:border-white/20 hover:border-violet-400/50 bg-gray-50 dark:bg-white/3'
                  }`}
                >
                  <div className="p-4 space-y-2">
                    <div className="flex items-center gap-2">
                      <span className="text-xs font-mono text-violet-500 dark:text-violet-400 bg-violet-500/10 px-2 py-0.5 rounded">
                        PROMPT
                      </span>
                      <span className="text-sm font-medium text-gray-700 dark:text-white/80">
                        {pb.title || '제목 없음'}
                      </span>
                      <span
                        className={`ml-auto text-xs px-2 py-0.5 rounded-full ${STATUS_COLORS[pb.status]}`}
                      >
                        {STATUS_LABELS[pb.status]}
                      </span>
                    </div>
                    {pb.templateBody && (
                      <p className="text-xs text-gray-400 dark:text-white/30 font-mono truncate pl-1">
                        {pb.templateBody.slice(0, 80)}
                        {pb.templateBody.length > 80 ? '...' : ''}
                      </p>
                    )}
                    {varKeys.length > 0 && (
                      <div className="flex flex-wrap gap-1 pt-1">
                        {varKeys.map((k) => (
                          <span
                            key={k}
                            className="text-xs bg-violet-500/20 text-violet-500 dark:text-violet-400 px-1.5 py-0.5 rounded font-mono"
                          >
                            {'{{' + k + '}}'}
                          </span>
                        ))}
                      </div>
                    )}
                  </div>
                  <button
                    onClick={(e) => {
                      e.stopPropagation();
                      removeBlock(pb.id);
                    }}
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
        </div>

        {/* Right: Prompt block editor */}
        <div className="w-80 flex-shrink-0">
          <div className="sticky top-20">
            {activePrompt ? (
              <div className="rounded-2xl bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 p-5 space-y-4">
                <h2 className="text-sm font-semibold text-gray-500 dark:text-white/60 uppercase tracking-wider">
                  프롬프트 편집
                </h2>

                <div>
                  <label className="block text-xs font-medium text-gray-500 dark:text-white/50 mb-1">
                    제목
                  </label>
                  <input
                    type="text"
                    value={activePrompt.title}
                    onChange={(e) => updateBlock(activePrompt.id, { title: e.target.value })}
                    className="w-full bg-white dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-lg px-3 py-2 text-sm text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-500/50 transition-all"
                  />
                </div>

                <div>
                  <label className="block text-xs font-medium text-gray-500 dark:text-white/50 mb-1">
                    템플릿 본문{' '}
                    <span className="text-gray-400 dark:text-white/30">{'{{변수명}}'}</span>
                  </label>
                  <textarea
                    value={activePrompt.templateBody}
                    onChange={(e) => updateBlock(activePrompt.id, { templateBody: e.target.value })}
                    rows={8}
                    placeholder={'{{role}}로서 {{topic}}에 대해 설명해주세요.'}
                    className="w-full bg-white dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-lg px-3 py-2 text-xs font-mono text-gray-900 dark:text-white placeholder-gray-300 dark:placeholder-white/20 focus:outline-none focus:ring-2 focus:ring-violet-500/50 transition-all resize-y"
                  />
                </div>

                {extractVarKeys(activePrompt.templateBody).length > 0 && (
                  <div className="space-y-2">
                    <label className="block text-xs font-medium text-gray-500 dark:text-white/50">
                      변수 설명
                    </label>
                    {extractVarKeys(activePrompt.templateBody).map((k) => (
                      <div key={k}>
                        <code className="block text-xs text-violet-500 dark:text-violet-400 bg-violet-500/10 px-1.5 py-0.5 rounded font-mono mb-1">
                          {'{{' + k + '}}'}
                        </code>
                        <input
                          type="text"
                          value={activePrompt.variableDescriptions[k] || ''}
                          onChange={(e) =>
                            updateBlock(activePrompt.id, {
                              variableDescriptions: {
                                ...activePrompt.variableDescriptions,
                                [k]: e.target.value,
                              },
                            })
                          }
                          placeholder="변수 설명..."
                          className="w-full bg-white dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-lg px-3 py-1.5 text-xs text-gray-900 dark:text-white placeholder-gray-300 dark:placeholder-white/20 focus:outline-none focus:ring-1 focus:ring-violet-500/50 transition-all"
                        />
                      </div>
                    ))}
                  </div>
                )}

                <div>
                  <label className="block text-xs font-medium text-gray-500 dark:text-white/50 mb-1">
                    상태
                  </label>
                  <select
                    value={activePrompt.status}
                    onChange={(e) =>
                      updateBlock(activePrompt.id, {
                        status: e.target.value as PromptBlock['status'],
                      })
                    }
                    className="w-full bg-white dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-lg px-3 py-2 text-sm text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-500/50 transition-all"
                  >
                    <option value="draft">초안</option>
                    <option value="in_progress">작성중</option>
                    <option value="complete">완성</option>
                  </select>
                </div>

                <button
                  onClick={() => removeBlock(activePrompt.id)}
                  className="w-full py-2 text-sm text-red-500 border border-red-500/20 rounded-lg hover:bg-red-500/10 transition-all"
                >
                  이 프롬프트 삭제
                </button>
              </div>
            ) : (
              <div className="rounded-2xl bg-gray-50 dark:bg-white/3 border border-dashed border-gray-200 dark:border-white/10 p-8 text-center">
                <p className="text-2xl mb-3 text-gray-300 dark:text-white/20">+</p>
                <p className="text-sm text-gray-400 dark:text-white/30">
                  프롬프트 블록을 클릭하면
                  <br />
                  여기서 편집할 수 있습니다
                </p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
