/**
 * 사이트 공통 설정
 * URL은 NEXT_PUBLIC_SITE_URL 환경변수로 제어. 없으면 프로덕션 기본값 사용.
 */
export const siteConfig = {
  name: 'PromptClip',
  title: 'PromptClip - AI 프롬프트 허브',
  description:
    'AI 프롬프트 템플릿을 공유하고 활용하는 커뮤니티. ChatGPT, Claude 등 AI를 위한 최고의 프롬프트를 찾아보세요.',
  url: process.env.NEXT_PUBLIC_SITE_URL || 'https://www.promptclip.kr',
  ogImage: '/og-image.png',
  locale: 'ko_KR',
  keywords: ['AI 프롬프트', 'ChatGPT 프롬프트', 'Claude 프롬프트', '프롬프트 템플릿', 'AI 활용'],
};
