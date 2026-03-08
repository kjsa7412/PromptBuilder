#!/usr/bin/env node
/**
 * PromptClip Bulk Insert SQL Generator
 *
 * 사용법: node generate.js
 *
 * work/ 폴더의 JSON 파일을 읽어 PostgreSQL SQL을 생성하고
 * sql/ 폴더에 저장한 후 작업파일을 done/ 폴더로 이동합니다.
 */

const fs = require("fs");
const path = require("path");

// ============================================================
// 설정: 관리자 계정 user_id (Supabase auth.users.id)
// Supabase 대시보드 > Authentication > Users 에서 확인
// ============================================================
const ADMIN_USER_ID =
  process.env.ADMIN_USER_ID || "118149df-a070-4a7e-8e0b-a20d35d88680";

const WORK_DIR = path.join(__dirname, "work");
const SQL_DIR = path.join(__dirname, "sql");
const DONE_DIR = path.join(__dirname, "done");

// ============================================================
// 유틸리티
// ============================================================

function escapeSQL(str) {
  if (str === null || str === undefined) return "NULL";
  return `'${String(str).replace(/'/g, "''")}'`;
}

function escapeArray(arr) {
  if (!arr || arr.length === 0) return "'{}'";
  const escaped = arr
    .map((s) => `"${String(s).replace(/"/g, '\\"')}"`)
    .join(",");
  return `'{${escaped}}'`;
}

function indent(str, spaces = 4) {
  return str
    .split("\n")
    .map((l) => " ".repeat(spaces) + l)
    .join("\n");
}

// ============================================================
// SQL 생성
// ============================================================

function generateSQL(workFile, data) {
  const {
    title,
    description = null,
    tags = [],
    visibility = "public",
    body_markdown = null,
    post_prompts = [],
  } = data;

  const lines = [];
  const ts = new Date().toISOString();

  lines.push(`-- ============================================================`);
  lines.push(`-- Bulk Insert: ${title}`);
  lines.push(`-- Source: ${workFile}`);
  lines.push(`-- Generated: ${ts}`);
  lines.push(`-- ============================================================`);
  lines.push("");
  lines.push("DO $$");
  lines.push("DECLARE");
  lines.push("    v_prompt_id UUID;");

  // post_prompt 변수 선언
  post_prompts.forEach((_, i) => {
    lines.push(`    v_pp_id_${i} UUID;`);
  });

  lines.push("BEGIN");
  lines.push("");

  // 1. prompts 인서트
  lines.push("    -- 1. 게시물(prompt) 생성");
  lines.push("    INSERT INTO prompts (");
  lines.push(
    "        id, user_id, title, description, tags, visibility, body_markdown,",
  );
  lines.push(
    "        clip_count, like_count, generate_count, view_count, is_deleted,",
  );
  lines.push("        created_at, updated_at");
  lines.push("    ) VALUES (");
  lines.push("        gen_random_uuid(),");
  lines.push(`        ${escapeSQL(ADMIN_USER_ID)}::uuid,`);
  lines.push(`        ${escapeSQL(title)},`);
  lines.push(`        ${description ? escapeSQL(description) : "NULL"},`);
  lines.push(`        ${escapeArray(tags)}::text[],`);
  lines.push(`        ${escapeSQL(visibility)},`);
  lines.push(`        ${body_markdown ? escapeSQL(body_markdown) : "NULL"},`);
  lines.push("        0, 0, 0, 0, false,");
  lines.push("        NOW(), NOW()");
  lines.push("    )");
  lines.push("    RETURNING id INTO v_prompt_id;");
  lines.push("");

  // 2. post_prompts 인서트
  if (post_prompts.length > 0) {
    lines.push("    -- 2. post_prompts 생성");
    post_prompts.forEach((pp, i) => {
      const {
        title: ppTitle = "새 프롬프트",
        template_body = "",
        sort_order = i,
        status = "complete",
        variables = [],
      } = pp;

      lines.push(`    -- post_prompt[${i}]: ${ppTitle}`);
      lines.push(`    INSERT INTO post_prompts (`);
      lines.push(
        `        id, prompt_id, title, template_body, sort_order, status,`,
      );
      lines.push(`        created_at, updated_at`);
      lines.push(`    ) VALUES (`);
      lines.push(`        gen_random_uuid(),`);
      lines.push(`        v_prompt_id,`);
      lines.push(`        ${escapeSQL(ppTitle)},`);
      lines.push(`        ${escapeSQL(template_body)},`);
      lines.push(`        ${sort_order},`);
      lines.push(`        ${escapeSQL(status)},`);
      lines.push(`        NOW(), NOW()`);
      lines.push(`    )`);
      lines.push(`    RETURNING id INTO v_pp_id_${i};`);
      lines.push("");

      // 3. post_prompt_variables 인서트
      if (variables.length > 0) {
        lines.push(`    -- post_prompt[${i}] 변수 생성`);
        variables.forEach((v, j) => {
          const {
            key,
            label = null,
            description: vDesc = null,
            type = "text",
            sort_order: vSort = j,
          } = v;

          lines.push(`    INSERT INTO post_prompt_variables (`);
          lines.push(
            `        id, post_prompt_id, key, label, description, type, sort_order, created_at`,
          );
          lines.push(`    ) VALUES (`);
          lines.push(`        gen_random_uuid(),`);
          lines.push(`        v_pp_id_${i},`);
          lines.push(`        ${escapeSQL(key)},`);
          lines.push(`        ${label ? escapeSQL(label) : "NULL"},`);
          lines.push(`        ${vDesc ? escapeSQL(vDesc) : "NULL"},`);
          lines.push(`        ${escapeSQL(type)},`);
          lines.push(`        ${vSort},`);
          lines.push(`        NOW()`);
          lines.push(`    );`);
        });
        lines.push("");
      }
    });
  }

  lines.push(
    `    RAISE NOTICE 'INSERT OK: ${title.replace(/'/g, "''")} (prompt_id=%)', v_prompt_id;`,
  );
  lines.push("END $$;");
  lines.push("");

  return lines.join("\n");
}

// ============================================================
// 메인 실행
// ============================================================

function main() {
  if (ADMIN_USER_ID === "YOUR_ADMIN_USER_ID_HERE") {
    console.error("❌ ADMIN_USER_ID가 설정되지 않았습니다.");
    console.error("   환경변수: ADMIN_USER_ID=<uuid> node generate.js");
    console.error(
      "   또는 generate.js 상단의 ADMIN_USER_ID 상수를 직접 수정하세요.",
    );
    process.exit(1);
  }

  const workFiles = fs.readdirSync(WORK_DIR).filter((f) => f.endsWith(".json"));

  if (workFiles.length === 0) {
    console.log("ℹ️  work/ 폴더에 처리할 JSON 파일이 없습니다.");
    return;
  }

  console.log(`📂 ${workFiles.length}개 파일 처리 시작...\n`);

  let successCount = 0;
  let errorCount = 0;

  for (const filename of workFiles) {
    const workPath = path.join(WORK_DIR, filename);
    const sqlFilename = filename.replace(/\.json$/, ".sql");
    const sqlPath = path.join(SQL_DIR, sqlFilename);
    const donePath = path.join(DONE_DIR, filename);

    try {
      const raw = fs.readFileSync(workPath, "utf-8");
      const parsed = JSON.parse(raw);

      // 단일 객체도 배열로 통일
      const posts = Array.isArray(parsed) ? parsed : [parsed];

      if (posts.length === 0) {
        throw new Error("게시물이 없습니다");
      }

      // 각 게시물 유효성 검사
      posts.forEach((data, i) => {
        if (!data.title) throw new Error(`[${i}] title 필드가 없습니다`);
        if (!data.post_prompts || data.post_prompts.length === 0)
          throw new Error(`[${i}] post_prompts 배열이 비어있습니다`);
      });

      // 파일 내 모든 게시물을 하나의 SQL 파일로 합침
      const sqlParts = posts.map((data, i) =>
        generateSQL(filename, data, i, posts.length),
      );
      fs.writeFileSync(sqlPath, sqlParts.join("\n"), "utf-8");

      // 작업파일을 done/으로 이동
      fs.renameSync(workPath, donePath);

      console.log(`✅ ${filename} (${posts.length}개 게시물)`);
      console.log(`   → SQL: sql/${sqlFilename}`);
      console.log(`   → 완료: done/${filename}`);
      successCount++;
    } catch (err) {
      console.error(`❌ ${filename}: ${err.message}`);
      errorCount++;
    }

    console.log("");
  }

  console.log("─".repeat(50));
  console.log(`완료: ${successCount}개 성공, ${errorCount}개 실패`);

  if (successCount > 0) {
    console.log("\n📋 다음 단계:");
    console.log(
      "   sql/ 폴더의 .sql 파일을 Supabase SQL Editor에서 실행하세요.",
    );
    console.log("   (실행 후 sql/ 파일은 수동으로 삭제하거나 보관하세요)");
  }
}

main();
