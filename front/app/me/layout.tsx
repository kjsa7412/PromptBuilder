import type { Metadata } from 'next';

// /me/* 하위 전체 (라이브러리, 프로필, 작성, 편집) noindex 처리
export const metadata: Metadata = {
  robots: { index: false, follow: false },
};

export default function MeLayout({ children }: { children: React.ReactNode }) {
  return <>{children}</>;
}
