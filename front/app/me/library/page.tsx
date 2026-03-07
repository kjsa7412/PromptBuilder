'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import PromptCard from '@/components/PromptCard';
import { api } from '@/lib/api';
import { supabase } from '@/lib/supabase';
import type { PromptCard as PromptCardType } from '@/lib/api';

type Tab = 'my' | 'clips';

export default function LibraryPage() {
  const router = useRouter();
  const [tab, setTab] = useState<Tab>('my');
  const [myPrompts, setMyPrompts] = useState<PromptCardType[]>([]);
  const [clips, setClips] = useState<PromptCardType[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      const { data } = await supabase.auth.getSession();
      if (!data.session) {
        router.push('/login');
        return;
      }
      const t = data.session.access_token;
      try {
        const [myRes, clipRes] = await Promise.all([
          fetch(
            `${process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080'}/api/me/prompts`,
            { headers: { Authorization: `Bearer ${t}` } }
          ).then((r) => r.json()),
          api.getClips(t),
        ]);
        setMyPrompts(myRes.data || []);
        setClips(clipRes.data || []);
      } catch {
        setMyPrompts([]);
        setClips([]);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [router]);

  const items = tab === 'my' ? myPrompts : clips;

  return (
    <div className="bg-white dark:bg-[#0a0a0f] min-h-screen">
      {/* Header */}
      <div className="relative py-16 px-6 overflow-hidden">
        <div className="absolute top-0 right-1/3 w-96 h-48 bg-pink-400/10 dark:bg-pink-600/10 rounded-full blur-3xl" />
        <div className="max-w-7xl mx-auto relative z-10 flex items-center justify-between">
          <div>
            <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-2">내 라이브러리</h1>
            <p className="text-gray-400 dark:text-white/40">내 프롬프트와 클립을 관리하세요</p>
          </div>
          <Link
            href="/me/prompts/new"
            className="px-6 py-2.5 rounded-xl bg-gradient-to-r from-violet-600 to-pink-600 text-white font-medium hover:opacity-90 transition-all text-sm"
          >
            + 새 프롬프트
          </Link>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-6 pb-24">
        {/* Tabs - Glass pill style */}
        <div className="inline-flex p-1 rounded-xl bg-gray-100 dark:bg-white/5 border border-gray-200 dark:border-white/10 mb-8">
          <button
            onClick={() => setTab('my')}
            className={`px-5 py-2 text-sm font-medium rounded-lg transition-all ${
              tab === 'my'
                ? 'bg-violet-600/40 text-violet-600 dark:text-violet-200 border border-violet-500/30'
                : 'text-gray-500 dark:text-white/50 hover:text-gray-900 dark:hover:text-white'
            }`}
          >
            내 프롬프트 {!loading && <span className="ml-1 text-xs opacity-60">({myPrompts.length})</span>}
          </button>
          <button
            onClick={() => setTab('clips')}
            className={`px-5 py-2 text-sm font-medium rounded-lg transition-all ${
              tab === 'clips'
                ? 'bg-violet-600/40 text-violet-600 dark:text-violet-200 border border-violet-500/30'
                : 'text-gray-500 dark:text-white/50 hover:text-gray-900 dark:hover:text-white'
            }`}
          >
            클립 {!loading && <span className="ml-1 text-xs opacity-60">({clips.length})</span>}
          </button>
        </div>

        {loading ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="h-48 rounded-2xl bg-gray-100 dark:bg-white/5 border border-gray-200 dark:border-white/10 animate-pulse" />
            ))}
          </div>
        ) : items.length === 0 ? (
          <div className="text-center py-24 rounded-2xl border border-gray-200 dark:border-white/5 bg-gray-50 dark:bg-white/2">
            {tab === 'my' ? (
              <>
                <p className="text-5xl mb-4">&#9997;</p>
                <p className="text-gray-500 dark:text-white/60 font-medium mb-2">아직 작성한 프롬프트가 없습니다</p>
                <p className="text-gray-400 dark:text-white/30 text-sm mb-6">첫 번째 프롬프트를 만들어보세요</p>
                <Link
                  href="/me/prompts/new"
                  className="inline-block px-6 py-2.5 rounded-xl bg-gradient-to-r from-violet-600 to-pink-600 text-white font-medium hover:opacity-90 transition-all text-sm"
                >
                  새 프롬프트 작성하기
                </Link>
              </>
            ) : (
              <>
                <p className="text-5xl mb-4">&#9733;</p>
                <p className="text-gray-500 dark:text-white/60 font-medium mb-2">아직 클립한 프롬프트가 없습니다</p>
                <p className="text-gray-400 dark:text-white/30 text-sm mb-6">마음에 드는 프롬프트를 클립해보세요</p>
                <Link
                  href="/explore"
                  className="inline-block px-6 py-2.5 rounded-xl bg-gray-100 dark:bg-white/10 border border-gray-200 dark:border-white/20 text-gray-700 dark:text-white font-medium hover:bg-gray-200 dark:hover:bg-white/20 transition-all text-sm"
                >
                  프롬프트 탐색하기
                </Link>
              </>
            )}
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            {items.map((p) => (
              <PromptCard key={p.id} prompt={p} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
