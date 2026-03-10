export const dynamic = 'force-dynamic';

import Link from 'next/link';
import HomeSections from '@/components/HomeSections';
import { api } from '@/lib/api';

const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

const POPULAR_SEARCHES = ['회의록 정리', '마케팅 이메일', '코드 리뷰', '일상 답장', '할 일 정리'];

async function getData() {
  try {
    const [trendingRes, randomRes, newRes, statsRes] = await Promise.allSettled([
      api.getTrending(4, 0),
      api.getRandom(4),
      api.getNew(4, 0),
      fetch(`${API_BASE}/api/public/stats`, { cache: 'no-store' }).then((r) => r.json()),
    ]);
    return {
      trending: trendingRes.status === 'fulfilled' ? (trendingRes.value.data || []) : [],
      random: randomRes.status === 'fulfilled' ? (randomRes.value.data || []) : [],
      newPrompts: newRes.status === 'fulfilled' ? (newRes.value.data || []) : [],
      totalPrompts: statsRes.status === 'fulfilled' ? (statsRes.value?.data?.totalPrompts ?? 0) : 0,
    };
  } catch {
    return { trending: [], random: [], newPrompts: [], totalPrompts: 0 };
  }
}

export default async function HomePage() {
  const { trending, random, newPrompts, totalPrompts } = await getData();

  return (
    <div className="bg-white dark:bg-[#0a0a0f]">
      {/* Hero */}
      <section className="relative overflow-hidden min-h-[88vh] flex items-center justify-center noise-bg">
        {/* Dot grid background */}
        <div className="absolute inset-0 dot-grid opacity-60" />
        {/* Gradient fade edges */}
        <div className="absolute inset-0 bg-gradient-to-b from-white/60 via-transparent to-white/80 dark:from-[#0a0a0f]/80 dark:via-transparent dark:to-[#0a0a0f]" />

        <div className="relative z-10 text-center px-6 max-w-3xl mx-auto animate-fade-in-up">
          {/* Badge */}
          <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-full bg-violet-500/10 border border-violet-500/20 text-violet-600 dark:text-violet-300 text-xs font-medium mb-8">
            <span className="w-1.5 h-1.5 rounded-full bg-violet-400 animate-pulse" />
            AI 프롬프트 커뮤니티
          </div>

          {/* Headline */}
          <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight text-gray-900 dark:text-white mb-5 leading-[1.1]">
            더 나은 AI 답변을
            <br />
            <span className="gradient-text">프롬프트로 시작하세요</span>
          </h1>

          <p className="text-lg text-gray-500 dark:text-white/45 mb-10 max-w-xl mx-auto leading-relaxed">
            검증된 프롬프트 템플릿으로 ChatGPT·Claude를 더 스마트하게 활용하세요
          </p>

          {/* Search bar */}
          <div className="relative max-w-lg mx-auto mb-4">
            <div className="flex items-center bg-white dark:bg-[#16161f] border border-gray-200 dark:border-white/10 rounded-2xl shadow-lg shadow-violet-500/5 overflow-hidden focus-within:ring-2 focus-within:ring-violet-500/30 focus-within:border-violet-500/30 transition-all">
              <svg className="w-4 h-4 text-gray-400 dark:text-white/30 ml-4 flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 111 11a6 6 0 0116 0z" />
              </svg>
              <Link href="/explore" className="flex-1 px-3 py-3.5 text-sm text-gray-400 dark:text-white/30 text-left">
                프롬프트 검색...
              </Link>
              <Link
                href="/explore"
                className="m-1.5 px-4 py-2 bg-gradient-to-r from-violet-600 to-pink-600 text-white text-sm font-medium rounded-xl hover:opacity-90 transition-all flex-shrink-0"
              >
                탐색
              </Link>
            </div>
          </div>

          {/* Make your own CTA */}
          <div className="flex items-center justify-center mb-5">
            <Link
              href="/me/prompts/new"
              className="inline-flex items-center gap-2 px-5 py-2.5 text-sm font-medium rounded-xl border border-violet-500/30 bg-violet-500/5 text-violet-600 dark:text-violet-300 hover:bg-violet-500/15 hover:border-violet-500/50 transition-all"
            >
              <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
              </svg>
              나도 프롬프트 만들기
            </Link>
          </div>

          {/* Popular searches */}
          <div className="flex items-center justify-center gap-2 flex-wrap">
            <span className="text-xs text-gray-400 dark:text-white/25">인기:</span>
            {POPULAR_SEARCHES.map((s) => (
              <Link
                key={s}
                href={`/explore?q=${encodeURIComponent(s)}`}
                className="text-xs px-2.5 py-1 rounded-full bg-gray-100 dark:bg-white/5 text-gray-500 dark:text-white/40 border border-gray-200 dark:border-white/8 hover:bg-violet-500/10 hover:text-violet-600 dark:hover:text-violet-300 hover:border-violet-500/20 transition-all"
              >
                {s}
              </Link>
            ))}
          </div>
        </div>

        {/* Stats strip */}
        <div className="absolute bottom-8 left-0 right-0 flex items-center justify-center gap-8 text-sm">
          <div className="flex flex-col items-center gap-0.5">
            <span className="text-xl font-bold text-violet-500 dark:text-violet-400">
              {totalPrompts > 0 ? `${totalPrompts.toLocaleString()}+` : '∞'}
            </span>
            <span className="text-xs text-gray-400 dark:text-white/30">공개 프롬프트</span>
          </div>
          <div className="w-px h-8 bg-gray-200 dark:bg-white/8" />
          <div className="flex flex-col items-center gap-0.5">
            <span className="text-xl font-bold text-gray-700 dark:text-white/60 font-mono">{'{{변수}}'}</span>
            <span className="text-xs text-gray-400 dark:text-white/30">템플릿 변수</span>
          </div>
          <div className="w-px h-8 bg-gray-200 dark:bg-white/8" />
          <div className="flex flex-col items-center gap-0.5">
            <span className="text-xl font-bold text-gray-700 dark:text-white/60">1-click</span>
            <span className="text-xs text-gray-400 dark:text-white/30">즉시 복사</span>
          </div>
        </div>
      </section>

      {/* Content sections */}
      <div className="max-w-[1729px] mx-auto px-4 sm:px-6 py-20">
        <HomeSections trending={trending} random={random} newPrompts={newPrompts} />
      </div>
    </div>
  );
}
