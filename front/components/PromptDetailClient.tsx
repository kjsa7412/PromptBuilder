'use client';

import { useState, useEffect } from 'react';
import ReactMarkdown from 'react-markdown';
import PromptActions from './PromptActions';
import PromptBuilder from './PromptBuilder';
import type { PromptDetail, PostPrompt } from '@/lib/api';

type ParsedBlock =
  | { type: 'text'; content: string }
  | { type: 'prompt'; postPrompt: PostPrompt };

/**
 * bodyMarkdown의 [[PROMPT:N]] 마커를 기준으로 텍스트/프롬프트 블록을 순서대로 파싱.
 * 마커가 없으면: 텍스트 먼저, 그 다음 sortOrder 순으로 postPrompts 전부 표시.
 */
function parseContentBlocks(bodyMarkdown: string, postPrompts: PostPrompt[]): ParsedBlock[] {
  const hasMarkdown = bodyMarkdown?.trim();
  const hasMarkers = hasMarkdown && /\[\[PROMPT:\d+\]\]/.test(bodyMarkdown);

  if (hasMarkers) {
    const segments = bodyMarkdown.split(/\[\[PROMPT:(\d+)\]\]/);
    const result: ParsedBlock[] = [];
    for (let i = 0; i < segments.length; i++) {
      if (i % 2 === 0) {
        if (segments[i].trim()) result.push({ type: 'text', content: segments[i].trim() });
      } else {
        const idx = parseInt(segments[i]);
        const pp = postPrompts[idx];
        if (pp) result.push({ type: 'prompt', postPrompt: pp });
      }
    }
    return result;
  }

  // 마커 없음: 텍스트 블록 -> postPrompts sortOrder 순
  const result: ParsedBlock[] = [];
  if (hasMarkdown) result.push({ type: 'text', content: bodyMarkdown });
  const sorted = [...postPrompts].sort((a, b) => a.sortOrder - b.sortOrder);
  for (const pp of sorted) {
    result.push({ type: 'prompt', postPrompt: pp });
  }
  return result;
}

const STATUS_COLORS = {
  draft: 'bg-gray-100 dark:bg-white/10 text-gray-500 dark:text-white/50',
  in_progress: 'bg-yellow-100 dark:bg-yellow-500/20 text-yellow-600 dark:text-yellow-300',
  complete: 'bg-green-100 dark:bg-green-500/20 text-green-600 dark:text-green-300',
} as const;

const STATUS_LABELS = { draft: '초안', in_progress: '작성중', complete: '완성' } as const;

export default function PromptDetailClient({ prompt }: { prompt: PromptDetail }) {
  const postPrompts: PostPrompt[] = prompt.postPrompts || [];
  const [modalPromptId, setModalPromptId] = useState<string | null>(null);
  const [showVariableModal, setShowVariableModal] = useState(false);

  const modalPostPrompt = postPrompts.find((pp) => pp.id === modalPromptId) || null;
  const blocks = parseContentBlocks(prompt.bodyMarkdown || '', postPrompts);

  useEffect(() => {
    const handleEsc = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setShowVariableModal(false);
    };
    if (showVariableModal) {
      document.body.style.overflow = 'hidden';
      window.addEventListener('keydown', handleEsc);
    } else {
      document.body.style.overflow = '';
    }
    return () => {
      window.removeEventListener('keydown', handleEsc);
      document.body.style.overflow = '';
    };
  }, [showVariableModal]);

  const openModal = (ppId: string) => {
    setModalPromptId(ppId);
    setShowVariableModal(true);
  };

  return (
    <div className="max-w-4xl">
      {prompt.tags && prompt.tags.length > 0 && (
        <div className="flex flex-wrap gap-2 mb-6">
          {prompt.tags.map((tag: string) => (
            <a
              key={tag}
              href={`/explore?tag=${encodeURIComponent(tag)}`}
              className="px-3 py-1 text-xs rounded-full bg-violet-500/20 text-violet-600 dark:text-violet-300 border border-violet-500/30 hover:bg-violet-500/30 transition-colors"
            >
              #{tag}
            </a>
          ))}
        </div>
      )}

      <h1 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white leading-tight mb-6">
        {prompt.title}
      </h1>

      {prompt.authorName && (
        <div className="flex items-center gap-2 mb-4">
          {prompt.authorAvatar ? (
            <img src={prompt.authorAvatar} alt={prompt.authorName}
              className="w-8 h-8 rounded-full object-cover ring-1 ring-gray-200 dark:ring-white/10" />
          ) : (
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-violet-400 to-pink-400 flex items-center justify-center text-white text-sm font-bold">
              {prompt.authorName.charAt(0).toUpperCase()}
            </div>
          )}
          <span className="text-sm text-gray-500 dark:text-white/50">{prompt.authorName}</span>
        </div>
      )}

      <div className="mb-6">
        <PromptActions
          promptId={prompt.id}
          initialClipCount={prompt.clipCount ?? 0}
          initialLikeCount={prompt.likeCount ?? 0}
          initialGenerateCount={prompt.generateCount ?? 0}
        />
      </div>

      {!prompt.bodyMarkdown && prompt.description && (
        <p className="text-gray-500 dark:text-white/60 leading-relaxed mb-6">{prompt.description}</p>
      )}

      {blocks.length > 0 ? (
        <div className="space-y-4">
          {blocks.map((block, idx) => {
            if (block.type === 'text') {
              return (
                <div
                  key={idx}
                  className="prose prose-sm prose-gray dark:prose-invert max-w-none text-gray-600 dark:text-white/70 leading-relaxed"
                >
                  <ReactMarkdown>{block.content}</ReactMarkdown>
                </div>
              );
            }

            const pp = block.postPrompt;
            return (
              <div
                key={idx}
                onClick={() => openModal(pp.id)}
                className="rounded-xl border-2 border-gray-200 dark:border-white/10 p-4 bg-gray-50 dark:bg-white/3 hover:border-violet-400/60 hover:bg-violet-500/5 cursor-pointer transition-all"
              >
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-xs font-mono text-violet-500 dark:text-violet-400 bg-violet-500/10 px-2 py-0.5 rounded">
                    PROMPT
                  </span>
                  <span className="text-sm font-medium text-gray-800 dark:text-white">
                    {pp.title}
                  </span>
                  {pp.status && (
                    <span
                      className={`text-xs px-2 py-0.5 rounded-full ${
                        STATUS_COLORS[pp.status as keyof typeof STATUS_COLORS] || STATUS_COLORS.draft
                      }`}
                    >
                      {STATUS_LABELS[pp.status as keyof typeof STATUS_LABELS] || pp.status}
                    </span>
                  )}
                  <span className="ml-auto text-xs text-violet-500 dark:text-violet-400 font-medium">
                    클릭하여 생성 →
                  </span>
                </div>

                {pp.templateBody && (
                  <p className="text-xs text-gray-400 dark:text-white/30 font-mono truncate mt-1">
                    {pp.templateBody.slice(0, 100)}
                    {pp.templateBody.length > 100 ? '...' : ''}
                  </p>
                )}

                {pp.variables && pp.variables.length > 0 && (
                  <div className="mt-3 pt-3 border-t border-gray-200 dark:border-white/10 space-y-2">
                    <p className="text-xs font-semibold text-violet-500 dark:text-violet-400 uppercase tracking-wider mb-2">
                      변수 목록
                    </p>
                    {pp.variables.map((v) => (
                      <div key={v.key} className="flex flex-col gap-0.5">
                        <code className="text-xs text-violet-600 dark:text-violet-300 font-mono bg-violet-500/10 px-2 py-0.5 rounded w-fit">
                          {`{{${v.key}}}`}
                        </code>
                        {(v.description || (v.label && v.label !== v.key)) && (
                          <span className="text-xs text-gray-500 dark:text-white/40 pl-1">
                            {v.description || v.label}
                          </span>
                        )}
                      </div>
                    ))}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      ) : (
        <p className="text-sm text-gray-400 dark:text-white/40 py-4">프롬프트 내용이 없습니다.</p>
      )}

      {showVariableModal && modalPostPrompt && (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center p-4"
          onClick={(e) => { if (e.target === e.currentTarget) setShowVariableModal(false); }}
          style={{ backgroundColor: 'rgba(0,0,0,0.6)' }}
        >
          <div
            className="relative w-full max-w-lg bg-white dark:bg-[#1a1a2e] rounded-2xl border border-gray-200 dark:border-white/10 shadow-2xl overflow-hidden"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal header */}
            <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200 dark:border-white/10">
              <div>
                <h2 className="text-lg font-bold text-gray-900 dark:text-white">변수 입력 &amp; 생성</h2>
                <p className="text-xs text-gray-500 dark:text-white/40 mt-0.5">{modalPostPrompt.title}</p>
              </div>
              <button
                onClick={() => setShowVariableModal(false)}
                className="w-8 h-8 flex items-center justify-center rounded-full text-gray-400 dark:text-white/40 hover:bg-gray-100 dark:hover:bg-white/10 hover:text-gray-600 dark:hover:text-white transition-all"
                aria-label="닫기"
              >
                <svg className="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            {/* Modal body */}
            <div className="p-6 max-h-[70vh] overflow-y-auto">
              <PromptBuilder
                promptId={prompt.id}
                templateBody={modalPostPrompt.templateBody}
                variables={modalPostPrompt.variables || []}
              />
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
