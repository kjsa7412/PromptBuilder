'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

const NAV_ITEMS = [
  {
    href: '/',
    label: '홈',
    icon: (active: boolean) => (
      <svg className="w-5 h-5" fill={active ? 'currentColor' : 'none'} viewBox="0 0 24 24" stroke="currentColor" strokeWidth={active ? 0 : 1.8}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
      </svg>
    ),
  },
  {
    href: '/explore',
    label: '탐색',
    icon: (active: boolean) => (
      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={active ? 2.2 : 1.8}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 111 11a6 6 0 0116 0z" />
      </svg>
    ),
  },
  // index 2 = center slot (rendered separately)
  {
    href: '/me/library',
    label: '라이브러리',
    icon: (active: boolean) => (
      <svg className="w-5 h-5" fill={active ? 'currentColor' : 'none'} viewBox="0 0 24 24" stroke="currentColor" strokeWidth={active ? 0 : 1.8}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
      </svg>
    ),
  },
  {
    href: '/me/profile',
    label: '프로필',
    icon: (active: boolean) => (
      <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={active ? 2.2 : 1.8}>
        <path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z" />
      </svg>
    ),
  },
];

export default function MobileBottomNav() {
  const pathname = usePathname();
  const [newHref, setNewHref] = useState('/login');

  // Only the "새 프롬프트" center button needs auth state — static hrefs elsewhere
  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setNewHref(data.session ? '/me/prompts/new' : '/login');
    });
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_e, s) => {
      setNewHref(s ? '/me/prompts/new' : '/login');
    });
    return () => subscription.unsubscribe();
  }, []);

  return (
    <nav className="md:hidden fixed bottom-0 left-0 right-0 z-50 bg-white/90 dark:bg-[#0a0a0f]/90 backdrop-blur-xl border-t border-gray-100 dark:border-white/[0.08] bottom-nav-safe">
      <div className="flex items-end">
        {/* 홈, 탐색 */}
        {NAV_ITEMS.slice(0, 2).map((item) => {
          const active = pathname === item.href || (item.href !== '/' && pathname?.startsWith(item.href));
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex-1 flex flex-col items-center justify-center gap-0.5 py-2.5 transition-colors ${
                active ? 'text-violet-600 dark:text-violet-400' : 'text-gray-400 dark:text-white/35 hover:text-gray-600 dark:hover:text-white/60'
              }`}
            >
              {item.icon(active)}
              <span className="text-[10px] font-medium">{item.label}</span>
            </Link>
          );
        })}

        {/* Center: 새 프롬프트 raised button */}
        <div className="flex-1 flex flex-col items-center justify-end pb-2.5">
          <Link
            href={newHref}
            aria-label="새 프롬프트"
            className="w-12 h-12 -mt-5 rounded-full bg-gradient-to-br from-violet-600 to-pink-600 shadow-lg shadow-violet-500/40 flex items-center justify-center text-white hover:opacity-90 active:scale-95 transition-all"
          >
            <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
            </svg>
          </Link>
          <span className="text-[10px] font-medium mt-0.5 text-violet-500 dark:text-violet-400">만들기</span>
        </div>

        {/* 라이브러리, 프로필 — always static hrefs, pages handle auth redirect */}
        {NAV_ITEMS.slice(2).map((item) => {
          const active = pathname?.startsWith(item.href.split('?')[0]);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex-1 flex flex-col items-center justify-center gap-0.5 py-2.5 transition-colors ${
                active ? 'text-violet-600 dark:text-violet-400' : 'text-gray-400 dark:text-white/35 hover:text-gray-600 dark:hover:text-white/60'
              }`}
            >
              {item.icon(!!active)}
              <span className="text-[10px] font-medium">{item.label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
