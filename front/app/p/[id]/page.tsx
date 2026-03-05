export const dynamic = 'force-dynamic';

import { api } from '@/lib/api';
import PromptBuilder from '@/components/PromptBuilder';
import type { Metadata } from 'next';
import { notFound } from 'next/navigation';

interface Props {
  params: { id: string };
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  try {
    const res = await api.getDetail(params.id);
    return { title: `${res.data.title} - PromptClip` };
  } catch {
    return { title: 'PromptClip' };
  }
}

export default async function PromptDetailPage({ params }: Props) {
  let prompt;
  try {
    const res = await api.getDetail(params.id);
    prompt = res.data;
  } catch {
    notFound();
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-10">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* 좌: 설명 */}
        <div className="space-y-4">
          <h1 className="text-2xl font-bold text-gray-900">{prompt.title}</h1>

          {prompt.tags && prompt.tags.length > 0 && (
            <div className="flex flex-wrap gap-1">
              {prompt.tags.map((tag: string) => (
                <span
                  key={tag}
                  className="text-xs bg-indigo-50 text-indigo-600 px-2 py-0.5 rounded-full"
                >
                  {tag}
                </span>
              ))}
            </div>
          )}

          {prompt.description && (
            <div className="prose prose-sm text-gray-600 max-w-none">
              <p>{prompt.description}</p>
            </div>
          )}

          <div className="flex gap-4 text-sm text-gray-400">
            <span>북마크 {prompt.bookmarkCount ?? 0}</span>
            <span>좋아요 {prompt.likeCount ?? 0}</span>
            <span>사용 {prompt.generateCount ?? 0}</span>
          </div>
        </div>

        {/* 우: Prompt Builder */}
        <div className="bg-white rounded-xl border p-6">
          <h2 className="text-lg font-bold text-gray-900 mb-4">Prompt Builder</h2>
          <PromptBuilder
            promptId={prompt.id}
            templateBody={prompt.templateBody || ''}
            variables={prompt.variables || []}
          />
        </div>
      </div>
    </div>
  );
}
