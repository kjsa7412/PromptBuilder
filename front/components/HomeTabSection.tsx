'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import PromptCard from './PromptCard';
import type { PromptCard as PromptCardType } from '@/lib/api';

const PAGE_SIZE = 12;
const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

type TabKey = 'trending' | 'random' | 'new';

interface Props {
  trending: PromptCardType[];
  random: PromptCardType[];
  newPrompts: PromptCardType[];
}

const TABS = [
  { key: 'trending' as const, label: '🔥 주간 인기', subtitle: '커뮤니티에서 가장 많이 사용되는 프롬프트' },
  { key: 'random' as const, label: '🎲 랜덤 발견', subtitle: '새로운 영감을 찾아보세요' },
  { key: 'new' as const, label: '✨ 신규 프롬프트', subtitle: '최신 등록 프롬프트' },
];

async function fetchMore(tab: TabKey, offset: number): Promise<PromptCardType[]> {
  const endpoint =
    tab === 'trending'
      ? `/api/public/prompts/trending?limit=${PAGE_SIZE}&offset=${offset}`
      : tab === 'new'
      ? `/api/public/prompts/new?limit=${PAGE_SIZE}&offset=${offset}`
      : `/api/public/prompts/random?limit=${PAGE_SIZE}`;

  try {
    const res = await fetch(`${API_BASE}${endpoint}`);
    if (!res.ok) return [];
    const json = await res.json();
    return json.data || [];
  } catch {
    return [];
  }
}

export default function HomeTabSection({ trending, random, newPrompts }: Props) {
  const [activeTab, setActiveTab] = useState<TabKey>('trending');

  const [items, setItems] = useState<Record<TabKey, PromptCardType[]>>({
    trending,
    random,
    new: newPrompts,
  });
  const [offsets, setOffsets] = useState<Record<TabKey, number>>({
    trending: PAGE_SIZE,
    random: PAGE_SIZE,
    new: PAGE_SIZE,
  });
  const [hasMore, setHasMore] = useState<Record<TabKey, boolean>>({
    trending: trending.length >= PAGE_SIZE,
    random: true,
    new: newPrompts.length >= PAGE_SIZE,
  });
  const [loading, setLoading] = useState(false);

  const sentinelRef = useRef<HTMLDivElement | null>(null);
  const loadingRef = useRef(false);

  const loadMore = useCallback(async () => {
    if (loadingRef.current || !hasMore[activeTab]) return;
    loadingRef.current = true;
    setLoading(true);

    const offset = offsets[activeTab];
    const more = await fetchMore(activeTab, offset);

    if (more.length > 0) {
      setItems((prev) => ({ ...prev, [activeTab]: [...prev[activeTab], ...more] }));
      setOffsets((prev) => ({ ...prev, [activeTab]: offset + PAGE_SIZE }));
      if (more.length < PAGE_SIZE) {
        setHasMore((prev) => ({ ...prev, [activeTab]: false }));
      }
    } else {
      setHasMore((prev) => ({ ...prev, [activeTab]: false }));
    }

    loadingRef.current = false;
    setLoading(false);
  }, [activeTab, hasMore, offsets]);

  useEffect(() => {
    const el = sentinelRef.current;
    if (!el) return;
    const observer = new IntersectionObserver(
      (entries) => { if (entries[0].isIntersecting) loadMore(); },
      { rootMargin: '300px' }
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, [loadMore]);

  const current = items[activeTab];
  const activeInfo = TABS.find((t) => t.key === activeTab)!;

  return (
    <div>
      <div className="flex items-center gap-1 mb-8 p-1 bg-gray-100 dark:bg-white/5 rounded-xl w-fit">
        {TABS.map((tab) => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key)}
            className={`px-5 py-2 rounded-lg text-sm font-medium transition-all ${
              activeTab === tab.key
                ? 'bg-white dark:bg-white/20 text-gray-900 dark:text-white shadow-sm'
                : 'text-gray-500 dark:text-white/50 hover:text-gray-700 dark:hover:text-white/70'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <p className="text-gray-400 dark:text-white/40 text-sm mb-6">{activeInfo.subtitle}</p>

      {current.length === 0 ? (
        <div className="text-center py-16 rounded-2xl border border-gray-200 dark:border-white/5 bg-gray-50 dark:bg-white/[0.02]">
          <p className="text-gray-400 dark:text-white/30 text-sm">아직 프롬프트가 없습니다</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {current.map((p, i) => (
            <PromptCard key={`${p.id}-${i}`} prompt={p} />
          ))}
        </div>
      )}

      {/* 하단 감지용 sentinel */}
      <div ref={sentinelRef} className="h-4" />

      {loading && (
        <div className="flex justify-center py-8">
          <div className="flex items-center gap-2 text-gray-400 dark:text-white/30 text-sm">
            <div className="w-4 h-4 border-2 border-violet-500/40 border-t-violet-500 rounded-full animate-spin" />
            불러오는 중...
          </div>
        </div>
      )}

      {!hasMore[activeTab] && current.length > 0 && !loading && (
        <p className="text-center text-gray-300 dark:text-white/20 text-xs py-8">
          모든 프롬프트를 확인했습니다
        </p>
      )}
    </div>
  );
}
