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
  const [rendered, setRendered] = useState<string | null>(null);
  const [generating, setGenerating] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    const defaults: Record<string, string> = {};
    variables.forEach((v) => {
      if (v.defaultValue) defaults[v.key] = v.defaultValue;
    });
    setValues(defaults);
  }, [variables]);

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
      // Always render client-side with the correct templateBody for this post_prompt.
      // Backend generate API only knows the main prompt's template, not individual post_prompts.
      const finalRendered = renderPrompt(templateBody, values);
      setRendered(finalRendered);
      onGenerate?.(finalRendered);
      window.dispatchEvent(new CustomEvent('promptGenerated', { detail: { promptId } }));

      // Fire-and-forget to increment generate_count on the backend
      fetch(
        `${process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080'}/api/public/prompts/${promptId}/generate`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ values }),
        }
      ).catch(() => {/* ignore */});
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
    <div className="space-y-5">
      {variables.length > 0 ? (
        <div className="space-y-4">
          <h3 className="text-sm font-semibold text-gray-500 dark:text-white/80 uppercase tracking-wider">변수 입력</h3>
          {variables.map((v) => (
            <div key={v.key} className="space-y-1.5">
              <label htmlFor={`var-${v.key}`} className="block text-sm font-medium text-gray-600 dark:text-white/70">
                {v.label || v.key}
                {v.required && <span className="text-pink-400 ml-1" aria-label="필수">*</span>}
              </label>

              {v.type === 'select' && v.options ? (
                <select
                  id={`var-${v.key}`}
                  value={values[v.key] || ''}
                  onChange={(e) => setValues((prev) => ({ ...prev, [v.key]: e.target.value }))}
                  className="w-full bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-2.5 text-sm text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-violet-500/50 focus:border-violet-500/50 transition-all"
                  aria-describedby={v.helpText ? `help-${v.key}` : undefined}
                >
                  <option value="" className="bg-white dark:bg-[#1a1a2e]">선택하세요</option>
                  {v.options.map((opt) => (
                    <option key={opt} value={opt} className="bg-white dark:bg-[#1a1a2e]">{opt}</option>
                  ))}
                </select>
              ) : (
                <textarea
                  id={`var-${v.key}`}
                  value={values[v.key] || ''}
                  onChange={(e) => setValues((prev) => ({ ...prev, [v.key]: e.target.value }))}
                  placeholder={v.placeholder || `${v.label || v.key} 입력...`}
                  rows={4}
                  className="w-full bg-gray-50 dark:bg-white/5 border border-gray-200 dark:border-white/10 rounded-xl px-4 py-2.5 text-sm text-gray-900 dark:text-white placeholder-gray-400 dark:placeholder-white/30 focus:outline-none focus:ring-2 focus:ring-violet-500/50 focus:border-violet-500/50 transition-all resize-y font-mono whitespace-pre-wrap"
                  aria-describedby={v.helpText ? `help-${v.key}` : undefined}
                />
              )}

              {(v.helpText || v.description) && (
                <p id={`help-${v.key}`} className="text-xs text-gray-400 dark:text-white/40">
                  {v.helpText || v.description}
                </p>
              )}
              {errors[v.key] && (
                <p role="alert" className="text-xs text-pink-400">{errors[v.key]}</p>
              )}
            </div>
          ))}
        </div>
      ) : (
        <p className="text-sm text-gray-400 dark:text-white/40 text-center py-4">이 프롬프트에는 변수가 없습니다.</p>
      )}

      <button
        onClick={handleGenerate}
        disabled={!isValid || generating}
        className="w-full py-3 px-6 bg-gradient-to-r from-violet-600 to-pink-600 text-white font-semibold rounded-xl disabled:opacity-40 disabled:cursor-not-allowed hover:opacity-90 transition-all hover:scale-[1.01] shadow-lg shadow-violet-500/20"
        aria-disabled={!isValid}
      >
        {generating ? '생성 중...' : '프롬프트 생성하기'}
      </button>

      {rendered && (
        <div className="space-y-3">
          <h3 className="text-sm font-semibold text-gray-500 dark:text-white/80 uppercase tracking-wider">완성된 프롬프트</h3>
          <pre className="bg-violet-50 dark:bg-violet-500/10 border border-violet-200 dark:border-violet-500/20 rounded-xl p-4 text-sm whitespace-pre-wrap text-gray-700 dark:text-white/80 min-h-[100px] font-mono max-h-96 overflow-y-auto touch-pan-y">
            {rendered}
          </pre>
          <div className="flex gap-3">
            <button
              onClick={() => handleCopy(rendered)}
              className="flex-1 py-2 px-4 border border-violet-500/30 text-violet-500 dark:text-violet-300 font-medium rounded-xl hover:bg-violet-500/10 transition-all text-sm"
            >
              {copied ? '복사됨!' : '복사'}
            </button>
            <button
              onClick={() => handleChatUI(rendered)}
              className="flex-1 py-2 px-4 bg-gray-100 dark:bg-white/10 border border-gray-200 dark:border-white/20 text-gray-700 dark:text-white font-medium rounded-xl hover:bg-gray-200 dark:hover:bg-white/20 transition-all text-sm"
            >
              Chat UI로 사용
            </button>
          </div>
          <p className="text-xs text-gray-400 dark:text-white/30 text-center">
            Chat UI로 사용 시 클립보드에 복사됩니다. Ctrl+V 후 Enter를 누르세요.
          </p>
        </div>
      )}
    </div>
  );
}
