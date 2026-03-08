export const dynamic = 'force-dynamic';

import { api } from '@/lib/api';
import PromptDetailClient from '@/components/PromptDetailClient';
import PrivatePromptClient from '@/components/PrivatePromptClient';
import type { Metadata } from 'next';
import type { PromptDetail } from '@/lib/api';

interface Props {
  params: { id: string };
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  try {
    const res = await api.getDetail(params.id);
    const p = res.data;
    const title = `${p.title} - PromptClip`;
    const description = p.description || `${p.title}에 대한 AI 프롬프트 템플릿`;
    const tags = p.tags || [];
    const url = `https://www.promptclip.com/p/${params.id}`;

    return {
      title: p.title,
      description,
      keywords: tags,
      alternates: { canonical: url },
      openGraph: {
        type: 'article',
        title,
        description,
        url,
        siteName: 'PromptClip',
        locale: 'ko_KR',
        tags,
      },
      twitter: {
        card: 'summary',
        title,
        description,
      },
    };
  } catch {
    return { title: 'PromptClip' };
  }
}

export default async function PromptDetailPage({ params }: Props) {
  let prompt: PromptDetail | null = null;
  try {
    const res = await api.getDetail(params.id);
    prompt = res.data;
  } catch {
    // public API failed — may be private or draft; let client retry with auth
  }

  // Public post: render with server-fetched data (SEO friendly)
  if (prompt) {
    const jsonLd = {
      '@context': 'https://schema.org',
      '@type': 'CreativeWork',
      name: prompt.title,
      description: prompt.description,
      keywords: prompt.tags?.join(', '),
      url: `https://www.promptclip.com/p/${params.id}`,
    };

    return (
      <div className="bg-white dark:bg-[#0a0a0f] min-h-screen">
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
        <div className="max-w-7xl mx-auto px-6 py-12">
          <PromptDetailClient prompt={prompt} />
        </div>
      </div>
    );
  }

  // Private / draft post: client component fetches with auth token
  return <PrivatePromptClient promptId={params.id} />;
}
