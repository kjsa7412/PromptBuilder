'use client';

import { Suspense, useState, useEffect } from 'react';
import { useSearchParams } from 'next/navigation';
import PromptCard from '@/components/PromptCard';
import { api } from '@/lib/api';
import type { PromptCard as PromptCardType } from '@/lib/api';

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
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row gap-3">
        <input
          type="text"
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder="제목, 태그 검색..."
          className="flex-1 border rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
        />
        <input
          type="text"
          value={tag}
          onChange={(e) => setTag(e.target.value)}
          placeholder="태그..."
          className="w-40 border rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
        />
        <select
          value={sort}
          onChange={(e) => setSort(e.target.value)}
          className="border rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
        >
          <option value="new">최신순</option>
          <option value="trending">인기순</option>
          <option value="random">랜덤</option>
        </select>
      </div>
      <p className="text-sm text-gray-400">총 {total}개</p>
      {loading ? (
        <div className="text-center py-20 text-gray-400">불러오는 중...</div>
      ) : prompts.length === 0 ? (
        <div className="text-center py-20 text-gray-400">
          검색 결과가 없습니다 (API 연결 후 표시됩니다)
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
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
    <div className="max-w-6xl mx-auto px-4 py-10 space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">프롬프트 탐색</h1>
      <Suspense fallback={<div className="text-center py-20 text-gray-400">불러오는 중...</div>}>
        <ExploreContent />
      </Suspense>
    </div>
  );
}
