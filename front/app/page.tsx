export const dynamic = 'force-dynamic';

import Link from 'next/link';
import HomeTabSection from '@/components/HomeTabSection';
import { api } from '@/lib/api';

const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

async function getData() {
  try {
    const [trendingRes, randomRes, newRes, statsRes] = await Promise.allSettled([
      api.getTrending(9),
      api.getRandom(9),
      api.getNew(9),
      fetch(`${API_BASE}/api/public/stats`, { cache: 'no-store' }).then((r) => r.json()),
    ]);

    return {
      trending: trendingRes.status === 'fulfilled' ? (trendingRes.value.data || []) : [],
      random: randomRes.status === 'fulfilled' ? (randomRes.value.data || []) : [],
      newPrompts: newRes.status === 'fulfilled' ? (newRes.value.data || []) : [],
      totalPrompts:
        statsRes.status === 'fulfilled' ? (statsRes.value?.data?.totalPrompts ?? 0) : 0,
    };
  } catch {
    return { trending: [], random: [], newPrompts: [], totalPrompts: 0 };
  }
}

export default async function HomePage() {
  const { trending, random, newPrompts, totalPrompts } = await getData();

  return (
    <div className="bg-white dark:bg-[#0a0a0f]">
      {/* Hero Section */}
      <section className="relative min-h-[90vh] flex items-center justify-center overflow-hidden">
        <div className="absolute inset-0">
          <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-violet-400/10 dark:bg-violet-600/20 rounded-full blur-3xl" />
          <div className="absolute top-1/3 right-1/4 w-80 h-80 bg-pink-400/10 dark:bg-pink-600/20 rounded-full blur-3xl" />
          <div className="absolute bottom-1/4 left-1/2 w-72 h-72 bg-blue-400/10 dark:bg-blue-600/20 rounded-full blur-3xl" />
        </div>

        <div className="absolute inset-0 opacity-[0.03]" style={{
          backgroundImage: `linear-gradient(rgba(0,0,0,0.3) 1px, transparent 1px), linear-gradient(90deg, rgba(0,0,0,0.3) 1px, transparent 1px)`,
          backgroundSize: '60px 60px'
        }} />

        <div className="relative z-10 text-center px-6 max-w-4xl mx-auto animate-fade-in-up">
          <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-gray-100 dark:bg-white/10 border border-gray-200 dark:border-white/20 text-gray-600 dark:text-white/80 text-sm mb-8">
            <span className="w-2 h-2 rounded-full bg-green-400 animate-pulse" />
            AI 프롬프트 허브
          </div>

          <h1 className="text-5xl md:text-7xl font-bold text-gray-900 dark:text-white mb-6 leading-tight">
            최고의 프롬프트를
            <br />
            <span className="bg-gradient-to-r from-violet-400 via-pink-400 to-blue-400 bg-clip-text text-transparent">
              만들고 공유하세요
            </span>
          </h1>

          <p className="text-xl text-gray-500 dark:text-white/50 mb-10 max-w-2xl mx-auto leading-relaxed">
            변수 템플릿으로 완성도 높은 AI 프롬프트를 쉽게 만들고,
            <br className="hidden md:block" />
            커뮤니티와 함께 성장하세요
          </p>

          <div className="flex items-center justify-center gap-4 flex-wrap">
            <Link
              href="/explore"
              className="px-8 py-3.5 rounded-xl bg-gradient-to-r from-violet-600 to-pink-600 text-white font-semibold hover:opacity-90 transition-all hover:scale-105 shadow-lg shadow-violet-500/25"
            >
              프롬프트 탐색하기
            </Link>
            <Link
              href="/me/prompts/new"
              className="px-8 py-3.5 rounded-xl bg-gray-100 dark:bg-white/10 border border-gray-200 dark:border-white/20 text-gray-700 dark:text-white font-semibold hover:bg-gray-200 dark:hover:bg-white/20 transition-all"
            >
              프롬프트 만들기
            </Link>
          </div>

          {/* Stats */}
          <div className="flex items-center justify-center gap-8 mt-16 text-gray-400 dark:text-white/30 text-sm">
            <div className="flex flex-col items-center gap-1">
              <span className="text-2xl font-bold text-violet-500 dark:text-violet-400">
                {totalPrompts > 0 ? `${totalPrompts.toLocaleString()}+` : '∞'}
              </span>
              <span>공개 프롬프트</span>
            </div>
            <div className="w-px h-8 bg-gray-200 dark:bg-white/10" />
            <div className="flex flex-col items-center gap-1">
              <span className="text-2xl font-bold text-gray-500 dark:text-white/60">{'{{변수}}'}</span>
              <span>템플릿 변수</span>
            </div>
            <div className="w-px h-8 bg-gray-200 dark:bg-white/10" />
            <div className="flex flex-col items-center gap-1">
              <span className="text-2xl font-bold text-gray-500 dark:text-white/60">1-click</span>
              <span>즉시 복사</span>
            </div>
          </div>
        </div>

        <div className="absolute bottom-8 left-1/2 -translate-x-1/2 flex flex-col items-center gap-2 text-gray-400 dark:text-white/30">
          <span className="text-xs">스크롤</span>
          <div className="w-px h-8 bg-gradient-to-b from-gray-300 dark:from-white/30 to-transparent" />
        </div>
      </section>

      {/* Tab Sections */}
      <div className="max-w-7xl mx-auto px-6 py-24">
        <HomeTabSection trending={trending} random={random} newPrompts={newPrompts} />
      </div>
    </div>
  );
}
