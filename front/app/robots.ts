import { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/me/', '/api/'],
      },
    ],
    sitemap: 'https://www.promptclip.com/sitemap.xml',
    host: 'https://www.promptclip.com',
  };
}
