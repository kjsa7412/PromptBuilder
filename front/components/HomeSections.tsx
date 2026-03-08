import Link from 'next/link';
import HomeTallCard from './HomeTallCard';
import type { PromptCard as PromptCardType } from '@/lib/api';

const MAX_CARDS = 4;

interface Props {
  trending: PromptCardType[];
  random: PromptCardType[];
  newPrompts: PromptCardType[];
}

function SectionHeader({ title, subtitle, href }: { title: string; subtitle: string; href: string }) {
  return (
    <div className="flex items-end justify-between mb-5">
      <div>
        <h2 className="text-lg font-bold text-gray-900 dark:text-white">{title}</h2>
        <p className="text-xs text-gray-400 dark:text-zinc-500 mt-0.5">{subtitle}</p>
      </div>
      <Link
        href={href}
        className="text-xs text-violet-500 dark:text-violet-400 hover:text-violet-700 dark:hover:text-violet-300 font-medium flex items-center gap-0.5 transition-colors shrink-0"
      >
        모두 보기
        <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </Link>
    </div>
  );
}

function CardGrid({ items }: { items: PromptCardType[] }) {
  if (items.length === 0) {
    return (
      <div className="text-center py-10 rounded-2xl border border-gray-100 dark:border-white/[0.06] bg-gray-50 dark:bg-white/[0.02]">
        <p className="text-gray-400 dark:text-zinc-500 text-sm">아직 프롬프트가 없습니다</p>
      </div>
    );
  }
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-5">
      {items.slice(0, MAX_CARDS).map((p, i) => (
        <HomeTallCard key={`${p.id}-${i}`} prompt={p} />
      ))}
    </div>
  );
}

export default function HomeSections({ trending, random, newPrompts }: Props) {
  return (
    <div className="space-y-16">
      <section>
        <SectionHeader
          title="🔥 이번 주 인기"
          subtitle="커뮤니티에서 가장 많이 사용되는 프롬프트"
          href="/explore?sort=trending"
        />
        <CardGrid items={trending} />
      </section>

      <section>
        <SectionHeader
          title="✨ 신규 프롬프트"
          subtitle="막 등록된 따끈따끈한 프롬프트"
          href="/explore?sort=new"
        />
        <CardGrid items={newPrompts} />
      </section>

      <section>
        <SectionHeader
          title="🎲 랜덤 발견"
          subtitle="예상치 못한 유용한 프롬프트를 만나보세요"
          href="/explore?sort=random"
        />
        <CardGrid items={random} />
      </section>
    </div>
  );
}
