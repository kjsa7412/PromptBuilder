'use client';

import { useState, useEffect, useCallback, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/api';
import type { PromptCard as PromptCardType } from '@/lib/api';
import HomeTallCard from './HomeTallCard';

type TagItem = { tag: string; count: number };
type SelectedTag = 'all' | 'popular' | 'new' | string;

const PAGE_SIZE = 20;
const ELLIPSIS_W = 48; // "…" 버튼 너비 + 여백
const GAP = 6;         // 태그 간격

const FIXED_TAGS: { key: SelectedTag; label: string }[] = [
  { key: 'all', label: 'all' },
  { key: 'popular', label: '인기' },
  { key: 'new', label: '신규' },
];

export default function HomeTagFeed() {
  const router = useRouter();
  const [tags, setTags] = useState<TagItem[]>([]);
  const [selected, setSelected] = useState<SelectedTag>('all');
  const [prompts, setPrompts] = useState<PromptCardType[]>([]);
  const [page, setPage] = useState(0);
  const [hasMore, setHasMore] = useState(true);
  const [initialLoading, setInitialLoading] = useState(true);
  const [transitioning, setTransitioning] = useState(false);
  const [loadingMore, setLoadingMore] = useState(false);
  // null = 모두 표시, number = 표시할 태그 수
  const [visibleCount, setVisibleCount] = useState<number | null>(null);

  const loadingMoreRef = useRef(false);
  const sentinelRef = useRef<HTMLDivElement>(null);
  const requestIdRef = useRef(0);

  // 측정 전용 레이어 (invisible) — 항상 전체 태그를 렌더해서 너비를 잼
  const measureRef = useRef<HTMLDivElement>(null);
  // 컨테이너 (실제 표시 영역)
  const containerRef = useRef<HTMLDivElement>(null);

  // 모든 태그 아이템 (fixed + dynamic)
  const allItems = [
    ...FIXED_TAGS.map(t => ({ key: t.key, label: t.label, extra: '' })),
    ...tags.map(t => ({ key: t.tag, label: t.tag, extra: `(${t.count})` })),
  ];

  // 너비 측정 후 visibleCount 결정
  const measure = useCallback(() => {
    const container = containerRef.current;
    const measureEl = measureRef.current;
    if (!container || !measureEl) return;

    const containerWidth = container.clientWidth;
    const btns = Array.from(measureEl.querySelectorAll<HTMLElement>('[data-m]'));
    if (btns.length === 0) return;

    let total = 0;
    let count = 0;
    for (const btn of btns) {
      const w = btn.getBoundingClientRect().width + GAP;
      // "…" 공간을 미리 확보하면서 맞는지 확인
      if (total + w + ELLIPSIS_W > containerWidth) break;
      total += w;
      count++;
    }

    setVisibleCount(count >= btns.length ? null : count);
  }, []);

  // 태그 로드 후 측정
  useEffect(() => {
    const id = requestAnimationFrame(measure);
    return () => cancelAnimationFrame(id);
  }, [tags, measure]);

  // 리사이즈 시 재측정
  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;
    const ro = new ResizeObserver(() => requestAnimationFrame(measure));
    ro.observe(el);
    return () => ro.disconnect();
  }, [measure]);

  // 태그 목록 로드
  useEffect(() => {
    api.getTags().then(res => setTags(res?.data || [])).catch(() => setTags([]));
  }, []);

  const fetchPage = useCallback(async (sel: SelectedTag, pg: number) => {
    const sort = sel === 'popular' ? 'trending' : 'new';
    const tag = (sel === 'all' || sel === 'popular' || sel === 'new') ? undefined : sel;
    const res = await api.search({ tag, sort, page: pg, size: PAGE_SIZE });
    return res?.data || [];
  }, []);

  // 태그 변경: 기존 카드 dimming → 교체
  useEffect(() => {
    const reqId = ++requestIdRef.current;
    setPage(0);
    setHasMore(true);
    loadingMoreRef.current = false;

    if (prompts.length > 0) setTransitioning(true);
    else setInitialLoading(true);

    fetchPage(selected, 0).then(data => {
      if (reqId !== requestIdRef.current) return;
      setPrompts(data);
      setHasMore(data.length === PAGE_SIZE);
      setInitialLoading(false);
      setTransitioning(false);
    }).catch(() => {
      if (reqId !== requestIdRef.current) return;
      setInitialLoading(false);
      setTransitioning(false);
    });
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selected, fetchPage]);

  // 인피니티 스크롤
  const loadMore = useCallback(() => {
    if (loadingMoreRef.current || !hasMore) return;
    loadingMoreRef.current = true;
    const nextPage = page + 1;
    setPage(nextPage);
    setLoadingMore(true);

    fetchPage(selected, nextPage).then(data => {
      setPrompts(prev => [...prev, ...data]);
      setHasMore(data.length === PAGE_SIZE);
    }).catch(() => setHasMore(false))
      .finally(() => { setLoadingMore(false); loadingMoreRef.current = false; });
  }, [page, hasMore, selected, fetchPage]);

  useEffect(() => {
    const el = sentinelRef.current;
    if (!el) return;
    const obs = new IntersectionObserver(
      entries => { if (entries[0].isIntersecting) loadMore(); },
      { rootMargin: '300px' }
    );
    obs.observe(el);
    return () => obs.disconnect();
  }, [loadMore]);

  const displayCount = visibleCount ?? allItems.length;
  const hasEllipsis = visibleCount !== null;

  return (
    <div>
      {/* 태그 바 */}
      <div className="sticky top-0 z-30 bg-white/90 dark:bg-[#0a0a0f]/90 backdrop-blur-md border-b border-gray-100 dark:border-white/[0.06]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6">
          {/* 측정 전용 레이어 — invisible, absolute, 전체 태그 항상 렌더 */}
          <div
            ref={measureRef}
            className="absolute flex items-center gap-1.5 py-2.5 pointer-events-none"
            style={{ visibility: 'hidden', left: 0, right: 0, overflow: 'hidden' }}
            aria-hidden="true"
          >
            {allItems.map(item => (
              <button
                key={item.key}
                data-m
                tabIndex={-1}
                className="px-3 py-1 rounded-full text-sm whitespace-nowrap flex-shrink-0 bg-gray-100"
              >
                {item.label}
                {item.extra && <span className="ml-1 text-xs opacity-60">{item.extra}</span>}
              </button>
            ))}
          </div>

          {/* 실제 표시 레이어 */}
          <div ref={containerRef} className="flex items-center gap-1.5 py-2.5 overflow-hidden">
            {allItems.slice(0, displayCount).map(item => (
              <button
                key={item.key}
                onClick={() => setSelected(item.key)}
                className={`px-3 py-1 rounded-full text-sm whitespace-nowrap transition-all flex-shrink-0 ${
                  selected === item.key
                    ? 'bg-violet-600 text-white font-medium shadow-sm'
                    : 'bg-gray-100 dark:bg-white/10 text-gray-600 dark:text-white/60 hover:bg-gray-200 dark:hover:bg-white/20'
                }`}
              >
                {item.label}
                {item.extra && <span className="ml-1 text-xs opacity-60">{item.extra}</span>}
              </button>
            ))}

            {hasEllipsis && (
              <button
                onClick={() => router.push('/explore')}
                className="px-3 py-1 rounded-full text-sm whitespace-nowrap flex-shrink-0 bg-gray-100 dark:bg-white/10 text-gray-600 dark:text-white/60 hover:bg-gray-200 dark:hover:bg-white/20 transition-all font-semibold"
                aria-label="전체 태그 보기"
              >
                …
              </button>
            )}
          </div>
        </div>
      </div>

      {/* 게시물 피드 */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-6">
        {initialLoading ? (
          <div className="flex justify-center py-20">
            <div className="w-6 h-6 border-2 border-violet-500 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : prompts.length === 0 ? (
          <div className="text-center py-20 text-gray-400 dark:text-white/30 text-sm">
            게시물이 없습니다.
          </div>
        ) : (
          <div className={`grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5 transition-opacity duration-200 ${
            transitioning ? 'opacity-40 pointer-events-none' : 'opacity-100'
          }`}>
            {prompts.map(p => <HomeTallCard key={p.id} prompt={p} />)}
          </div>
        )}

        <div ref={sentinelRef} className="h-4" />

        {loadingMore && (
          <div className="flex justify-center py-6">
            <div className="w-5 h-5 border-2 border-violet-500 border-t-transparent rounded-full animate-spin" />
          </div>
        )}

        {!hasMore && prompts.length > 0 && !transitioning && (
          <p className="text-center text-xs text-gray-400 dark:text-white/25 py-6">
            모든 게시물을 확인했습니다
          </p>
        )}
      </div>
    </div>
  );
}
