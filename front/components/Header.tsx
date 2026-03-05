'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import type { Session } from '@supabase/supabase-js';

export default function Header() {
  const [session, setSession] = useState<Session | null>(null);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => setSession(data.session));
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, s) => {
      setSession(s);
    });
    return () => subscription.unsubscribe();
  }, []);

  const handleLogout = async () => {
    await supabase.auth.signOut();
  };

  return (
    <header className="bg-white border-b sticky top-0 z-50">
      <div className="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
        <Link href="/" className="text-xl font-bold text-primary">
          PromptClip
        </Link>

        <nav className="flex items-center gap-4 text-sm">
          <Link href="/" className="text-gray-600 hover:text-primary transition-colors">
            홈
          </Link>
          <Link href="/explore" className="text-gray-600 hover:text-primary transition-colors">
            탐색
          </Link>
          {session && (
            <>
              <Link href="/me/library" className="text-gray-600 hover:text-primary transition-colors">
                내 라이브러리
              </Link>
              <Link href="/me/prompts/new" className="text-gray-600 hover:text-primary transition-colors">
                새 프롬프트
              </Link>
            </>
          )}

          {session ? (
            <button
              onClick={handleLogout}
              className="px-3 py-1.5 text-sm border border-gray-300 rounded-md hover:bg-gray-50 transition-colors"
            >
              로그아웃
            </button>
          ) : (
            <Link
              href="/login"
              className="px-3 py-1.5 text-sm bg-primary text-white rounded-md hover:bg-indigo-700 transition-colors"
            >
              로그인
            </Link>
          )}
        </nav>
      </div>
    </header>
  );
}
