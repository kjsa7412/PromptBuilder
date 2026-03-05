'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/lib/supabase';
import { renderPrompt } from '@/lib/api';

interface VariableDef {
  key: string;
  label: string;
  type: 'text' | 'textarea' | 'select';
  required: boolean;
  placeholder: string;
}

export default function NewPromptPage() {
  const router = useRouter();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [templateBody, setTemplateBody] = useState('');
  const [variables, setVariables] = useState<VariableDef[]>([]);
  const [previewValues, setPreviewValues] = useState<Record<string, string>>({});
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Auth 체크
  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (!data.session) router.push('/login');
    });
  }, [router]);

  // 템플릿에서 변수 자동 감지
  useEffect(() => {
    const re = /\{\{\s*([a-zA-Z0-9_]+)\s*\}\}/g;
    const foundKeys = new Set<string>();
    let m;
    while ((m = re.exec(templateBody)) !== null) {
      foundKeys.add(m[1]);
    }
    setVariables((prev) => {
      const existing = new Map(prev.map((v) => [v.key, v]));
      return Array.from(foundKeys).map((key) =>
        existing.get(key) ?? {
          key,
          label: key,
          type: 'text' as const,
          required: true,
          placeholder: '',
        }
      );
    });
  }, [templateBody]);

  const preview = renderPrompt(templateBody, previewValues);

  const handleSave = async (visibility: 'draft' | 'public') => {
    if (!title.trim()) {
      setError('제목을 입력하세요');
      return;
    }
    setSaving(true);
    const { data } = await supabase.auth.getSession();
    if (!data.session) { router.push('/login'); return; }

    const token = data.session.access_token;
    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080'}/api/me/prompts`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({ title, description, templateBody, visibility }),
        }
      );
      if (!res.ok) throw new Error('저장 실패');
      router.push('/me/library');
    } catch (e) {
      setError('저장 중 오류가 발생했습니다');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto px-4 py-10 space-y-8">
      <h1 className="text-2xl font-bold text-gray-900">새 프롬프트 작성</h1>

      {error && (
        <div role="alert" className="text-sm text-red-500 bg-red-50 rounded p-3">{error}</div>
      )}

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* 편집 영역 */}
        <div className="space-y-5">
          <div>
            <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-1">
              제목 <span className="text-red-500">*</span>
            </label>
            <input
              id="title"
              type="text"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
              placeholder="프롬프트 제목"
            />
          </div>

          <div>
            <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-1">
              설명
            </label>
            <textarea
              id="description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={3}
              className="w-full border rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary resize-y"
              placeholder="이 프롬프트가 어떤 용도인지 설명하세요"
            />
          </div>

          <div>
            <label htmlFor="template" className="block text-sm font-medium text-gray-700 mb-1">
              템플릿 본문
              <span className="text-xs text-gray-400 ml-2">{'{{변수명}} 형식으로 변수를 정의하세요'}</span>
            </label>
            <textarea
              id="template"
              value={templateBody}
              onChange={(e) => setTemplateBody(e.target.value)}
              rows={8}
              className="w-full border rounded-lg px-3 py-2 text-sm font-mono focus:outline-none focus:ring-2 focus:ring-primary resize-y"
              placeholder={'안녕하세요, {{name}}님!\n\n저는 {{role}} 역할로 도움을 드리겠습니다.'}
            />
          </div>

          {/* 감지된 변수 */}
          {variables.length > 0 && (
            <div className="space-y-2">
              <p className="text-sm font-medium text-gray-700">감지된 변수</p>
              {variables.map((v) => (
                <div key={v.key} className="flex items-center gap-2 text-sm">
                  <code className="bg-gray-100 px-2 py-0.5 rounded text-indigo-600">
                    {`{{${v.key}}}`}
                  </code>
                  <input
                    type="text"
                    value={previewValues[v.key] || ''}
                    onChange={(e) =>
                      setPreviewValues((prev) => ({ ...prev, [v.key]: e.target.value }))
                    }
                    placeholder={`${v.key} 미리보기 값`}
                    className="flex-1 border rounded px-2 py-1 text-xs focus:outline-none focus:ring-1 focus:ring-primary"
                  />
                </div>
              ))}
            </div>
          )}
        </div>

        {/* 미리보기 */}
        <div className="space-y-4">
          <h2 className="font-semibold text-gray-800">미리보기</h2>
          <pre className="bg-gray-50 border rounded-xl p-4 text-sm whitespace-pre-wrap text-gray-700 min-h-[200px]">
            {preview || '(템플릿을 입력하세요)'}
          </pre>

          <div className="flex gap-3">
            <button
              onClick={() => handleSave('draft')}
              disabled={saving}
              className="flex-1 py-2 border border-gray-300 text-gray-700 font-medium rounded-lg
                         disabled:opacity-50 hover:bg-gray-50 transition-colors"
            >
              초안 저장
            </button>
            <button
              onClick={() => handleSave('public')}
              disabled={saving}
              className="flex-1 py-2 bg-primary text-white font-medium rounded-lg
                         disabled:opacity-50 hover:bg-indigo-700 transition-colors"
            >
              {saving ? '발행 중...' : '발행'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
