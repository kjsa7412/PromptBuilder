const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8080';

export interface PromptCard {
  id: string;
  title: string;
  description: string;
  tags: string[];
  bookmarkCount: number;
  likeCount: number;
  generateCount: number;
  createdAt: string;
  weeklyScore?: number;
}

export interface PromptVariable {
  key: string;
  label: string;
  type: 'text' | 'textarea' | 'select';
  required: boolean;
  placeholder?: string;
  helpText?: string;
  defaultValue?: string;
  options?: string[];
}

export interface PromptDetail extends PromptCard {
  userId: string;
  templateBody: string;
  currentVersionId?: string;
  versionId?: string;
  variables: PromptVariable[];
}

export interface GenerateResult {
  renderedPrompt: string;
  missingRequired: string[];
}

async function fetchApi(path: string, options?: RequestInit) {
  const res = await fetch(`${API_BASE}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.message || `API error: ${res.status}`);
  }
  return res.json();
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
  getTrending: (limit = 6): Promise<{ data: PromptCard[] }> =>
    fetchApi(`/api/public/prompts/trending?limit=${limit}`),

  getRandom: (limit = 6): Promise<{ data: PromptCard[] }> =>
    fetchApi(`/api/public/prompts/random?limit=${limit}`),

  getNew: (limit = 6): Promise<{ data: PromptCard[] }> =>
    fetchApi(`/api/public/prompts/new?limit=${limit}`),

  search: (params: {
    q?: string;
    tag?: string;
    sort?: string;
    page?: number;
    size?: number;
  }): Promise<{ data: PromptCard[]; meta: { total: number; page: number; size: number } }> => {
    const query = new URLSearchParams();
    if (params.q) query.set('q', params.q);
    if (params.tag) query.set('tag', params.tag);
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

  // Auth APIs
  getBookmarks: (token: string): Promise<{ data: PromptCard[] }> =>
    fetchApiAuth('/api/me/bookmarks', token),

  addBookmark: (promptId: string, token: string) =>
    fetchApiAuth(`/api/me/bookmarks/${promptId}`, token, { method: 'POST' }),

  removeBookmark: (promptId: string, token: string) =>
    fetchApiAuth(`/api/me/bookmarks/${promptId}`, token, { method: 'DELETE' }),
};

// Prompt Builder 유틸
const PLACEHOLDER_RE = /\{\{\s*([a-zA-Z0-9_]+)\s*\}\}/g;

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
