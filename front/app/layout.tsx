import type { Metadata } from 'next';
import './globals.css';
import Header from '@/components/Header';

export const metadata: Metadata = {
  title: 'PromptClip - 프롬프트 템플릿 허브',
  description: '프롬프트를 템플릿으로 저장·공유하고 즉시 사용하세요',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko">
      <body className="min-h-screen flex flex-col">
        <Header />
        <main className="flex-1">{children}</main>
        <footer className="bg-white border-t py-6 text-center text-sm text-gray-500">
          <p>© 2024 PromptClip. 프롬프트 템플릿 허브</p>
        </footer>
      </body>
    </html>
  );
}
