'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';

export default function ProfilePage() {
  const router = useRouter();
  const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [token, setToken] = useState<string | null>(null);
  const [displayName, setDisplayName] = useState('');
  const [username, setUsername] = useState('');
  const [avatarUrl, setAvatarUrl] = useState('');
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const init = async () => {
      const { data } = await supabase.auth.getSession();
      if (!data.session) { router.push('/login'); return; }
      const t = data.session.access_token;
      setToken(t);
      try {
        const res = await fetch(`${API_BASE}/api/me/profile`, {
          headers: { Authorization: `Bearer ${t}` }
        });
        if (res.ok) {
          const json = await res.json();
          const profile = json.data || {};
          setDisplayName(profile.display_name || profile.displayName || '');
          setUsername(profile.username || '');
          setAvatarUrl(profile.avatar_url || profile.avatarUrl || '');
        }
      } catch {}
      setLoading(false);
    };
    init();
  }, [router, API_BASE]);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!token) return;
    setSaving(true);
    setError(null);
    setMessage(null);
    try {
      const res = await fetch(`${API_BASE}/api/me/profile`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ displayName, username, avatarUrl }),
      });
      if (res.ok) {
        setMessage('프로필이 저장되었습니다.');
      } else {
        setError('저장에 실패했습니다.');
      }
    } catch {
      setError('저장 중 오류가 발생했습니다.');
    }
    setSaving(false);
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-white dark:bg-[#0a0a0f] flex items-center justify-center">
        <div className="text-gray-400 dark:text-white/40">로딩 중...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-white dark:bg-[#0a0a0f]">
      <div className="max-w-2xl mx-auto px-6 py-16">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-8">프로필 관리</h1>

        {/* Avatar preview */}
        <div className="flex items-center gap-6 mb-8">
          <div className="w-20 h-20 rounded-full bg-gradient-to-br from-violet-500 to-pink-500 flex items-center justify-center text-white text-2xl font-bold overflow-hidden">
            {avatarUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={avatarUrl} alt="avatar" className="w-full h-full object-cover" />
            ) : (
              <span>{displayName ? displayName[0].toUpperCase() : '?'}</span>
            )}
          </div>
          <div>
            <p className="text-lg font-semibold text-gray-900 dark:text-white">{displayName || '이름 없음'}</p>
            <p className="text-sm text-gray-500 dark:text-white/40">@{username || 'unknown'}</p>
          </div>
        </div>

        <div className="p-6 rounded-2xl bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10">
          {error && (
            <div className="text-sm text-pink-600 dark:text-pink-300 bg-pink-50 dark:bg-pink-500/10 border border-pink-200 dark:border-pink-500/20 rounded-xl p-3 mb-4">{error}</div>
          )}
          {message && (
            <div className="text-sm text-green-600 dark:text-green-300 bg-green-50 dark:bg-green-500/10 border border-green-200 dark:border-green-500/20 rounded-xl p-3 mb-4">{message}</div>
          )}

          <form onSubmit={handleSave} className="space-y-5">
            <div>
              <label className="block text-sm font-medium text-gray-600 dark:text-white/60 mb-1.5">닉네임 (표시 이름)</label>
              <input type="text" value={displayName} onChange={(e) => setDisplayName(e.target.value)}
                className="w-full bg-white dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-sm text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-violet-500/50 transition-all"
                placeholder="표시될 이름" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600 dark:text-white/60 mb-1.5">사용자명 (username)</label>
              <input type="text" value={username} onChange={(e) => setUsername(e.target.value)}
                className="w-full bg-white dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-sm text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-violet-500/50 transition-all"
                placeholder="@username" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-600 dark:text-white/60 mb-1.5">아바타 URL</label>
              <input type="url" value={avatarUrl} onChange={(e) => setAvatarUrl(e.target.value)}
                className="w-full bg-white dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-sm text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-violet-500/50 transition-all"
                placeholder="https://..." />
            </div>
            <button type="submit" disabled={saving}
              className="w-full py-3 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-semibold rounded-xl disabled:opacity-40 hover:opacity-90 transition-all">
              {saving ? '저장 중...' : '저장'}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
