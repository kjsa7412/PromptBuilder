'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import type { PromptCard as PromptCardType } from '@/lib/api';

interface Props {
  prompt: PromptCardType;
}

type Category = {
  border: string;
  badgeBg: string;
  badgeText: string;
  dot: string;
  label: string;
};

function getCat(tags?: string[]): Category {
  const t = (tags || []).join(' ').toLowerCase();
  if (t.includes('업무') || t.includes('회의') || t.includes('이메일') || t.includes('보고') || t.includes('개발'))
    return { border: 'border-l-blue-400', badgeBg: 'bg-blue-50 dark:bg-blue-500/10', badgeText: 'text-blue-600 dark:text-blue-400', dot: 'bg-blue-400', label: '업무' };
  if (t.includes('일상') || t.includes('생활') || t.includes('식단') || t.includes('가계') || t.includes('주말'))
    return { border: 'border-l-emerald-400', badgeBg: 'bg-emerald-50 dark:bg-emerald-500/10', badgeText: 'text-emerald-600 dark:text-emerald-400', dot: 'bg-emerald-400', label: '일상' };
  if (t.includes('창작') || t.includes('글쓰기') || t.includes('소설') || t.includes('마케팅') || t.includes('카피'))
    return { border: 'border-l-amber-400', badgeBg: 'bg-amber-50 dark:bg-amber-500/10', badgeText: 'text-amber-600 dark:text-amber-400', dot: 'bg-amber-400', label: '창작' };
  if (t.includes('교육') || t.includes('학습') || t.includes('공부') || t.includes('gpt') || t.includes('claude'))
    return { border: 'border-l-purple-400', badgeBg: 'bg-purple-50 dark:bg-purple-500/10', badgeText: 'text-purple-600 dark:text-purple-400', dot: 'bg-purple-400', label: '학습' };
  return { border: 'border-l-violet-400', badgeBg: 'bg-violet-50 dark:bg-violet-500/10', badgeText: 'text-violet-600 dark:text-violet-400', dot: 'bg-violet-400', label: '' };
}

export default function HomeTallCard({ prompt }: Props) {
  const router = useRouter();
  const cat = getCat(prompt.tags);
  const varCount = prompt.variableCount ?? 0;
  const preview = prompt.firstTemplateBody ?? null;
  const otherTags = (prompt.tags || []).filter(t => t !== cat.label).slice(0, 2);

  return (
    <Link href={`/p/${prompt.id}`}>
      <div className={`
        group flex flex-col h-full min-h-[320px] rounded-2xl
        bg-white dark:bg-[#13131a]
        border border-l-4 border-gray-100 dark:border-white/[0.06] ${cat.border}
        hover:border-gray-200 dark:hover:border-white/[0.12]
        hover:-translate-y-1 hover:shadow-lg hover:shadow-black/[0.06] dark:hover:shadow-black/40
        transition-all duration-200 cursor-pointer
      `}>
        <div className="flex flex-col flex-1 p-5 gap-4">

          {/* Category + variable count */}
          <div className="flex items-center justify-between gap-2">
            <div className="flex items-center gap-1.5 flex-wrap">
              {cat.label && (
                <span className={`inline-flex items-center gap-1 text-[11px] font-medium px-2 py-0.5 rounded-md ${cat.badgeBg} ${cat.badgeText}`}>
                  <span className={`w-1 h-1 rounded-full ${cat.dot}`} />
                  {cat.label}
                </span>
              )}
              {otherTags.map(tag => (
                <span
                  key={tag}
                  onClick={e => { e.preventDefault(); e.stopPropagation(); router.push(`/explore?tag=${encodeURIComponent(tag)}`); }}
                  className="text-[11px] px-2 py-0.5 rounded-md bg-gray-50 dark:bg-white/[0.04] text-gray-400 dark:text-white/35 hover:text-violet-600 dark:hover:text-violet-400 cursor-pointer transition-colors"
                >
                  #{tag}
                </span>
              ))}
            </div>
            {varCount > 0 && (
              <span className="text-[10px] font-mono shrink-0 px-1.5 py-0.5 rounded bg-gray-100 dark:bg-white/[0.06] text-gray-400 dark:text-white/35">
                {varCount}개 변수
              </span>
            )}
          </div>

          {/* Title */}
          <h3 className="text-[15px] font-bold text-gray-900 dark:text-white line-clamp-2 leading-snug group-hover:text-violet-600 dark:group-hover:text-violet-400 transition-colors">
            {prompt.title}
          </h3>

          {/* Preview / description */}
          <div className="flex-1 overflow-hidden">
            {preview ? (
              <p className="text-[12px] text-gray-400 dark:text-white/30 line-clamp-6 leading-relaxed whitespace-pre-line">
                {preview}
              </p>
            ) : prompt.description ? (
              <p className="text-[13px] text-gray-500 dark:text-white/35 line-clamp-5 leading-relaxed">
                {prompt.description}
              </p>
            ) : null}
          </div>

          {/* Footer */}
          <div className="flex items-center justify-between pt-3.5 border-t border-gray-100 dark:border-white/[0.05]">
            {prompt.authorName ? (
              <div className="flex items-center gap-1.5 min-w-0">
                {prompt.authorAvatar ? (
                  <img src={prompt.authorAvatar} alt={prompt.authorName} className="w-5 h-5 rounded-full object-cover" />
                ) : (
                  <div className="w-5 h-5 rounded-full bg-gradient-to-br from-violet-400 to-pink-400 flex items-center justify-center text-white text-[8px] font-bold shrink-0">
                    {prompt.authorName.charAt(0).toUpperCase()}
                  </div>
                )}
                <span className="text-[11px] text-gray-400 dark:text-white/30 truncate max-w-[80px]">{prompt.authorName}</span>
              </div>
            ) : <div />}

            <div className="flex items-center gap-3 text-[11px] text-gray-300 dark:text-white/25">
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
          </div>
        </div>
      </div>
    </Link>
  );
}
