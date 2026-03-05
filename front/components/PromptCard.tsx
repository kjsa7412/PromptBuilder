import Link from 'next/link';
import type { PromptCard as PromptCardType } from '@/lib/api';

interface Props {
  prompt: PromptCardType;
}

export default function PromptCard({ prompt }: Props) {
  const excerpt = prompt.description
    ? prompt.description.slice(0, 100) + (prompt.description.length > 100 ? '...' : '')
    : '';

  return (
    <Link href={`/p/${prompt.id}`}>
      <div className="bg-white rounded-xl border hover:shadow-md transition-shadow p-5 h-full flex flex-col gap-3 cursor-pointer">
        <h3 className="font-semibold text-gray-900 line-clamp-2">{prompt.title}</h3>

        {excerpt && (
          <p className="text-sm text-gray-500 line-clamp-3 flex-1">{excerpt}</p>
        )}

        {prompt.tags && prompt.tags.length > 0 && (
          <div className="flex flex-wrap gap-1">
            {prompt.tags.slice(0, 3).map((tag) => (
              <span
                key={tag}
                className="text-xs bg-indigo-50 text-indigo-600 px-2 py-0.5 rounded-full"
              >
                {tag}
              </span>
            ))}
          </div>
        )}

        <div className="flex items-center gap-3 text-xs text-gray-400 pt-1 border-t">
          <span>북마크 {prompt.bookmarkCount ?? 0}</span>
          <span>좋아요 {prompt.likeCount ?? 0}</span>
          <span>사용 {prompt.generateCount ?? 0}</span>
        </div>
      </div>
    </Link>
  );
}
