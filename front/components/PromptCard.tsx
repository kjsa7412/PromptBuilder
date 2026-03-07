'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import type { PromptCard as PromptCardType } from '@/lib/api';

interface Props {
  prompt: PromptCardType;
}

export default function PromptCard({ prompt }: Props) {
  const router = useRouter();
  const excerpt = prompt.description
    ? prompt.description.slice(0, 100) + (prompt.description.length > 100 ? '...' : '')
    : '';

  return (
    <Link href={`/p/${prompt.id}`}>
      <div className="group relative p-6 rounded-2xl bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 hover:bg-gray-100 dark:hover:bg-white/8 hover:border-gray-300 dark:hover:border-white/20 transition-all duration-300 hover:-translate-y-1 hover:shadow-xl hover:shadow-violet-500/10 cursor-pointer h-full flex flex-col gap-3">

        {prompt.tags && prompt.tags.length > 0 && (
          <div className="flex flex-wrap gap-1.5">
            {prompt.tags.slice(0, 3).map((tag) => (
              <span
                key={tag}
                onClick={(e) => {
                  e.preventDefault();
                  e.stopPropagation();
                  router.push(`/explore?tag=${encodeURIComponent(tag)}`);
                }}
                className="px-2 py-0.5 text-xs rounded-full bg-violet-500/20 text-violet-600 dark:text-violet-300 border border-violet-500/30 hover:bg-violet-500/30 cursor-pointer transition-colors"
              >
                #{tag}
              </span>
            ))}
          </div>
        )}

        <h3 className="text-base font-semibold text-gray-900 dark:text-white line-clamp-2 group-hover:text-violet-600 dark:group-hover:text-violet-300 transition-colors flex-1">
          {prompt.title}
        </h3>

        {excerpt && (
          <p className="text-sm text-gray-500 dark:text-white/50 line-clamp-2">{excerpt}</p>
        )}

        <div className="flex items-center justify-between text-xs text-gray-400 dark:text-white/40 pt-2 border-t border-gray-200 dark:border-white/5">
          <div className="flex items-center gap-3">
            <span>&#9829; {prompt.likeCount ?? 0}</span>
            <span>&#128279; {prompt.clipCount ?? prompt.bookmarkCount ?? 0}</span>
            <span>&#9889; {prompt.generateCount ?? 0}</span>
          </div>
        </div>
      </div>
    </Link>
  );
}
