import { siteConfig } from '@/lib/site';

export const dynamic = 'force-dynamic';

interface PromptItem {
  id: string;
  title: string;
  description?: string;
  tags?: string[];
  created_at?: string;
  createdAt?: string;
}

function escapeXml(str: string): string {
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

export async function GET() {
  const base = siteConfig.url;
  const apiBase = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

  let items = '';
  try {
    const res = await fetch(`${apiBase}/api/public/prompts/new?limit=50`, {
      cache: 'no-store',
    });
    if (res.ok) {
      const json = await res.json();
      const prompts: PromptItem[] = json.data || [];
      items = prompts
        .map((p) => {
          const pubDate = new Date(p.created_at || p.createdAt || Date.now()).toUTCString();
          const link = `${base}/p/${p.id}`;
          const desc = escapeXml(p.description || p.title);
          const categories = (p.tags || [])
            .map((t) => `<category>${escapeXml(t)}</category>`)
            .join('');
          return `    <item>
      <title><![CDATA[${p.title}]]></title>
      <link>${link}</link>
      <guid isPermaLink="true">${link}</guid>
      <pubDate>${pubDate}</pubDate>
      <description><![CDATA[${desc}]]></description>
      ${categories}
    </item>`;
        })
        .join('\n');
    }
  } catch {
    // API 미가동 시 빈 피드 반환
  }

  const rss = `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
  <channel>
    <title>${escapeXml(siteConfig.name)}</title>
    <link>${base}</link>
    <description>${escapeXml(siteConfig.description)}</description>
    <language>ko</language>
    <atom:link href="${base}/rss.xml" rel="self" type="application/rss+xml" />
    <lastBuildDate>${new Date().toUTCString()}</lastBuildDate>
${items}
  </channel>
</rss>`;

  return new Response(rss, {
    headers: {
      'Content-Type': 'application/rss+xml; charset=utf-8',
      'Cache-Control': 'public, max-age=3600, s-maxage=3600',
    },
  });
}
