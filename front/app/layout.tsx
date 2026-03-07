import type { Metadata } from 'next';
import './globals.css';
import Header from '@/components/Header';
import { ThemeProvider } from '@/components/ThemeProvider';

export const metadata: Metadata = {
  title: 'PromptClip - AI 프롬프트 허브',
  description: '최고의 AI 프롬프트를 만들고 공유하세요. 변수 템플릿으로 완성도 높은 프롬프트를 쉽게 생성하세요.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ko" suppressHydrationWarning>
      <body className="min-h-screen flex flex-col bg-white dark:bg-[#0a0a0f] text-gray-900 dark:text-white antialiased transition-colors duration-300">
        <ThemeProvider attribute="class" defaultTheme="dark" enableSystem={false}>
          <Header />
          <main className="flex-1">{children}</main>
          <footer className="border-t border-gray-200 dark:border-white/5 py-8 text-center text-sm text-gray-500 dark:text-white/30">
            <p>&copy; 2026 PromptClip. AI 프롬프트 템플릿 허브</p>
          </footer>
        </ThemeProvider>
      </body>
    </html>
  );
}
