'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { useTheme } from 'next-themes';
import { supabase } from '@/lib/supabase';
import type { Session } from '@supabase/supabase-js';

export default function Header() {
  const [session, setSession] = useState<Session | null>(null);
  const [mounted, setMounted] = useState(false);
  const { theme, setTheme } = useTheme();

  useEffect(() => {
    setMounted(true);
    supabase.auth.getSession().then(({ data }) => setSession(data.session));
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, s) => {
      setSession(s);
    });
    return () => subscription.unsubscribe();
  }, []);

  const toggleTheme = () => {
    setTheme(theme === 'dark' ? 'light' : 'dark');
  };

  return (
    <header className="sticky top-0 z-50 bg-white/80 dark:bg-black/60 backdrop-blur-xl border-b border-gray-200 dark:border-white/10 transition-colors duration-300">
      <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
        <Link href="/" className="text-xl font-bold bg-gradient-to-r from-violet-500 to-pink-500 bg-clip-text text-transparent">
          PromptClip
        </Link>

        <nav className="flex items-center gap-5 text-sm">
          <Link href="/" className="text-gray-600 dark:text-white/60 hover:text-gray-900 dark:hover:text-white transition-colors">홈</Link>
          <Link href="/explore" className="text-gray-600 dark:text-white/60 hover:text-gray-900 dark:hover:text-white transition-colors">탐색</Link>
          {session && (
            <>
              <Link href="/me/library" className="text-gray-600 dark:text-white/60 hover:text-gray-900 dark:hover:text-white transition-colors">내 라이브러리</Link>
              <Link href="/me/prompts/new" className="text-gray-600 dark:text-white/60 hover:text-gray-900 dark:hover:text-white transition-colors">새 프롬프트</Link>
            </>
          )}

          {/* 테마 토글 */}
          {mounted && (
            <button
              onClick={toggleTheme}
              className="p-2 rounded-lg bg-gray-100 dark:bg-white/10 border border-gray-200 dark:border-white/20 text-gray-600 dark:text-white/70 hover:bg-gray-200 dark:hover:bg-white/20 transition-all"
              aria-label={theme === 'dark' ? '라이트 모드로 전환' : '다크 모드로 전환'}
              title={theme === 'dark' ? '라이트 모드' : '다크 모드'}
            >
              {theme === 'dark' ? (
                <svg xmlns="http://www.w3.org/2000/svg" className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707M17.657 17.657l-.707-.707M6.343 6.343l-.707-.707M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              ) : (
                <svg xmlns="http://www.w3.org/2000/svg" className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                </svg>
              )}
            </button>
          )}

          {session ? (
            <button onClick={() => supabase.auth.signOut()}
              className="px-4 py-1.5 text-sm bg-gray-100 dark:bg-white/10 border border-gray-200 dark:border-white/20 text-gray-700 dark:text-white/80 rounded-lg hover:bg-gray-200 dark:hover:bg-white/20 transition-all">
              로그아웃
            </button>
          ) : (
            <Link href="/login"
              className="px-4 py-1.5 text-sm bg-gradient-to-r from-violet-600 to-pink-600 text-white rounded-lg hover:opacity-90 transition-all font-medium">
              로그인
            </Link>
          )}
        </nav>
      </div>
    </header>
  );
}
