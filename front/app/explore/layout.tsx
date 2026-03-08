import { Metadata } from 'next';

export const metadata: Metadata = {
  title: '프롬프트 탐색',
  description: 'AI 프롬프트 템플릿을 탐색하고 검색하세요. 다양한 카테고리의 프롬프트를 찾아보세요.',
  openGraph: {
    title: '프롬프트 탐색 | PromptClip',
    description: 'AI 프롬프트 템플릿을 탐색하고 검색하세요.',
  },
};

export default function ExploreLayout({ children }: { children: React.ReactNode }) {
  return children;
}
