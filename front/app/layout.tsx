import type { Metadata } from 'next';
import './globals.css';
import Header from '@/components/Header';
import MobileBottomNav from '@/components/MobileBottomNav';
import { ThemeProvider } from '@/components/ThemeProvider';
import { siteConfig } from '@/lib/site';

export const metadata: Metadata = {
  metadataBase: new URL(siteConfig.url),
  title: {
    default: siteConfig.title,
    template: `%s | ${siteConfig.name}`,
  },
  description: siteConfig.description,
  keywords: siteConfig.keywords,
  authors: [{ name: siteConfig.name }],
  openGraph: {
    type: 'website',
    locale: siteConfig.locale,
    url: siteConfig.url,
    siteName: siteConfig.name,
    title: siteConfig.title,
    description: siteConfig.description,
    images: [{ url: siteConfig.ogImage, width: 1200, height: 630, alt: siteConfig.name }],
  },
  twitter: {
    card: 'summary_large_image',
    title: siteConfig.title,
    description: siteConfig.description,
    images: [siteConfig.ogImage],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: { index: true, follow: true, 'max-image-preview': 'large' },
  },
  alternates: {
    canonical: siteConfig.url,
    types: {
      'application/rss+xml': [{ url: `${siteConfig.url}/rss.xml`, title: `${siteConfig.name} RSS 피드` }],
    },
  },
  verification: {
    google: process.env.NEXT_PUBLIC_GOOGLE_SITE_VERIFICATION,
  },
  other: {
    'naver-site-verification': 'f9f55419cd10c561a45f230175f892b840bb5e57',
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
