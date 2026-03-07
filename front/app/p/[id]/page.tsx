export const dynamic = 'force-dynamic';

import { api } from '@/lib/api';
import PromptDetailClient from '@/components/PromptDetailClient';
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
    <div className="bg-white dark:bg-[#0a0a0f] min-h-screen">
      <div className="max-w-7xl mx-auto px-6 py-12">
        <PromptDetailClient prompt={prompt} />
      </div>
    </div>
  );
}
