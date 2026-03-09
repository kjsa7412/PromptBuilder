import { MetadataRoute } from 'next';
import { siteConfig } from '@/lib/site';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const base = siteConfig.url;
  const apiBase = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

  const staticRoutes: MetadataRoute.Sitemap = [
    { url: base, lastModified: new Date(), changeFrequency: 'daily', priority: 1 },
    { url: `${base}/explore`, lastModified: new Date(), changeFrequency: 'daily', priority: 0.8 },
  ];

  try {
    // 공개 게시물만 포함 (/api/public/ 엔드포인트는 visibility='public' 게시물만 반환)
    const res = await fetch(`${apiBase}/api/public/prompts/new?limit=200`, { cache: 'no-store' });
    if (res.ok) {
      const json = await res.json();
      const prompts: Array<{ id: string; updated_at?: string; updatedAt?: string }> = json.data || [];
      const promptRoutes: MetadataRoute.Sitemap = prompts.map((p) => ({
        url: `${base}/p/${p.id}`,
        lastModified: new Date(p.updated_at || p.updatedAt || Date.now()),
        changeFrequency: 'weekly' as const,
        priority: 0.6,
      }));
      return [...staticRoutes, ...promptRoutes];
    }
  } catch {
    // API 미가동 시 정적 라우트만 반환
  }

  return staticRoutes;
}
