'use client';

import { Suspense, useState, useEffect } from 'react';
import { useSearchParams } from 'next/navigation';
import PromptCard from '@/components/PromptCard';
import { api } from '@/lib/api';
import type { PromptCard as PromptCardType } from '@/lib/api';

const POPULAR_TAGS = ['GPT', 'Claude', '글쓰기', '코딩', '번역', '요약', '마케팅', '교육'];

function ExploreContent() {
  const searchParams = useSearchParams();
  const [prompts, setPrompts] = useState<PromptCardType[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [q, setQ] = useState(searchParams.get('q') || '');
  const [tag, setTag] = useState(searchParams.get('tag') || '');
  const [sort, setSort] = useState(searchParams.get('sort') || 'new');

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      try {
        const res = await api.search({ q, tag, sort });
        setPrompts(res.data || []);
        setTotal(res.meta?.total || 0);
      } catch {
        setPrompts([]);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [q, tag, sort]);

  return (
    <div className="space-y-8">
      {/* Search bar */}
      <div className="flex flex-col sm:flex-row gap-3">
        <div className="relative flex-1">
          <span className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 dark:text-white/30 text-sm">
            ⌕
          </span>
          <input
            type="text"
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="제목, 태그 검색..."
            className="w-full bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl pl-10 pr-4 py-3 text-sm text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-violet-500/50 focus:border-violet-500/50 transition-all"
          />
        </div>
        <input
          type="text"
          value={tag}
          onChange={(e) => setTag(e.target.value)}
          placeholder="태그 필터..."
          className="w-40 bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-sm text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-violet-500/50 focus:border-violet-500/50 transition-all"
        />
        <select
          value={sort}
          onChange={(e) => setSort(e.target.value)}
          className="bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-sm text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-500/50 focus:border-violet-500/50 transition-all"
        >
          <option value="new" className="bg-white dark:bg-[#1a1a2e]">최신순</option>
          <option value="trending" className="bg-white dark:bg-[#1a1a2e]">인기순</option>
          <option value="random" className="bg-white dark:bg-[#1a1a2e]">랜덤</option>
        </select>
      </div>

      {/* Popular tags */}
      <div className="flex flex-wrap gap-2">
        <span className="text-xs text-gray-400 dark:text-white/30 self-center mr-1">인기 태그:</span>
        {POPULAR_TAGS.map((t) => (
          <button
            key={t}
            onClick={() => setTag(tag === t ? '' : t)}
            className={`px-3 py-1 text-xs rounded-full border transition-all ${
              tag === t
                ? 'bg-violet-500/30 text-violet-600 dark:text-violet-300 border-violet-500/50'
                : 'bg-gray-100 dark:bg-white/5 text-gray-500 dark:text-white/50 border-gray-200 dark:border-white/10 hover:bg-gray-200 dark:hover:bg-white/10 hover:text-gray-900 dark:hover:text-white'
            }`}
          >
            #{t}
          </button>
        ))}
      </div>

      <div className="flex items-center justify-between">
        <p className="text-sm text-gray-400 dark:text-white/30">총 {total}개의 프롬프트</p>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {[...Array(6)].map((_, i) => (
            <div
              key={i}
              className="h-48 rounded-2xl bg-gray-100 dark:bg-white/5 border border-gray-200 dark:border-white/10 animate-pulse"
            />
          ))}
        </div>
      ) : prompts.length === 0 ? (
        <div className="text-center py-24 rounded-2xl border border-gray-200 dark:border-white/5 bg-gray-50 dark:bg-white/2">
          <p className="text-4xl mb-4">&#128269;</p>
          <p className="text-gray-500 dark:text-white/50 font-medium">검색 결과가 없습니다</p>
          <p className="text-gray-400 dark:text-white/30 text-sm mt-2">다른 검색어나 태그를 시도해보세요</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {prompts.map((p) => (
            <PromptCard key={p.id} prompt={p} />
          ))}
        </div>
      )}
    </div>
  );
}

export default function ExplorePage() {
  return (
    <div className="bg-white dark:bg-[#0a0a0f] min-h-screen">
      {/* Header */}
      <div className="relative py-16 px-6 overflow-hidden">
        <div className="absolute top-0 left-1/3 w-96 h-48 bg-violet-400/10 dark:bg-violet-600/10 rounded-full blur-3xl" />
        <div className="max-w-7xl mx-auto relative z-10">
          <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-3">프롬프트 탐색</h1>
          <p className="text-gray-400 dark:text-white/40">커뮤니티가 공유한 최고의 AI 프롬프트를 찾아보세요</p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 pb-24">
        <Suspense fallback={
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="h-48 rounded-2xl bg-gray-100 dark:bg-white/5 border border-gray-200 dark:border-white/10 animate-pulse" />
            ))}
          </div>
        }>
          <ExploreContent />
        </Suspense>
      </div>
    </div>
  );
}
