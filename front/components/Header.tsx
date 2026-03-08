'use client';

import Link from 'next/link';
import { useEffect, useState, useRef } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { useTheme } from 'next-themes';
import { supabase } from '@/lib/supabase';
import type { Session } from '@supabase/supabase-js';

const CAT_NAV = [
  { label: '탐색', href: '/explore' },
  { label: '업무', href: '/explore?tag=업무' },
  { label: '일상', href: '/explore?tag=일상' },
  { label: '창작', href: '/explore?tag=창작' },
];

export default function Header() {
  const [session, setSession] = useState<Session | null>(null);
  const [mounted, setMounted] = useState(false);
  const [profileName, setProfileName] = useState<string | null>(null);
  const [avatarUrl, setAvatarUrl] = useState<string | null>(null);
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const { theme, setTheme } = useTheme();
  const router = useRouter();
  const pathname = usePathname();
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    setMounted(true);
    supabase.auth.getSession().then(({ data }) => {
      setSession(data.session);
      const s = data.session;
      if (s?.access_token) {
        fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080'}/api/me/profile`, {
          headers: { Authorization: `Bearer ${s.access_token}` }
        }).then(r => r.ok ? r.json() : null)
          .then(json => {
            if (json?.data) {
              const name = json.data.display_name || json.data.displayName || json.data.username;
              if (name) setProfileName(name);
              if (json.data.avatar_url || json.data.avatarUrl) {
                setAvatarUrl(json.data.avatar_url || json.data.avatarUrl);
              }
            }
          }).catch(() => {});
      }
    });
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, s) => {
      setSession(s);
      if (!s) {
        setProfileName(null);
        setAvatarUrl(null);
        if (pathname?.startsWith('/me/')) router.push('/login');
      }
    });
    return () => subscription.unsubscribe();
  }, []);

  // Close dropdown on outside click
  useEffect(() => {
    const handler = (e: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setDropdownOpen(false);
      }
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  const handleSignOut = async () => {
    await supabase.auth.signOut();
    setDropdownOpen(false);
    router.push('/');
    router.refresh();
  };

  return (
    <header className="sticky top-0 z-50 bg-white/85 dark:bg-[#0a0a0f]/85 backdrop-blur-xl border-b border-gray-100 dark:border-white/[0.06] transition-colors duration-300">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 h-14 flex items-center justify-between gap-4">

        {/* Logo */}
        <Link href="/" className="text-lg font-bold bg-gradient-to-r from-violet-500 to-pink-500 bg-clip-text text-transparent flex-shrink-0">
          PromptClip
        </Link>

        {/* Center: Category nav (desktop) */}
        <nav className="hidden md:flex items-center gap-1">
          {CAT_NAV.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className="px-3 py-1.5 text-sm text-gray-500 dark:text-white/50 hover:text-gray-900 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-white/8 rounded-lg transition-all"
            >
              {item.label}
            </Link>
          ))}
        </nav>

        {/* Right actions */}
        <div className="flex items-center gap-2">
          {/* Search icon → explore */}
          <Link
            href="/explore"
            className="p-2 rounded-lg text-gray-500 dark:text-white/50 hover:text-gray-900 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-white/8 transition-all"
            aria-label="검색"
          >
            <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 111 11a6 6 0 0116 0z" />
            </svg>
          </Link>

          {/* Theme toggle */}
          {mounted && (
            <button
              onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
              className="p-2 rounded-lg text-gray-500 dark:text-white/50 hover:text-gray-900 dark:hover:text-white hover:bg-gray-100 dark:hover:bg-white/8 transition-all"
              aria-label="테마 전환"
            >
              {theme === 'dark' ? (
                <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364-6.364l-.707.707M6.343 17.657l-.707.707M17.657 17.657l-.707-.707M6.343 6.343l-.707-.707" />
                </svg>
              ) : (
                <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
                </svg>
              )}
            </button>
          )}

          {/* Auth */}
          {session ? (
            <div className="relative" ref={dropdownRef}>
              <button
                onClick={() => setDropdownOpen((v) => !v)}
                className="flex items-center gap-2 px-3 py-1.5 rounded-lg hover:bg-gray-100 dark:hover:bg-white/8 transition-all"
              >
                {avatarUrl ? (
                  <img src={avatarUrl} alt={profileName || ''} className="w-6 h-6 rounded-full object-cover ring-1 ring-gray-200 dark:ring-white/10" />
                ) : (
                  <div className="w-6 h-6 rounded-full bg-gradient-to-br from-violet-500 to-pink-500 flex items-center justify-center text-white text-[10px] font-bold">
                    {(profileName || 'U').charAt(0).toUpperCase()}
                  </div>
                )}
                <span className="hidden sm:block text-sm text-gray-700 dark:text-white/80 max-w-[80px] truncate">
                  {profileName || '나'}
                </span>
                <svg className="w-3 h-3 text-gray-400 dark:text-white/30" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                  <path strokeLinecap="round" strokeLinejoin="round" d="M19 9l-7 7-7-7" />
                </svg>
              </button>

              {dropdownOpen && (
                <div className="absolute right-0 top-full mt-1.5 w-44 bg-white dark:bg-[#1a1a2e] border border-gray-200 dark:border-white/10 rounded-xl shadow-xl overflow-hidden z-50">
                  <Link
                    href="/me/library"
                    onClick={() => setDropdownOpen(false)}
                    className="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 dark:text-white/80 hover:bg-gray-50 dark:hover:bg-white/5 transition-colors"
                  >
                    <svg className="w-4 h-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}><path strokeLinecap="round" strokeLinejoin="round" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z"/></svg>
                    내 라이브러리
                  </Link>
                  <Link
                    href="/me/prompts/new"
                    onClick={() => setDropdownOpen(false)}
                    className="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 dark:text-white/80 hover:bg-gray-50 dark:hover:bg-white/5 transition-colors"
                  >
                    <svg className="w-4 h-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}><path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4"/></svg>
                    새 프롬프트
                  </Link>
                  <Link
                    href="/me/profile"
                    onClick={() => setDropdownOpen(false)}
                    className="flex items-center gap-2 px-4 py-2.5 text-sm text-gray-700 dark:text-white/80 hover:bg-gray-50 dark:hover:bg-white/5 transition-colors"
                  >
                    <svg className="w-4 h-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}><path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z"/></svg>
                    프로필 설정
                  </Link>
                  <div className="border-t border-gray-100 dark:border-white/5 mt-1" />
                  <button
                    onClick={handleSignOut}
                    className="w-full flex items-center gap-2 px-4 py-2.5 text-sm text-red-500 hover:bg-red-50 dark:hover:bg-red-500/10 transition-colors"
                  >
                    <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.5}><path strokeLinecap="round" strokeLinejoin="round" d="M15.75 9V5.25A2.25 2.25 0 0013.5 3h-6a2.25 2.25 0 00-2.25 2.25v13.5A2.25 2.25 0 007.5 21h6a2.25 2.25 0 002.25-2.25V15M12 9l-3 3m0 0l3 3m-3-3h12.75"/></svg>
                    로그아웃
                  </button>
                </div>
              )}
            </div>
          ) : (
            <Link
              href="/login"
              className="px-4 py-1.5 text-sm bg-gradient-to-r from-violet-600 to-pink-600 text-white rounded-lg hover:opacity-90 transition-all font-medium"
            >
              로그인
            </Link>
          )}
        </div>
      </div>
    </header>
  );
}
