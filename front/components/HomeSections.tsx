'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import Link from 'next/link';
import PromptCard from './PromptCard';
import type { PromptCard as PromptCardType } from '@/lib/api';

const PAGE_SIZE = 12;
const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

interface Props {
  trending: PromptCardType[];
  random: PromptCardType[];
  newPrompts: PromptCardType[];
}

function SectionHeader({ title, subtitle, href }: { title: string; subtitle: string; href: string }) {
  return (
    <div className="flex items-end justify-between mb-6">
      <div>
        <h2 className="text-xl font-bold text-gray-900 dark:text-white">{title}</h2>
        <p className="text-sm text-gray-400 dark:text-white/35 mt-0.5">{subtitle}</p>
      </div>
      <Link
        href={href}
        className="text-sm text-violet-500 dark:text-violet-400 hover:text-violet-700 dark:hover:text-violet-300 font-medium flex items-center gap-1 transition-colors"
      >
        모두 보기
        <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
          <path strokeLinecap="round" strokeLinejoin="round" d="M9 5l7 7-7 7" />
        </svg>
      </Link>
    </div>
  );
}

function CardGrid({ items }: { items: PromptCardType[] }) {
  if (items.length === 0) {
    return (
      <div className="text-center py-12 rounded-2xl border border-gray-100 dark:border-white/5 bg-gray-50 dark:bg-white/[0.02]">
        <p className="text-gray-400 dark:text-white/30 text-sm">아직 프롬프트가 없습니다</p>
      </div>
    );
  }
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      {items.map((p, i) => <PromptCard key={`${p.id}-${i}`} prompt={p} />)}
    </div>
  );
}

async function fetchMore(type: 'trending' | 'new' | 'random', offset: number): Promise<PromptCardType[]> {
  const url = type === 'trending'
    ? `${API_BASE}/api/public/prompts/trending?limit=${PAGE_SIZE}&offset=${offset}`
    : type === 'new'
    ? `${API_BASE}/api/public/prompts/new?limit=${PAGE_SIZE}&offset=${offset}`
    : `${API_BASE}/api/public/prompts/random?limit=${PAGE_SIZE}`;
  try {
    const res = await fetch(url);
    if (!res.ok) return [];
    const json = await res.json();
    return json.data || [];
  } catch { return []; }
}

function InfiniteSection({
  type, title, subtitle, href, initial,
}: {
  type: 'trending' | 'new' | 'random';
  title: string;
  subtitle: string;
  href: string;
  initial: PromptCardType[];
}) {
  const [items, setItems] = useState(initial);
  const [offset, setOffset] = useState(PAGE_SIZE);
  const [hasMore, setHasMore] = useState(initial.length >= PAGE_SIZE);
  const [loading, setLoading] = useState(false);
  const sentinelRef = useRef<HTMLDivElement>(null);
  const loadingRef = useRef(false);

  const loadMore = useCallback(async () => {
    if (loadingRef.current || !hasMore) return;
    loadingRef.current = true;
    setLoading(true);
    const more = await fetchMore(type, offset);
    if (more.length > 0) {
      setItems(prev => [...prev, ...more]);
      setOffset(prev => prev + PAGE_SIZE);
      if (more.length < PAGE_SIZE) setHasMore(false);
    } else {
      setHasMore(false);
    }
    loadingRef.current = false;
    setLoading(false);
  }, [type, offset, hasMore]);

  useEffect(() => {
    const el = sentinelRef.current;
    if (!el) return;
    const observer = new IntersectionObserver(
      entries => { if (entries[0].isIntersecting) loadMore(); },
      { rootMargin: '300px' }
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, [loadMore]);

  return (
    <section>
      <SectionHeader title={title} subtitle={subtitle} href={href} />
      <CardGrid items={items} />
      <div ref={sentinelRef} className="h-2" />
      {loading && (
        <div className="flex justify-center py-6">
          <div className="w-4 h-4 border-2 border-violet-500/30 border-t-violet-500 rounded-full animate-spin" />
        </div>
      )}
      {!hasMore && items.length > 0 && !loading && (
        <p className="text-center text-[11px] text-gray-300 dark:text-white/15 py-6">
          모든 프롬프트를 확인했습니다
        </p>
      )}
    </section>
  );
}

export default function HomeSections({ trending, random, newPrompts }: Props) {
  return (
    <div className="space-y-20">
      <InfiniteSection
        type="trending"
        title="🔥 이번 주 인기"
        subtitle="커뮤니티에서 가장 많이 사용되는 프롬프트"
        href="/explore?sort=trending"
        initial={trending}
      />
      <InfiniteSection
        type="new"
        title="✨ 신규 프롬프트"
        subtitle="막 등록된 따끈따끈한 프롬프트"
        href="/explore?sort=new"
        initial={newPrompts}
      />
      <InfiniteSection
        type="random"
        title="🎲 랜덤 발견"
        subtitle="예상치 못한 유용한 프롬프트를 만나보세요"
        href="/explore?sort=random"
        initial={random}
      />
    </div>
  );
}
