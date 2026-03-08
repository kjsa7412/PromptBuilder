'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import type { PromptCard as PromptCardType } from '@/lib/api';

interface Props {
  prompt: PromptCardType;
  hrefOverride?: string;
}

function getCategoryClass(tags?: string[]): { border: string; shadow: string; badge: string; label: string } {
  if (!tags || tags.length === 0) return { border: 'border-l-violet-400', shadow: 'default-shadow', badge: 'bg-violet-100 dark:bg-violet-500/20 text-violet-600 dark:text-violet-300', label: '' };
  const t = tags.join(' ').toLowerCase();
  if (t.includes('업무') || t.includes('회의') || t.includes('이메일') || t.includes('보고') || t.includes('개발'))
    return { border: 'border-l-blue-400', shadow: 'cat-work-shadow', badge: 'bg-blue-100 dark:bg-blue-500/20 text-blue-600 dark:text-blue-300', label: '업무' };
  if (t.includes('일상') || t.includes('생활') || t.includes('식단') || t.includes('가계') || t.includes('주말'))
    return { border: 'border-l-emerald-400', shadow: 'cat-daily-shadow', badge: 'bg-emerald-100 dark:bg-emerald-500/20 text-emerald-600 dark:text-emerald-300', label: '일상' };
  if (t.includes('창작') || t.includes('글쓰기') || t.includes('소설') || t.includes('마케팅') || t.includes('카피'))
    return { border: 'border-l-amber-400', shadow: 'cat-creative-shadow', badge: 'bg-amber-100 dark:bg-amber-500/20 text-amber-600 dark:text-amber-300', label: '창작' };
  if (t.includes('교육') || t.includes('학습') || t.includes('공부') || t.includes('gpt') || t.includes('claude'))
    return { border: 'border-l-purple-400', shadow: 'cat-edu-shadow', badge: 'bg-purple-100 dark:bg-purple-500/20 text-purple-600 dark:text-purple-300', label: '학습' };
  return { border: 'border-l-violet-400', shadow: 'default-shadow', badge: 'bg-violet-100 dark:bg-violet-500/20 text-violet-600 dark:text-violet-300', label: '' };
}

export default function PromptCard({ prompt, hrefOverride }: Props) {
  const router = useRouter();
  const cat = getCategoryClass(prompt.tags);
  const varCount = prompt.variableCount ?? 0;
  const templatePreview = prompt.firstTemplateBody
    ? prompt.firstTemplateBody.slice(0, 90) + (prompt.firstTemplateBody.length > 90 ? '…' : '')
    : null;

  return (
    <Link href={hrefOverride ? `/p/${hrefOverride}` : `/p/${prompt.id}`}>
      {/*
       * Responsive padding: alternates large/small with the card-grid column breakpoints
       * base(<640):p-5  sm(640):p-3  md(768):p-4  lg(1024):p-3  xl(1280):p-4  2xl(1536):p-3  3xl(1729):p-5
       */}
      <div className={`group relative flex flex-col gap-2.5 p-5 sm:p-3 md:p-4 lg:p-3 xl:p-4 2xl:p-3 3xl:p-5 rounded-2xl bg-white dark:bg-white/[0.04] border border-l-4 border-gray-200 dark:border-white/[0.08] ${cat.border} ${cat.shadow} hover:-translate-y-1 transition-all duration-200 cursor-pointer h-full`}>

        {/* Top row: category badge + variable count */}
        <div className="flex items-start justify-between gap-1.5">
          <div className="flex items-center gap-1 flex-wrap">
            {cat.label && (
              <span className={`text-[10px] font-semibold px-1.5 py-0.5 rounded-full leading-none ${cat.badge}`}>
                {cat.label}
              </span>
            )}
            {prompt.tags && prompt.tags.filter(t => t !== cat.label).slice(0, 2).map((tag) => (
              <span
                key={tag}
                onClick={(e) => { e.preventDefault(); e.stopPropagation(); router.push(`/explore?tag=${encodeURIComponent(tag)}`); }}
                className="text-[10px] px-1.5 py-0.5 rounded-full leading-none bg-gray-100 dark:bg-zinc-700/80 text-gray-500 dark:text-zinc-300 border border-gray-200 dark:border-zinc-600 hover:bg-violet-100 dark:hover:bg-violet-500/25 hover:text-violet-600 dark:hover:text-violet-300 hover:border-violet-300 dark:hover:border-violet-500/40 cursor-pointer transition-colors"
              >
                #{tag}
              </span>
            ))}
          </div>
          {varCount > 0 && (
            <span className="text-[10px] font-mono shrink-0 px-1.5 py-0.5 rounded-md bg-violet-100 dark:bg-violet-500/20 text-violet-600 dark:text-violet-300 border border-violet-200 dark:border-violet-500/30 leading-none">
              {`{{${varCount}}}`}
            </span>
          )}
        </div>

        {/* Title */}
        <h3 className="text-sm font-semibold text-gray-900 dark:text-white line-clamp-2 group-hover:text-violet-600 dark:group-hover:text-violet-300 transition-colors leading-snug">
          {prompt.title}
        </h3>

        {/* Template preview */}
        {templatePreview ? (
          <div className="rounded-lg bg-gray-50 dark:bg-black/30 border border-gray-200 dark:border-white/[0.06] px-2.5 py-1.5">
            <p className="text-[11px] font-mono text-gray-400 dark:text-zinc-500 line-clamp-2 leading-relaxed">
              {templatePreview}
            </p>
          </div>
        ) : prompt.description ? (
          <p className="text-xs text-gray-500 dark:text-zinc-400 line-clamp-2 leading-relaxed flex-1">
            {prompt.description}
          </p>
        ) : null}

        {/* Stats + author */}
        <div className="flex items-center justify-between pt-2 border-t border-gray-100 dark:border-white/[0.06] mt-auto">
          <div className="flex items-center gap-2.5 text-[11px] text-gray-400 dark:text-zinc-500">
            <span className="flex items-center gap-0.5">
              <svg className="w-3 h-3" viewBox="0 0 24 24" fill="currentColor"><path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/></svg>
              {prompt.likeCount ?? 0}
            </span>
            <span className="flex items-center gap-0.5">
              <svg className="w-3 h-3" viewBox="0 0 24 24" fill="currentColor"><path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"/></svg>
              {prompt.clipCount ?? prompt.bookmarkCount ?? 0}
            </span>
            <span className="flex items-center gap-0.5">
              <svg className="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path strokeLinecap="round" strokeLinejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
              {prompt.generateCount ?? 0}
            </span>
          </div>

          {prompt.authorName && (
            <div className="flex items-center gap-1">
              {prompt.authorAvatar ? (
                <img src={prompt.authorAvatar} alt={prompt.authorName} className="w-4 h-4 rounded-full object-cover" />
              ) : (
                <div className="w-4 h-4 rounded-full bg-gradient-to-br from-violet-400 to-pink-400 flex items-center justify-center text-white text-[7px] font-bold shrink-0">
                  {prompt.authorName.charAt(0).toUpperCase()}
                </div>
              )}
              <span className="text-[10px] text-gray-400 dark:text-zinc-500 truncate max-w-[64px]">{prompt.authorName}</span>
            </div>
          )}
        </div>
      </div>
    </Link>
  );
}
