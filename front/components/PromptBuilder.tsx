'use client';

import { useState, useEffect } from 'react';
import type { PromptVariable } from '@/lib/api';
import { renderPrompt } from '@/lib/api';

interface Props {
  promptId: string;
  templateBody: string;
  variables: PromptVariable[];
  onGenerate?: (rendered: string) => void;
}

export default function PromptBuilder({ promptId, templateBody, variables, onGenerate }: Props) {
  const [values, setValues] = useState<Record<string, string>>({});
  const [preview, setPreview] = useState(templateBody);
  const [rendered, setRendered] = useState<string | null>(null);
  const [generating, setGenerating] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [copied, setCopied] = useState(false);

  // 기본값 초기화
  useEffect(() => {
    const defaults: Record<string, string> = {};
    variables.forEach((v) => {
      if (v.defaultValue) defaults[v.key] = v.defaultValue;
    });
    setValues(defaults);
  }, [variables]);

  // 실시간 미리보기
  useEffect(() => {
    setPreview(renderPrompt(templateBody, values));
  }, [templateBody, values]);

  const validate = (): boolean => {
    const newErrors: Record<string, string> = {};
    variables.forEach((v) => {
      if (v.required && !values[v.key]?.trim()) {
        newErrors[v.key] = `${v.label || v.key}은(는) 필수입니다`;
      }
    });
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const isValid = variables.every(
    (v) => !v.required || values[v.key]?.trim()
  );

  const handleGenerate = async () => {
    if (!validate()) return;
    setGenerating(true);
    try {
      const res = await fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080'}/api/public/prompts/${promptId}/generate`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ values }),
        }
      );
      const data = await res.json();
      const finalRendered = data.data?.renderedPrompt || renderPrompt(templateBody, values);
      setRendered(finalRendered);
      onGenerate?.(finalRendered);
    } catch {
      // API 실패 시 클라이언트 치환으로 폴백
      const fallback = renderPrompt(templateBody, values);
      setRendered(fallback);
      onGenerate?.(fallback);
    } finally {
      setGenerating(false);
    }
  };

  const handleCopy = async (text: string) => {
    await navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleChatUI = async (text: string) => {
    await handleCopy(text);
    const chatUrl = process.env.NEXT_PUBLIC_CHAT_UI_URL || 'https://chat.openai.com';
    window.open(chatUrl, '_blank');
  };

  return (
    <div className="space-y-6">
      {/* 변수 폼 */}
      {variables.length > 0 && (
        <div className="space-y-4">
          <h3 className="font-semibold text-gray-800">변수 입력</h3>
          {variables.map((v) => (
            <div key={v.key} className="space-y-1">
              <label htmlFor={`var-${v.key}`} className="block text-sm font-medium text-gray-700">
                {v.label || v.key}
                {v.required && <span className="text-red-500 ml-1" aria-label="필수">*</span>}
              </label>

              {v.type === 'select' && v.options ? (
                <select
                  id={`var-${v.key}`}
                  value={values[v.key] || ''}
                  onChange={(e) => setValues((prev) => ({ ...prev, [v.key]: e.target.value }))}
                  className="w-full border rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                  aria-describedby={v.helpText ? `help-${v.key}` : undefined}
                >
                  <option value="">선택하세요</option>
                  {v.options.map((opt) => (
                    <option key={opt} value={opt}>{opt}</option>
                  ))}
                </select>
              ) : v.type === 'textarea' ? (
                <textarea
                  id={`var-${v.key}`}
                  value={values[v.key] || ''}
                  onChange={(e) => setValues((prev) => ({ ...prev, [v.key]: e.target.value }))}
                  placeholder={v.placeholder}
                  rows={3}
                  className="w-full border rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary resize-y"
                  aria-describedby={v.helpText ? `help-${v.key}` : undefined}
                />
              ) : (
                <input
                  id={`var-${v.key}`}
                  type="text"
                  value={values[v.key] || ''}
                  onChange={(e) => setValues((prev) => ({ ...prev, [v.key]: e.target.value }))}
                  placeholder={v.placeholder}
                  className="w-full border rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-primary"
                  aria-describedby={v.helpText ? `help-${v.key}` : undefined}
                />
              )}

              {v.helpText && (
                <p id={`help-${v.key}`} className="text-xs text-gray-400">{v.helpText}</p>
              )}
              {errors[v.key] && (
                <p role="alert" className="text-xs text-red-500">{errors[v.key]}</p>
              )}
            </div>
          ))}
        </div>
      )}

      {/* 미리보기 */}
      <div className="space-y-2">
        <h3 className="font-semibold text-gray-800">미리보기</h3>
        <pre className="bg-gray-50 border rounded-md p-4 text-sm whitespace-pre-wrap text-gray-700 min-h-[100px]">
          {preview || '(템플릿이 없습니다)'}
        </pre>
      </div>

      {/* Generate 버튼 */}
      <button
        onClick={handleGenerate}
        disabled={!isValid || generating}
        className="w-full py-3 px-6 bg-primary text-white font-semibold rounded-xl
                   disabled:opacity-50 disabled:cursor-not-allowed
                   hover:bg-indigo-700 transition-colors"
        aria-disabled={!isValid}
      >
        {generating ? '생성 중...' : 'Generate'}
      </button>

      {/* 완성 프롬프트 */}
      {rendered && (
        <div className="space-y-3">
          <h3 className="font-semibold text-gray-800">완성된 프롬프트</h3>
          <pre className="bg-indigo-50 border border-indigo-200 rounded-md p-4 text-sm
                          whitespace-pre-wrap text-gray-800 min-h-[100px]">
            {rendered}
          </pre>
          <div className="flex gap-3">
            <button
              onClick={() => handleCopy(rendered)}
              className="flex-1 py-2 px-4 border border-primary text-primary font-medium
                         rounded-lg hover:bg-indigo-50 transition-colors"
            >
              {copied ? '복사됨!' : '복사'}
            </button>
            <button
              onClick={() => handleChatUI(rendered)}
              className="flex-1 py-2 px-4 bg-secondary text-white font-medium
                         rounded-lg hover:bg-purple-700 transition-colors"
            >
              Chat UI로 사용
            </button>
          </div>
          <p className="text-xs text-gray-400 text-center">
            Chat UI로 사용 시 클립보드에 복사됩니다. Ctrl+V 후 Enter를 누르세요.
          </p>
        </div>
      )}
    </div>
  );
}
