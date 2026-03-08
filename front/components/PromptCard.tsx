'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import type { PromptCard as PromptCardType } from '@/lib/api';

interface Props {
  prompt: PromptCardType;
  hrefOverride?: string;
}

// Determine category class from tags
function getCategoryClass(tags?: string[]): { border: string; shadow: string; badge: string; label: string } {
  if (!tags || tags.length === 0) return { border: 'border-l-violet-500/50', shadow: 'default-shadow', badge: 'bg-violet-500/10 text-violet-600 dark:text-violet-300', label: '' };
  const t = tags.join(' ').toLowerCase();
  if (t.includes('업무') || t.includes('회의') || t.includes('이메일') || t.includes('보고') || t.includes('개발'))
    return { border: 'border-l-blue-500', shadow: 'cat-work-shadow', badge: 'bg-blue-500/10 text-blue-600 dark:text-blue-300', label: '업무' };
  if (t.includes('일상') || t.includes('생활') || t.includes('식단') || t.includes('가계') || t.includes('주말'))
    return { border: 'border-l-emerald-500', shadow: 'cat-daily-shadow', badge: 'bg-emerald-500/10 text-emerald-600 dark:text-emerald-300', label: '일상' };
  if (t.includes('창작') || t.includes('글쓰기') || t.includes('소설') || t.includes('마케팅') || t.includes('카피'))
    return { border: 'border-l-amber-500', shadow: 'cat-creative-shadow', badge: 'bg-amber-500/10 text-amber-600 dark:text-amber-300', label: '창작' };
  if (t.includes('교육') || t.includes('학습') || t.includes('공부') || t.includes('gpt') || t.includes('claude'))
    return { border: 'border-l-purple-500', shadow: 'cat-edu-shadow', badge: 'bg-purple-500/10 text-purple-600 dark:text-purple-300', label: '학습' };
  return { border: 'border-l-violet-500/50', shadow: 'default-shadow', badge: 'bg-violet-500/10 text-violet-600 dark:text-violet-300', label: '' };
}

export default function PromptCard({ prompt, hrefOverride }: Props) {
  const router = useRouter();
  const cat = getCategoryClass(prompt.tags);
  const varCount = prompt.variableCount ?? 0;
  const templatePreview = prompt.firstTemplateBody
    ? prompt.firstTemplateBody.slice(0, 80) + (prompt.firstTemplateBody.length > 80 ? '…' : '')
    : null;

  return (
    <Link href={hrefOverride ? `/p/${hrefOverride}` : `/p/${prompt.id}`}>
      <div className={`group relative flex flex-col gap-3 p-5 rounded-2xl bg-[var(--bg-card)] border border-[var(--border)] border-l-4 ${cat.border} ${cat.shadow} hover:-translate-y-1.5 transition-all duration-250 cursor-pointer h-full`}>

        {/* Top row: category + variable count */}
        <div className="flex items-center justify-between gap-2">
          <div className="flex items-center gap-1.5">
            {cat.label && (
              <span className={`text-[10px] font-semibold px-2 py-0.5 rounded-full ${cat.badge}`}>
                {cat.label}
              </span>
            )}
            {prompt.tags && prompt.tags.filter(t => t !== cat.label).slice(0, 2).map((tag) => (
              <span
                key={tag}
                onClick={(e) => { e.preventDefault(); e.stopPropagation(); router.push(`/explore?tag=${encodeURIComponent(tag)}`); }}
                className="text-[10px] px-2 py-0.5 rounded-full bg-gray-100 dark:bg-white/8 text-gray-500 dark:text-white/40 hover:bg-violet-500/15 hover:text-violet-600 dark:hover:text-violet-300 cursor-pointer transition-colors"
              >
                #{tag}
              </span>
            ))}
          </div>
          {varCount > 0 && (
            <span className="text-[10px] text-violet-500 dark:text-violet-400 font-mono bg-violet-500/8 px-2 py-0.5 rounded-full flex-shrink-0">
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
          <div className="rounded-lg bg-gray-50 dark:bg-black/20 border border-gray-100 dark:border-white/5 px-3 py-2">
            <p className="text-[11px] font-mono text-gray-400 dark:text-white/30 line-clamp-2 leading-relaxed">
              {templatePreview}
            </p>
          </div>
        ) : prompt.description ? (
          <p className="text-xs text-gray-500 dark:text-white/40 line-clamp-2 leading-relaxed flex-1">
            {prompt.description}
          </p>
        ) : null}

        {/* Stats + author */}
        <div className="flex items-center justify-between pt-2 border-t border-gray-100 dark:border-white/5 mt-auto">
          <div className="flex items-center gap-3 text-[11px] text-gray-400 dark:text-white/30">
            <span className="flex items-center gap-1">
              <svg className="w-3 h-3" viewBox="0 0 24 24" fill="currentColor"><path d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"/></svg>
              {prompt.likeCount ?? 0}
            </span>
            <span className="flex items-center gap-1">
              <svg className="w-3 h-3" viewBox="0 0 24 24" fill="currentColor"><path d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"/></svg>
              {prompt.clipCount ?? prompt.bookmarkCount ?? 0}
            </span>
            <span className="flex items-center gap-1">
              <svg className="w-3 h-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path strokeLinecap="round" strokeLinejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
              {prompt.generateCount ?? 0}
            </span>
          </div>

          {prompt.authorName && (
            <div className="flex items-center gap-1.5">
              {prompt.authorAvatar ? (
                <img src={prompt.authorAvatar} alt={prompt.authorName} className="w-4 h-4 rounded-full object-cover ring-1 ring-gray-200 dark:ring-white/10" />
              ) : (
                <div className="w-4 h-4 rounded-full bg-gradient-to-br from-violet-400 to-pink-400 flex items-center justify-center text-white text-[8px] font-bold flex-shrink-0">
                  {prompt.authorName.charAt(0).toUpperCase()}
                </div>
              )}
              <span className="text-[11px] text-gray-400 dark:text-white/25 truncate max-w-[80px]">{prompt.authorName}</span>
            </div>
          )}
        </div>
      </div>
    </Link>
  );
}
