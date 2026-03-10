'use client';

import { useEffect, useState } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { supabase } from '@/lib/supabase';
import PromptEditorPage from '@/components/PromptEditorPage';

export default function EditPromptPage() {
  const router = useRouter();
  const params = useParams();
  const promptId = params.id as string;
  const [token, setToken] = useState<string | null>(null);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (!data.session) router.push('/login');
      else setToken(data.session.access_token);
    });
  }, [router]);

  if (!token) {
    return (
      <div className="flex-1 bg-white dark:bg-[#0a0a0f] flex items-center justify-center">
        <div className="text-gray-400 dark:text-white/40">로딩 중...</div>
      </div>
    );
  }

  return <PromptEditorPage token={token} promptId={promptId} />;
}
