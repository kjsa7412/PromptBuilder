'use client';

import { Suspense, useState, useEffect, useRef, useCallback } from 'react';
import Link from 'next/link';
import { useSearchParams } from 'next/navigation';
import PromptCard from '@/components/PromptCard';
import { api } from '@/lib/api';
import type { PromptCard as PromptCardType } from '@/lib/api';

const POPULAR_TAGS = ['업무', '일상', '창작', '교육', 'GPT', 'Claude', '글쓰기', '코딩', '번역', '요약', '마케팅'];
const PAGE_SIZE = 20;

function FilterSidebar({
  sort, setSort,
  tag, setTag,
  author, setAuthor,
  total,
}: {
  sort: string; setSort: (v: string) => void;
  tag: string; setTag: (v: string) => void;
  author: string; setAuthor: (v: string) => void;
  total: number;
}) {
  return (
    <aside className="w-full lg:w-56 flex-shrink-0 space-y-6">
      {/* Sort */}
      <div>
        <p className="text-xs font-semibold text-gray-400 dark:text-white/30 uppercase tracking-wider mb-3">정렬</p>
        <div className="space-y-1">
          {[{ v: 'new', l: '최신순' }, { v: 'trending', l: '인기순' }, { v: 'random', l: '랜덤' }].map(({ v, l }) => (
            <button
              key={v}
              onClick={() => setSort(v)}
              className={`w-full text-left px-3 py-2 rounded-lg text-sm transition-all ${
                sort === v
                  ? 'bg-violet-500/15 text-violet-600 dark:text-violet-300 font-medium'
                  : 'text-gray-600 dark:text-white/50 hover:bg-gray-100 dark:hover:bg-white/5'
              }`}
            >
              {l}
            </button>
          ))}
        </div>
      </div>

      {/* Category tags */}
      <div>
        <p className="text-xs font-semibold text-gray-400 dark:text-white/30 uppercase tracking-wider mb-3">카테고리 · 태그</p>
        <div className="flex flex-wrap gap-1.5">
          {POPULAR_TAGS.map((t) => (
            <button
              key={t}
              onClick={() => setTag(tag === t ? '' : t)}
              className={`px-2.5 py-1 text-xs rounded-full border transition-all ${
                tag === t
                  ? 'bg-violet-500/20 text-violet-600 dark:text-violet-300 border-violet-500/40'
                  : 'bg-gray-50 dark:bg-white/5 text-gray-500 dark:text-white/40 border-gray-200 dark:border-white/10 hover:border-violet-500/30 hover:text-violet-600 dark:hover:text-violet-300'
              }`}
            >
              #{t}
            </button>
          ))}
        </div>
      </div>

      {/* Author */}
      <div>
        <p className="text-xs font-semibold text-gray-400 dark:text-white/30 uppercase tracking-wider mb-3">작성자</p>
        <input
          type="text"
          value={author}
          onChange={(e) => setAuthor(e.target.value)}
          placeholder="작성자 이름..."
          className="input-base text-sm py-2"
        />
      </div>

      {/* Stats */}
      <div className="pt-4 border-t border-gray-100 dark:border-white/5">
        <p className="text-xs text-gray-400 dark:text-white/25">총 <span className="text-gray-600 dark:text-white/50 font-semibold">{total.toLocaleString()}</span>개</p>
      </div>
    </aside>
  );
}

function ExploreContent() {
  const searchParams = useSearchParams();
  const [prompts, setPrompts] = useState<PromptCardType[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [page, setPage] = useState(0);
  const [hasMore, setHasMore] = useState(true);
  const [sidebarOpen, setSidebarOpen] = useState(false);

  const [q, setQ] = useState(searchParams.get('q') || '');
  const [tag, setTag] = useState(searchParams.get('tag') || '');
  const [author, setAuthor] = useState(searchParams.get('author') || '');
  const [sort, setSort] = useState(searchParams.get('sort') || 'new');

  const sentinelRef = useRef<HTMLDivElement>(null);
  const loadingMoreRef = useRef(false);

  // Reset and search on filter change
  useEffect(() => {
    const load = async () => {
      setLoading(true);
      setPage(0);
      setHasMore(true);
      try {
        const res = await api.search({ q, tag, author, sort, page: 0, size: PAGE_SIZE });
        setPrompts(res.data || []);
        setTotal(res.meta?.total || 0);
        if ((res.data || []).length < PAGE_SIZE) setHasMore(false);
      } catch {
        setPrompts([]);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [q, tag, author, sort]);

  const loadMore = useCallback(async () => {
    if (loadingMoreRef.current || !hasMore || loading) return;
    loadingMoreRef.current = true;
    setLoadingMore(true);
    const nextPage = page + 1;
    try {
      const res = await api.search({ q, tag, author, sort, page: nextPage, size: PAGE_SIZE });
      const more = res.data || [];
      if (more.length > 0) {
        setPrompts(prev => [...prev, ...more]);
        setPage(nextPage);
        if (more.length < PAGE_SIZE) setHasMore(false);
      } else {
        setHasMore(false);
      }
    } catch {}
    loadingMoreRef.current = false;
    setLoadingMore(false);
  }, [q, tag, author, sort, page, hasMore, loading]);

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

  const activeFilters = [
    q && { label: `"${q}"`, clear: () => setQ('') },
    tag && { label: `#${tag}`, clear: () => setTag('') },
    author && { label: `@${author}`, clear: () => setAuthor('') },
  ].filter(Boolean) as { label: string; clear: () => void }[];

  return (
    <div className="flex gap-8">
      {/* Sidebar desktop */}
      <div className="hidden lg:block">
        <FilterSidebar sort={sort} setSort={setSort} tag={tag} setTag={setTag} author={author} setAuthor={setAuthor} total={total} />
      </div>

      {/* Main */}
      <div className="flex-1 min-w-0 space-y-5">
        {/* Search + mobile filter toggle */}
        <div className="flex gap-3">
          <div className="relative flex-1">
            <svg className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 dark:text-white/30" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 111 11a6 6 0 0116 0z" />
            </svg>
            <input
              type="text"
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder="제목, 설명 검색..."
              className="w-full bg-gray-50 dark:bg-white/[0.04] border border-gray-200 dark:border-white/10 rounded-xl pl-10 pr-4 py-3 text-sm text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-zinc-500 focus:outline-none focus:ring-2 focus:ring-violet-500/40 focus:border-violet-500/40 transition-all"
            />
          </div>
          {/* Mobile filter button */}
          <button
            onClick={() => setSidebarOpen(!sidebarOpen)}
            className="lg:hidden flex items-center gap-2 px-4 py-2.5 rounded-xl border border-gray-200 dark:border-white/10 bg-gray-50 dark:bg-white/5 text-sm text-gray-600 dark:text-white/60 hover:bg-gray-100 dark:hover:bg-white/10 transition-all"
          >
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M3 4h18M7 8h10M11 12h2" />
            </svg>
            필터
          </button>
        </div>

        {/* Mobile sidebar */}
        {sidebarOpen && (
          <div className="lg:hidden p-4 rounded-2xl border border-gray-200 dark:border-white/10 bg-gray-50 dark:bg-white/[0.03]">
            <FilterSidebar sort={sort} setSort={setSort} tag={tag} setTag={setTag} author={author} setAuthor={setAuthor} total={total} />
          </div>
        )}

        {/* Active filter chips */}
        {activeFilters.length > 0 && (
          <div className="flex items-center gap-2 flex-wrap">
            <span className="text-xs text-gray-400 dark:text-white/30">필터:</span>
            {activeFilters.map((f) => (
              <button
                key={f.label}
                onClick={f.clear}
                className="flex items-center gap-1 px-2.5 py-1 text-xs rounded-full bg-violet-500/15 text-violet-600 dark:text-violet-300 border border-violet-500/25 hover:bg-violet-500/25 transition-all"
              >
                {f.label}
                <svg className="w-3 h-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            ))}
            <button
              onClick={() => { setQ(''); setTag(''); setAuthor(''); }}
              className="text-xs text-gray-400 dark:text-white/25 hover:text-gray-600 dark:hover:text-white/50 transition-colors"
            >
              전체 초기화
            </button>
          </div>
        )}

        {/* Results */}
        {loading ? (
          <div className="card-grid">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="h-44 rounded-2xl skeleton" />
            ))}
          </div>
        ) : prompts.length === 0 ? (
          <div className="text-center py-24 rounded-2xl border border-gray-100 dark:border-white/[0.06] bg-gray-50 dark:bg-white/[0.02]">
            <p className="text-3xl mb-3">🔍</p>
            <p className="text-gray-600 dark:text-zinc-400 font-medium text-sm">검색 결과가 없습니다</p>
            <p className="text-gray-400 dark:text-zinc-500 text-xs mt-1.5">다른 검색어나 태그를 시도해보세요</p>
          </div>
        ) : (
          <div className="card-grid">
            {prompts.map((p, i) => <PromptCard key={`${p.id}-${i}`} prompt={p} />)}
          </div>
        )}

        <div ref={sentinelRef} className="h-2" />
        {loadingMore && (
          <div className="flex justify-center py-6">
            <div className="w-4 h-4 border-2 border-violet-500/30 border-t-violet-500 rounded-full animate-spin" />
          </div>
        )}
        {!hasMore && prompts.length > 0 && !loading && !loadingMore && (
          <p className="text-center text-[11px] text-gray-300 dark:text-white/15 py-4">모든 결과를 확인했습니다</p>
        )}
      </div>
    </div>
  );
}

export default function ExplorePage() {
  return (
    <div className="bg-white dark:bg-[#0a0a0f] min-h-screen">
      <div className="relative py-12 px-4 sm:px-6 overflow-hidden">
        <div className="absolute inset-0 dot-grid opacity-40" />
        <div className="absolute inset-0 bg-gradient-to-b from-transparent to-white dark:to-[#0a0a0f]" />
        <div className="max-w-[1729px] mx-auto relative z-10 flex items-center justify-between gap-4">
          <div>
            <h1 className="text-3xl font-extrabold text-gray-900 dark:text-white mb-2 tracking-tight">프롬프트 탐색</h1>
            <p className="text-gray-400 dark:text-zinc-500 text-sm">커뮤니티가 공유한 최고의 AI 프롬프트를 찾아보세요</p>
          </div>
          <Link
            href="/me/prompts/new"
            className="flex-shrink-0 flex items-center gap-2 px-4 py-2.5 text-sm font-medium rounded-xl bg-gradient-to-r from-violet-600 to-pink-600 text-white hover:opacity-90 transition-all shadow-md shadow-violet-500/20"
          >
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
            </svg>
            <span className="hidden sm:inline">새 프롬프트</span>
          </Link>
        </div>
      </div>

      <div className="max-w-[1729px] mx-auto px-4 sm:px-6 pb-24">
        <Suspense fallback={
          <div className="card-grid">
            {[...Array(6)].map((_, i) => <div key={i} className="h-44 rounded-2xl skeleton" />)}
          </div>
        }>
          <ExploreContent />
        </Suspense>
      </div>
    </div>
  );
}
