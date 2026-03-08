import type { Metadata } from 'next';
import './globals.css';
import Header from '@/components/Header';
import MobileBottomNav from '@/components/MobileBottomNav';
import { ThemeProvider } from '@/components/ThemeProvider';

export const metadata: Metadata = {
  metadataBase: new URL('https://www.promptclip.com'),
  title: {
    default: 'PromptClip - AI 프롬프트 허브',
    template: '%s | PromptClip',
  },
  description: 'AI 프롬프트 템플릿을 공유하고 활용하는 커뮤니티. ChatGPT, Claude 등 AI를 위한 최고의 프롬프트를 찾아보세요.',
  keywords: ['AI 프롬프트', 'ChatGPT 프롬프트', 'Claude 프롬프트', '프롬프트 템플릿', 'AI 활용'],
  authors: [{ name: 'PromptClip' }],
  openGraph: {
    type: 'website',
    locale: 'ko_KR',
    url: 'https://www.promptclip.com',
    siteName: 'PromptClip',
    title: 'PromptClip - AI 프롬프트 허브',
    description: 'AI 프롬프트 템플릿을 공유하고 활용하는 커뮤니티',
    images: [{ url: '/og-image.png', width: 1200, height: 630, alt: 'PromptClip' }],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'PromptClip - AI 프롬프트 허브',
    description: 'AI 프롬프트 템플릿을 공유하고 활용하는 커뮤니티',
    images: ['/og-image.png'],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: { index: true, follow: true, 'max-image-preview': 'large' },
  },
  alternates: {
    canonical: 'https://www.promptclip.com',
  },
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
          <footer className="hidden md:block border-t border-gray-100 dark:border-white/5 py-6 text-center text-xs text-gray-400 dark:text-white/20">
            &copy; 2026 PromptClip · AI 프롬프트 템플릿 커뮤니티
          </footer>
          <MobileBottomNav />
        </ThemeProvider>
      </body>
    </html>
  );
}
