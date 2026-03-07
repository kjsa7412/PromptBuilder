'use client';

import { useState } from 'react';
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
  const [activePostPromptId, setActivePostPromptId] = useState<string | null>(
    postPrompts.length > 0 ? postPrompts[0].id : null
  );

  const activePostPrompt = postPrompts.find((pp) => pp.id === activePostPromptId) || null;
  const blocks = parseContentBlocks(prompt.bodyMarkdown || '', postPrompts);

  return (
    <div className="grid grid-cols-1 lg:grid-cols-5 gap-8">
      {/* Left: tags, title, actions, content blocks */}
      <div className="lg:col-span-3 space-y-6">
        {prompt.tags && prompt.tags.length > 0 && (
          <div className="flex flex-wrap gap-2">
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

        <h1 className="text-3xl md:text-4xl font-bold text-gray-900 dark:text-white leading-tight">
          {prompt.title}
        </h1>

        <PromptActions
          promptId={prompt.id}
          initialClipCount={prompt.clipCount ?? 0}
          initialLikeCount={prompt.likeCount ?? 0}
          initialGenerateCount={prompt.generateCount ?? 0}
        />

        {!prompt.bodyMarkdown && prompt.description && (
          <p className="text-gray-500 dark:text-white/60 leading-relaxed">{prompt.description}</p>
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
              const isActive = activePostPromptId === pp.id;
              return (
                <button
                  key={idx}
                  onClick={() => setActivePostPromptId(pp.id)}
                  className={`w-full text-left rounded-xl border-2 p-4 transition-all ${
                    isActive
                      ? 'border-violet-500/60 bg-violet-500/5 dark:bg-violet-500/10'
                      : 'border-gray-200 dark:border-white/10 hover:border-violet-400/40 bg-gray-50 dark:bg-white/3'
                  }`}
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
                        className={`ml-auto text-xs px-2 py-0.5 rounded-full ${
                          STATUS_COLORS[pp.status as keyof typeof STATUS_COLORS] || STATUS_COLORS.draft
                        }`}
                      >
                        {STATUS_LABELS[pp.status as keyof typeof STATUS_LABELS] || pp.status}
                      </span>
                    )}
                  </div>

                  {!isActive && pp.templateBody && (
                    <p className="text-xs text-gray-400 dark:text-white/30 font-mono truncate mt-1">
                      {pp.templateBody.slice(0, 100)}
                      {pp.templateBody.length > 100 ? '...' : ''}
                    </p>
                  )}

                  {isActive && pp.variables && pp.variables.length > 0 && (
                    <div className="mt-3 pt-3 border-t border-violet-500/20 space-y-2">
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

                  {isActive && (
                    <p className="text-xs text-violet-500/60 dark:text-violet-400/50 mt-3 text-right">
                      오른쪽에서 값을 입력하고 생성하세요
                    </p>
                  )}
                </button>
              );
            })}
          </div>
        ) : (
          <p className="text-sm text-gray-400 dark:text-white/40 py-4">프롬프트 내용이 없습니다.</p>
        )}
      </div>

      {/* Right: variable input & generate panel */}
      <div className="lg:col-span-2">
        <div className="sticky top-20 rounded-2xl bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 p-6">
          {activePostPrompt ? (
            <>
              <div className="mb-5">
                <h2 className="text-lg font-bold text-gray-900 dark:text-white">변수 입력 &amp; 생성</h2>
                <p className="text-xs text-gray-500 dark:text-white/40 mt-1 font-medium">
                  {activePostPrompt.title}
                </p>
              </div>
              <PromptBuilder
                promptId={prompt.id}
                templateBody={activePostPrompt.templateBody}
                variables={activePostPrompt.variables || []}
              />
            </>
          ) : (
            <div className="text-center py-8">
              <h2 className="text-lg font-bold text-gray-900 dark:text-white mb-3">
                변수 입력 &amp; 생성
              </h2>
              <p className="text-sm text-gray-400 dark:text-white/40">
                왼쪽에서 프롬프트를 선택하세요
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
