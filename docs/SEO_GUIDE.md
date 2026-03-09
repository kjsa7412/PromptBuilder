# PromptClip SEO 운영 가이드

포털 등록 및 검색 노출 운영 절차.

---

## 변경된 파일 목록

| 파일 | 내용 |
|---|---|
| `front/lib/site.ts` | **신규** - 사이트 공통 설정 (URL, 제목, 설명, OG 이미지 등) |
| `front/app/layout.tsx` | Google/Naver 인증 메타태그, RSS alternate 링크, `siteConfig` 사용 |
| `front/app/robots.ts` | `siteConfig.url` 사용 (하드코딩 제거) |
| `front/app/sitemap.ts` | `siteConfig.url` 사용, limit 200 적용 |
| `front/app/rss.xml/route.ts` | **신규** - RSS 2.0 피드 Route Handler |
| `front/app/login/layout.tsx` | **신규** - noindex |
| `front/app/signup/layout.tsx` | **신규** - noindex |
| `front/app/me/layout.tsx` | **신규** - /me/* 전체 noindex |
| `front/app/p/[id]/page.tsx` | 비공개/미존재 게시물 generateMetadata noindex 처리 |
| `front/.env.local.example` | SEO 환경변수 3개 추가 |
| `front/public/og-image.svg` | **신규** - OG 이미지 플레이스홀더 (→ PNG 교체 필요) |

---

## 환경변수 설정

`.env.local` (또는 Railway/Vercel 환경변수)에 추가:

```env
# 프로덕션 도메인
NEXT_PUBLIC_SITE_URL=https://www.promptclip.com

# 구글 Search Console 인증 코드 (소유권 확인 후 발급)
NEXT_PUBLIC_GOOGLE_SITE_VERIFICATION=your_code_here

# 네이버 서치어드바이저 인증 코드
NEXT_PUBLIC_NAVER_SITE_VERIFICATION=your_code_here
```

> 인증 코드가 비어 있으면 메타태그가 렌더링되지 않으므로 빌드에 영향 없음.

---

## 공개/비공개 페이지 정책

### 검색 노출 대상 (index)

| 경로 | 설명 |
|---|---|
| `/` | 홈 (트렌딩, 신규 프롬프트) |
| `/explore` | 탐색/검색 |
| `/p/[id]` | 공개(`visibility=public`) 게시물 상세 |

### 검색 제외 대상 (noindex)

| 경로 | 처리 위치 |
|---|---|
| `/login` | `app/login/layout.tsx` |
| `/signup` | `app/signup/layout.tsx` |
| `/me/**` | `app/me/layout.tsx` (라이브러리, 프로필, 작성, 편집 전체) |
| `/p/[id]` (비공개/초안) | `generateMetadata` catch 블록 |
| `/api/**` | `robots.ts` Disallow |

---

## SEO 노출 URL 확인

| 리소스 | URL |
|---|---|
| robots.txt | `https://www.promptclip.com/robots.txt` |
| sitemap.xml | `https://www.promptclip.com/sitemap.xml` |
| RSS 피드 | `https://www.promptclip.com/rss.xml` |

---

## 구글 Search Console 등록 절차

1. [Google Search Console](https://search.google.com/search-console) 접속
2. `URL 접두사` 방식으로 `https://www.promptclip.com` 입력
3. `HTML 태그` 방식 선택 → 인증 코드 복사 (예: `abcdefg1234567`)
4. `.env.local`에 `NEXT_PUBLIC_GOOGLE_SITE_VERIFICATION=abcdefg1234567` 설정
5. 재배포 후 Search Console에서 **확인** 클릭
6. 등록 완료 후 `sitemap.xml` URL 제출:
   - 좌측 메뉴 → Sitemaps → `sitemap.xml` 입력 → 제출

---

## 네이버 서치어드바이저 등록 절차

1. [네이버 서치어드바이저](https://searchadvisor.naver.com) 접속
2. `사이트 관리` → `사이트 추가` → `https://www.promptclip.com` 입력
3. `HTML 태그` 방식 선택 → 인증 코드 복사
4. `.env.local`에 `NEXT_PUBLIC_NAVER_SITE_VERIFICATION=your_code_here` 설정
5. 재배포 후 서치어드바이저에서 **소유 확인** 클릭
6. `사이트맵 제출` → `sitemap.xml` 제출
7. `RSS 제출` → `rss.xml` 제출

---

## OG 이미지 교체 가이드

현재 `public/og-image.svg`는 플레이스홀더입니다.

1. **1200×630px PNG** 이미지 제작 (텍스트, 로고, 배경 포함)
2. `front/public/og-image.png`로 저장
3. `lib/site.ts`의 `ogImage` 경로는 이미 `/og-image.png`로 설정되어 있음
4. SVG 파일 삭제 또는 보관

> OG 이미지는 카카오, 슬랙, 트위터 등 링크 공유 시 미리보기로 노출됩니다.

---

## 운영 시 주의사항

- `NEXT_PUBLIC_SITE_URL`이 실제 도메인과 일치해야 canonical, sitemap, robots가 올바르게 동작합니다.
- sitemap은 백엔드 `/api/public/prompts/new?limit=200` 응답 기준으로 생성됩니다. 게시물 수가 200개를 넘으면 `sitemap.ts`에서 페이지네이션 또는 `generateSitemaps` 분할이 필요합니다.
- RSS 피드는 최신 20개 공개 게시물만 포함합니다.
- 비공개(`private`) 또는 초안(`draft`) 게시물은 `generateMetadata`에서 `robots: noindex`가 적용됩니다. 단, `PrivatePromptClient`로 렌더링되는 경우 해당 사용자(인증 유저)만 볼 수 있습니다.
