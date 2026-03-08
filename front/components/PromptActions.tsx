'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';

interface Props {
  promptId: string;
  initialClipCount: number;
  initialBookmarkCount?: number; // 하위 호환
  initialLikeCount: number;
  initialGenerateCount: number;
}

export default function PromptActions({
  promptId,
  initialClipCount,
  initialBookmarkCount,
  initialLikeCount,
  initialGenerateCount,
}: Props) {
  const router = useRouter();
  const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

  const [clipped, setClipped] = useState(false);
  const [liked, setLiked] = useState(false);
  const [clipCount, setClipCount] = useState(initialClipCount ?? initialBookmarkCount ?? 0);
  const [likeCount, setLikeCount] = useState(initialLikeCount);
  const [generateCount, setGenerateCount] = useState(initialGenerateCount);
  const [token, setToken] = useState<string | null>(null);
  const [loadingClip, setLoadingClip] = useState(false);
  const [loadingLike, setLoadingLike] = useState(false);

  useEffect(() => {
    const init = async () => {
      const { data } = await supabase.auth.getSession();
      if (!data.session) return;
      const t = data.session.access_token;
      setToken(t);

      try {
        const clipRes = await fetch(`${API_BASE}/api/me/clips`, {
          headers: { Authorization: `Bearer ${t}` },
        });
        if (clipRes.ok) {
          const clipData = await clipRes.json();
          const clips: { prompt_id?: string; promptId?: string }[] = clipData.data || [];
          setClipped(clips.some((c) => (c.prompt_id || c.promptId) === promptId));
        }
      } catch {}

      try {
        const likeRes = await fetch(`${API_BASE}/api/me/likes`, {
          headers: { Authorization: `Bearer ${t}` },
        });
        if (likeRes.ok) {
          const likeData = await likeRes.json();
          const likes: { prompt_id?: string; promptId?: string }[] = likeData.data || [];
          setLiked(likes.some((l) => (l.prompt_id || l.promptId) === promptId));
        }
      } catch {}
    };
    init();
  }, [promptId, API_BASE]);

  useEffect(() => {
    const handler = (e: CustomEvent<{ promptId: string }>) => {
      if (e.detail.promptId === promptId) {
        setGenerateCount((prev) => prev + 1);
      }
    };
    window.addEventListener('promptGenerated', handler as EventListener);
    return () => window.removeEventListener('promptGenerated', handler as EventListener);
  }, [promptId]);

  const handleClip = async () => {
    if (!token) { router.push('/login'); return; }
    setLoadingClip(true);
    try {
      if (clipped) {
        await fetch(`${API_BASE}/api/me/clips/${promptId}`, {
          method: 'DELETE',
          headers: { Authorization: `Bearer ${token}` },
        });
        setClipped(false);
        setClipCount((prev) => Math.max(0, prev - 1));
      } else {
        const res = await fetch(`${API_BASE}/api/me/clips/${promptId}`, {
          method: 'POST',
          headers: { Authorization: `Bearer ${token}` },
        });
        if (res.ok || res.status === 201) {
          setClipped(true);
          setClipCount((prev) => prev + 1);
        }
      }
    } catch {}
    setLoadingClip(false);
  };

  const handleLike = async () => {
    if (!token) { router.push('/login'); return; }
    setLoadingLike(true);
    try {
      if (liked) {
        await fetch(`${API_BASE}/api/me/likes/${promptId}`, {
          method: 'DELETE',
          headers: { Authorization: `Bearer ${token}` },
        });
        setLiked(false);
        setLikeCount((prev) => Math.max(0, prev - 1));
      } else {
        const res = await fetch(`${API_BASE}/api/me/likes/${promptId}`, {
          method: 'POST',
          headers: { Authorization: `Bearer ${token}` },
        });
        if (res.ok || res.status === 201) {
          setLiked(true);
          setLikeCount((prev) => prev + 1);
        }
      }
    } catch {}
    setLoadingLike(false);
  };

  return (
    <div className="flex items-center gap-3 flex-wrap">
      <button
        onClick={handleClip}
        disabled={loadingClip}
        className={`flex items-center gap-2 px-4 py-2 rounded-xl border text-sm font-medium transition-all disabled:opacity-50 ${
          clipped
            ? 'bg-violet-600/30 text-violet-600 dark:text-violet-300 border-violet-500/50 hover:bg-violet-600/40'
            : 'bg-gray-100 dark:bg-white/5 text-gray-500 dark:text-white/60 border-gray-200 dark:border-white/10 hover:bg-gray-200 dark:hover:bg-white/10 hover:text-gray-900 dark:hover:text-white'
        }`}
        title={token ? (clipped ? '클립 해제' : '클립') : '로그인 필요'}
      >
        <svg className="w-4 h-4" viewBox="0 0 24 24" fill={clipped ? "currentColor" : "none"} stroke="currentColor" strokeWidth="2">
          <path strokeLinecap="round" strokeLinejoin="round" d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
        </svg>
        <span>클립 {clipCount}</span>
      </button>

      <button
        onClick={handleLike}
        disabled={loadingLike}
        className={`flex items-center gap-2 px-4 py-2 rounded-xl border text-sm font-medium transition-all disabled:opacity-50 ${
          liked
            ? 'bg-pink-600/30 text-pink-600 dark:text-pink-300 border-pink-500/50 hover:bg-pink-600/40'
            : 'bg-gray-100 dark:bg-white/5 text-gray-500 dark:text-white/60 border-gray-200 dark:border-white/10 hover:bg-gray-200 dark:hover:bg-white/10 hover:text-gray-900 dark:hover:text-white'
        }`}
        title={token ? (liked ? '좋아요 취소' : '좋아요') : '로그인 필요'}
      >
        <svg className="w-4 h-4" viewBox="0 0 24 24" fill={liked ? "currentColor" : "none"} stroke="currentColor" strokeWidth="2">
          <path strokeLinecap="round" strokeLinejoin="round" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
        </svg>
        <span>좋아요 {likeCount}</span>
      </button>

      <div className="flex items-center gap-2 px-4 py-2 rounded-xl border border-gray-200 dark:border-white/5 bg-gray-100 dark:bg-white/5 text-sm text-gray-400 dark:text-white/40">
        <svg className="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
          <path strokeLinecap="round" strokeLinejoin="round" d="M13 10V3L4 14h7v7l9-11h-7z" />
        </svg>
        <span>사용 {generateCount}</span>
      </div>
    </div>
  );
}
