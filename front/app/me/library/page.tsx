'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import PromptCard from '@/components/PromptCard';
import { api } from '@/lib/api';
import { getToken, supabase } from '@/lib/supabase';
import type { PromptCard as PromptCardType } from '@/lib/api';

export default function LibraryPage() {
  const router = useRouter();
  const [bookmarks, setBookmarks] = useState<PromptCardType[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const load = async () => {
      const { data } = await supabase.auth.getSession();
      if (!data.session) {
        router.push('/login');
        return;
      }
      const token = data.session.access_token;
      try {
        const res = await api.getBookmarks(token);
        setBookmarks(res.data || []);
      } catch {
        setBookmarks([]);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, [router]);

  return (
    <div className="max-w-6xl mx-auto px-4 py-10 space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">내 라이브러리</h1>
      <p className="text-sm text-gray-500">북마크한 프롬프트 목록</p>

      {loading ? (
        <div className="text-center py-20 text-gray-400">불러오는 중...</div>
      ) : bookmarks.length === 0 ? (
        <div className="text-center py-20 text-gray-400">
          <p>아직 북마크한 프롬프트가 없습니다.</p>
          <a href="/explore" className="text-primary hover:underline mt-2 block">
            프롬프트 탐색하기
          </a>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {bookmarks.map((p) => (
            <PromptCard key={p.id} prompt={p} />
          ))}
        </div>
      )}
    </div>
  );
}
