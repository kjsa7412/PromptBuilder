import { MetadataRoute } from 'next';

const BASE_URL = 'https://www.promptclip.com';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const staticRoutes: MetadataRoute.Sitemap = [
    { url: BASE_URL, lastModified: new Date(), changeFrequency: 'daily', priority: 1 },
    { url: `${BASE_URL}/explore`, lastModified: new Date(), changeFrequency: 'daily', priority: 0.8 },
  ];

  try {
    const res = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080'}/api/public/prompts/new?limit=50`, { cache: 'no-store' });
    if (res.ok) {
      const json = await res.json();
      const prompts = json.data || [];
      const promptRoutes: MetadataRoute.Sitemap = prompts.map((p: { id: string; updated_at?: string; updatedAt?: string }) => ({
        url: `${BASE_URL}/p/${p.id}`,
        lastModified: new Date(p.updated_at || p.updatedAt || Date.now()),
        changeFrequency: 'weekly' as const,
        priority: 0.6,
      }));
      return [...staticRoutes, ...promptRoutes];
    }
  } catch {}

  return staticRoutes;
}
