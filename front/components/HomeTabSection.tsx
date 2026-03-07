'use client';

import { useState } from 'react';
import PromptCard from './PromptCard';
import type { PromptCard as PromptCardType } from '@/lib/api';

interface Props {
  trending: PromptCardType[];
  random: PromptCardType[];
  newPrompts: PromptCardType[];
}

const TABS = [
  { key: 'trending' as const, label: '🔥 주간 인기', subtitle: '커뮤니티에서 가장 많이 사용되는 프롬프트' },
  { key: 'random' as const, label: '🎲 랜덤 발견', subtitle: '새로운 영감을 찾아보세요' },
  { key: 'new' as const, label: '✨ 신규 프롬프트', subtitle: '최신 등록 프롬프트' },
];

export default function HomeTabSection({ trending, random, newPrompts }: Props) {
  const [activeTab, setActiveTab] = useState<'trending' | 'random' | 'new'>('trending');

  const current =
    activeTab === 'trending' ? trending : activeTab === 'random' ? random : newPrompts;
  const activeInfo = TABS.find((t) => t.key === activeTab)!;

  return (
    <div>
      <div className="flex items-center gap-1 mb-8 p-1 bg-gray-100 dark:bg-white/5 rounded-xl w-fit">
        {TABS.map((tab) => (
          <button
            key={tab.key}
            onClick={() => setActiveTab(tab.key)}
            className={`px-5 py-2 rounded-lg text-sm font-medium transition-all ${
              activeTab === tab.key
                ? 'bg-white dark:bg-white/20 text-gray-900 dark:text-white shadow-sm'
                : 'text-gray-500 dark:text-white/50 hover:text-gray-700 dark:hover:text-white/70'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <p className="text-gray-400 dark:text-white/40 text-sm mb-6">{activeInfo.subtitle}</p>

      {current.length === 0 ? (
        <div className="text-center py-16 rounded-2xl border border-gray-200 dark:border-white/5 bg-gray-50 dark:bg-white/2">
          <p className="text-gray-400 dark:text-white/30 text-sm">아직 프롬프트가 없습니다</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {current.map((p) => (
            <PromptCard key={p.id} prompt={p} />
          ))}
        </div>
      )}
    </div>
  );
}
