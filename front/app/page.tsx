export const dynamic = 'force-dynamic';

import Link from 'next/link';
import PromptCard from '@/components/PromptCard';
import { api } from '@/lib/api';
import type { PromptCard as PromptCardType } from '@/lib/api';

async function getData() {
  try {
    const [trendingRes, randomRes, newRes] = await Promise.allSettled([
      api.getTrending(6),
      api.getRandom(6),
      api.getNew(6),
    ]);

    return {
      trending: trendingRes.status === 'fulfilled' ? (trendingRes.value.data || []) : [],
      random: randomRes.status === 'fulfilled' ? (randomRes.value.data || []) : [],
      newPrompts: newRes.status === 'fulfilled' ? (newRes.value.data || []) : [],
    };
  } catch {
    return { trending: [], random: [], newPrompts: [] };
  }
}

function Section({
  title,
  prompts,
  href,
}: {
  title: string;
  prompts: PromptCardType[];
  href?: string;
}) {
  if (prompts.length === 0) {
    return (
      <section>
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-xl font-bold text-gray-900">{title}</h2>
        </div>
        <p className="text-gray-400 text-sm">표시할 프롬프트가 없습니다 (API 연결 후 표시됩니다)</p>
      </section>
    );
  }

  return (
    <section>
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-xl font-bold text-gray-900">{title}</h2>
        {href && (
          <Link href={href} className="text-sm text-primary hover:underline">
            더 보기
          </Link>
        )}
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {prompts.map((p) => (
          <PromptCard key={p.id} prompt={p} />
        ))}
      </div>
    </section>
  );
}

export default async function HomePage() {
  const { trending, random, newPrompts } = await getData();

  return (
    <div className="max-w-6xl mx-auto px-4 py-10 space-y-16">
      {/* Hero */}
      <section className="text-center space-y-4">
        <h1 className="text-4xl font-extrabold text-gray-900">
          프롬프트를 <span className="text-primary">템플릿</span>으로 저장하고 공유하세요
        </h1>
        <p className="text-lg text-gray-500 max-w-2xl mx-auto">
          변수만 채우면 즉시 복사 가능한 완성 프롬프트를 얻을 수 있습니다.
        </p>
        <div className="flex justify-center gap-4 pt-2">
          <Link
            href="/explore"
            className="px-6 py-3 bg-primary text-white rounded-xl font-semibold hover:bg-indigo-700 transition-colors"
          >
            프롬프트 탐색
          </Link>
          <Link
            href="/me/prompts/new"
            className="px-6 py-3 border border-primary text-primary rounded-xl font-semibold hover:bg-indigo-50 transition-colors"
          >
            프롬프트 만들기
          </Link>
        </div>
      </section>

      {/* 주간 인기 */}
      <Section title="주간 인기" prompts={trending} href="/explore?sort=trending" />

      {/* 랜덤 발견 */}
      <Section title="랜덤 발견" prompts={random} href="/explore?sort=random" />

      {/* 신규 */}
      <Section title="신규" prompts={newPrompts} href="/explore?sort=new" />
    </div>
  );
}
