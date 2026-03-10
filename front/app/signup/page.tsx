'use client';

import { useState } from 'react';
import Link from 'next/link';
import { supabase } from '@/lib/supabase';

export default function SignupPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const handleSignUp = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    if (password !== confirmPassword) {
      setError('비밀번호가 일치하지 않습니다');
      return;
    }
    if (password.length < 6) {
      setError('비밀번호는 6자 이상이어야 합니다');
      return;
    }
    setLoading(true);
    const { error: err } = await supabase.auth.signUp({ email, password });
    if (err) {
      setError(err.message);
    } else {
      setSuccess(true);
    }
    setLoading(false);
  };

  return (
    <div className="flex-1 bg-white dark:bg-[#0a0a0f] flex items-center justify-center relative overflow-hidden">
      {/* Background effects */}
      <div className="absolute inset-0">
        <div className="absolute top-1/3 left-1/3 w-96 h-96 bg-violet-400/10 dark:bg-violet-600/15 rounded-full blur-3xl" />
        <div className="absolute bottom-1/3 right-1/3 w-80 h-80 bg-pink-400/10 dark:bg-pink-600/15 rounded-full blur-3xl" />
      </div>

      <div className="relative z-10 w-full max-w-md mx-auto px-6">
        <div className="text-center mb-8">
          <Link href="/" className="text-2xl font-bold bg-gradient-to-r from-violet-400 to-pink-400 bg-clip-text text-transparent">
            PromptClip
          </Link>
        </div>

        <div className="p-8 rounded-2xl bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 backdrop-blur-xl">
          <div className="text-center mb-8">
            <h1 className="text-xl font-bold text-gray-900 dark:text-white mb-1">회원가입</h1>
            <p className="text-gray-400 dark:text-white/40 text-sm">AI 프롬프트 커뮤니티에 참여하세요</p>
          </div>

          {error && (
            <div role="alert" className="text-sm text-pink-600 dark:text-pink-300 bg-pink-50 dark:bg-pink-500/10 border border-pink-200 dark:border-pink-500/20 rounded-xl p-3 mb-4">
              {error}
            </div>
          )}

          {success ? (
            <div className="text-center py-4 space-y-4">
              <div className="text-sm text-green-600 dark:text-green-300 bg-green-50 dark:bg-green-500/10 border border-green-200 dark:border-green-500/20 rounded-xl p-4">
                이메일을 확인하세요. 인증 후 로그인하실 수 있습니다.
              </div>
              <Link href="/login" className="block w-full py-3 text-center bg-gradient-to-r from-violet-600 to-pink-600 text-white font-semibold rounded-xl hover:opacity-90 transition-all">
                로그인하러 가기
              </Link>
            </div>
          ) : (
            <form onSubmit={handleSignUp} className="space-y-4">
              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-600 dark:text-white/60 mb-1.5">이메일</label>
                <input id="email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required
                  className="w-full bg-white dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-sm text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-violet-500/50 focus:border-violet-500/50 transition-all"
                  placeholder="user@example.com" />
              </div>
              <div>
                <label htmlFor="password" className="block text-sm font-medium text-gray-600 dark:text-white/60 mb-1.5">비밀번호</label>
                <input id="password" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required
                  className="w-full bg-white dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-sm text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-violet-500/50 focus:border-violet-500/50 transition-all"
                  placeholder="6자 이상" />
              </div>
              <div>
                <label htmlFor="confirm" className="block text-sm font-medium text-gray-600 dark:text-white/60 mb-1.5">비밀번호 확인</label>
                <input id="confirm" type="password" value={confirmPassword} onChange={(e) => setConfirmPassword(e.target.value)} required
                  className="w-full bg-white dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-3 text-sm text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-violet-500/50 focus:border-violet-500/50 transition-all"
                  placeholder="비밀번호 재입력" />
              </div>
              <button type="submit" disabled={loading}
                className="w-full py-3 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-semibold rounded-xl disabled:opacity-40 hover:opacity-90 transition-all mt-2">
                {loading ? '처리 중...' : '회원가입'}
              </button>
            </form>
          )}
        </div>

        <p className="text-center mt-6 text-sm text-gray-500 dark:text-white/40">
          이미 계정이 있으신가요?{' '}
          <Link href="/login" className="text-violet-500 hover:text-violet-400 font-medium transition-colors">
            로그인
          </Link>
        </p>
      </div>
    </div>
  );
}
