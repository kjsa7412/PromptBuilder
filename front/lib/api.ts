const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

export interface PromptCard {
  id: string;
  promptId?: string; // For clips: the actual prompt ID (id is the clip record ID)
  title: string;
  description: string;
  tags: string[];
  clipCount: number;
  bookmarkCount?: number; // 하위 호환
  likeCount: number;
  generateCount: number;
  createdAt: string;
  weeklyScore?: number;
  visibility?: string;
  authorName?: string;
  authorAvatar?: string;
  variableCount?: number;
  firstTemplateBody?: string;
}

export interface PromptVariable {
  key: string;
  label?: string;
  description?: string;
  type: 'text' | 'textarea' | 'select';
  required?: boolean;
  placeholder?: string;
  helpText?: string;
  defaultValue?: string;
  options?: string[];
  sortOrder?: number;
}

export interface PostPrompt {
  id: string;
  promptId: string;
  title: string;
  templateBody: string;
  sortOrder: number;
  status: 'draft' | 'in_progress' | 'complete';
  variables: PromptVariable[];
}

export interface PromptDetail extends PromptCard {
  userId: string;
  bodyMarkdown?: string;
  templateBody?: string;
  currentVersionId?: string;
  versionId?: string;
  variables?: PromptVariable[];
  postPrompts?: PostPrompt[];
}

export interface GenerateResult {
  renderedPrompt: string;
  missingRequired: string[];
}

function snakeToCamel(s: string): string {
  return s.replace(/_([a-z])/g, (_, c) => c.toUpperCase());
}

function convertKeys(obj: unknown): unknown {
  if (Array.isArray(obj)) return obj.map(convertKeys);
  if (obj !== null && typeof obj === 'object') {
    return Object.fromEntries(
      Object.entries(obj as Record<string, unknown>).map(([k, v]) => [snakeToCamel(k), convertKeys(v)])
    );
  }
  return obj;
}

// eslint-disable-next-line
async function fetchApi(path: string, options?: RequestInit): Promise<any> { // noqa
  const res = await fetch(`${API_BASE}${path}`, {
    cache: 'no-store',
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  if (res.status === 204) return null;
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.message || `API error: ${res.status}`);
  }
  const json = await res.json();
  return convertKeys(json);
}

async function fetchApiAuth(path: string, token: string, options?: RequestInit) {
  return fetchApi(path, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
      ...(options?.headers || {}),
    },
  });
}

// Public APIs
export const api = {
  getTrending: (limit = 12, offset = 0): Promise<{ data: PromptCard[] }> =>
    fetchApi(`/api/public/prompts/trending?limit=${limit}&offset=${offset}`),

  getRandom: (limit = 12): Promise<{ data: PromptCard[] }> =>
    fetchApi(`/api/public/prompts/random?limit=${limit}`),

  getNew: (limit = 12, offset = 0): Promise<{ data: PromptCard[] }> =>
    fetchApi(`/api/public/prompts/new?limit=${limit}&offset=${offset}`),

  search: (params: {
    q?: string;
    tag?: string;
    author?: string;
    sort?: string;
    page?: number;
    size?: number;
  }): Promise<{ data: PromptCard[]; meta: { total: number; page: number; size: number } }> => {
    const query = new URLSearchParams();
    if (params.q) query.set('q', params.q);
    if (params.tag) query.set('tag', params.tag);
    if (params.author) query.set('author', params.author);
    if (params.sort) query.set('sort', params.sort);
    query.set('page', String(params.page ?? 0));
    query.set('size', String(params.size ?? 20));
    return fetchApi(`/api/public/prompts/search?${query}`);
  },

  getDetail: (promptId: string): Promise<{ data: PromptDetail }> =>
    fetchApi(`/api/public/prompts/${promptId}`),

  generate: (
    promptId: string,
    values: Record<string, string>,
    sessionId?: string
  ): Promise<{ data: GenerateResult }> =>
    fetchApi(`/api/public/prompts/${promptId}/generate`, {
      method: 'POST',
      body: JSON.stringify({ values, sessionId }),
    }),

  getStats: (): Promise<{ data: { totalPrompts: number } }> =>
    fetchApi('/api/public/stats'),

  // 클립 (북마크 대체)
  getClips: (token: string): Promise<{ data: PromptCard[] }> =>
    fetchApiAuth('/api/me/clips', token),

  addClip: (promptId: string, token: string) =>
    fetchApiAuth(`/api/me/clips/${promptId}`, token, { method: 'POST' }),

  removeClip: (promptId: string, token: string) =>
    fetchApiAuth(`/api/me/clips/${promptId}`, token, { method: 'DELETE' }),

  // 하위 호환 (북마크)
  getBookmarks: (token: string): Promise<{ data: PromptCard[] }> =>
    fetchApiAuth('/api/me/clips', token),

  // 좋아요
  getLikes: (token: string): Promise<{ data: PromptCard[] }> =>
    fetchApiAuth('/api/me/likes', token),

  addLike: (promptId: string, token: string) =>
    fetchApiAuth(`/api/me/likes/${promptId}`, token, { method: 'POST' }),

  removeLike: (promptId: string, token: string) =>
    fetchApiAuth(`/api/me/likes/${promptId}`, token, { method: 'DELETE' }),

  // 세부 프롬프트
  getPostPrompts: (promptId: string, token: string): Promise<{ data: PostPrompt[] }> =>
    fetchApiAuth(`/api/me/prompts/${promptId}/post-prompts`, token),

  createPostPrompt: (promptId: string, data: object, token: string) =>
    fetchApiAuth(`/api/me/prompts/${promptId}/post-prompts`, token, {
      method: 'POST',
      body: JSON.stringify(data),
    }),

  updatePostPrompt: (promptId: string, id: string, data: object, token: string) =>
    fetchApiAuth(`/api/me/prompts/${promptId}/post-prompts/${id}`, token, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),

  deletePostPrompt: (promptId: string, id: string, token: string) =>
    fetchApiAuth(`/api/me/prompts/${promptId}/post-prompts/${id}`, token, {
      method: 'DELETE',
    }),

  // 프롬프트 수정
  updatePrompt: (promptId: string, data: object, token: string) =>
    fetchApiAuth(`/api/me/prompts/${promptId}`, token, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),

  // 프롬프트 삭제
  deletePrompt: (promptId: string, token: string) =>
    fetchApiAuth(`/api/me/prompts/${promptId}`, token, { method: 'DELETE' }),

  // 공개여부 변경
  updateVisibility: (promptId: string, visibility: string, token: string) =>
    fetchApiAuth(`/api/me/prompts/${promptId}/visibility`, token, {
      method: 'PATCH',
      body: JSON.stringify({ visibility }),
    }),

  // 소유자 상세 조회 (draft 포함)
  getMyPromptDetail: (promptId: string, token: string): Promise<{ data: PromptDetail }> =>
    fetchApiAuth(`/api/me/prompts/${promptId}/detail`, token),

  // 프로필
  getProfile: (token: string) =>
    fetchApiAuth('/api/me/profile', token),

  updateProfile: (data: { displayName?: string; username?: string; avatarUrl?: string }, token: string) =>
    fetchApiAuth('/api/me/profile', token, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),
};

// Prompt Builder 유틸
const PLACEHOLDER_RE = /\{\{\s*([a-zA-Z0-9_가-힣]+)\s*\}\}/g;

export function extractVariableKeys(template: string): string[] {
  const keys = new Set<string>();
  let match;
  const re = new RegExp(PLACEHOLDER_RE.source, 'g');
  while ((match = re.exec(template)) !== null) {
    keys.add(match[1]);
  }
  return Array.from(keys);
}

export function renderPrompt(
  template: string,
  values: Record<string, string>
): string {
  return template.replace(
    new RegExp(PLACEHOLDER_RE.source, 'g'),
    (_, key) => values[key] ?? ''
  );
}
