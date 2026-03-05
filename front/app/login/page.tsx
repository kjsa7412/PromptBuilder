'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);

  const handleSignIn = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    const { error: err } = await supabase.auth.signInWithPassword({ email, password });
    if (err) {
      setError(err.message);
    } else {
      router.push('/');
    }
    setLoading(false);
  };

  const handleSignUp = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    const { error: err } = await supabase.auth.signUp({ email, password });
    if (err) {
      setError(err.message);
    } else {
      setMessage('확인 이메일을 발송했습니다. 이메일을 확인하세요.');
    }
    setLoading(false);
  };

  return (
    <div className="max-w-md mx-auto px-4 py-20">
      <div className="bg-white rounded-xl border p-8 space-y-6">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-gray-900">PromptClip</h1>
          <p className="text-sm text-gray-500 mt-1">로그인하여 더 많은 기능을 사용하세요</p>
        </div>

        {error && (
          <div role="alert" className="text-sm text-red-500 bg-red-50 rounded p-3">
            {error}
          </div>
        )}

        {message && (
          <div className="text-sm text-green-600 bg-green-50 rounded p-3">{message}</div>
        )}

        <form onSubmit={handleSignIn} className="space-y-4">
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-1">
              이메일
            </label>
            <input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="user@example.com"
            />
          </div>

          <div>
            <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-1">
              비밀번호
            </label>
            <input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>

          <div className="flex gap-3">
            <button
              type="submit"
              disabled={loading}
              className="flex-1 py-2 bg-primary text-white font-medium rounded-lg
                         disabled:opacity-50 hover:bg-indigo-700 transition-colors"
            >
              {loading ? '처리 중...' : '로그인'}
            </button>
            <button
              type="button"
              onClick={handleSignUp}
              disabled={loading}
              className="flex-1 py-2 border border-primary text-primary font-medium rounded-lg
                         disabled:opacity-50 hover:bg-indigo-50 transition-colors"
            >
              회원가입
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
