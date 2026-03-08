'use client';

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';
import PromptDetailClient from './PromptDetailClient';
import type { PromptDetail } from '@/lib/api';

const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

function convertKeys(obj: unknown): unknown {
  if (Array.isArray(obj)) return obj.map(convertKeys);
  if (obj !== null && typeof obj === 'object') {
    return Object.fromEntries(
      Object.entries(obj as Record<string, unknown>).map(([k, v]) => [
        k.replace(/_([a-z])/g, (_, c) => c.toUpperCase()),
        convertKeys(v),
      ])
    );
  }
  return obj;
}

export default function PrivatePromptClient({ promptId }: { promptId: string }) {
  const [prompt, setPrompt] = useState<PromptDetail | null>(null);
  const [status, setStatus] = useState<'loading' | 'ok' | 'forbidden' | 'error'>('loading');

  useEffect(() => {
    const load = async () => {
      const { data: sessionData } = await supabase.auth.getSession();
      const token = sessionData.session?.access_token;
      if (!token) { setStatus('forbidden'); return; }

      try {
        const res = await fetch(`${API_BASE}/api/me/prompts/${promptId}/detail`, {
          headers: { Authorization: `Bearer ${token}` },
          cache: 'no-store',
        });
        if (!res.ok) { setStatus(res.status === 403 || res.status === 404 ? 'forbidden' : 'error'); return; }
        const json = await res.json();
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const p = (convertKeys(json.data || json) as any);
        setPrompt(p as PromptDetail);
        setStatus('ok');
      } catch {
        setStatus('error');
      }
    };
    load();
  }, [promptId]);

  if (status === 'loading') {
    return (
      <div className="min-h-screen bg-white dark:bg-[#0a0a0f] flex items-center justify-center">
        <div className="text-gray-400 dark:text-white/40">로딩 중...</div>
      </div>
    );
  }

  if (status === 'forbidden') {
    return (
      <div className="min-h-screen bg-white dark:bg-[#0a0a0f] flex items-center justify-center">
        <div className="text-center space-y-2">
          <p className="text-gray-500 dark:text-white/50">비공개 게시물이거나 존재하지 않는 페이지입니다.</p>
          <a href="/" className="text-sm text-violet-500 hover:underline">홈으로 돌아가기</a>
        </div>
      </div>
    );
  }

  if (status === 'error' || !prompt) {
    return (
      <div className="min-h-screen bg-white dark:bg-[#0a0a0f] flex items-center justify-center">
        <p className="text-gray-400 dark:text-white/40">오류가 발생했습니다.</p>
      </div>
    );
  }

  return (
    <div className="bg-white dark:bg-[#0a0a0f] min-h-screen">
      <div className="max-w-7xl mx-auto px-6 py-12">
        <PromptDetailClient prompt={prompt} />
      </div>
    </div>
  );
}
