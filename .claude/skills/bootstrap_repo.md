# Skill: bootstrap_repo

## 목적
모노레포 A안 기본 뼈대를 생성한다.

## 실행 순서

```bash
# 1. 디렉토리 생성
mkdir -p front back tests scripts docs db/migrations generated
mkdir -p .claude/agents .claude/skills .claude/hooks
mkdir -p .github/workflows

# 2. Front (Next.js) 초기화
cd front
npx create-next-app@latest . \
  --typescript --tailwind --app --no-src-dir --no-import-alias
cd ..

# 3. Back (Spring Boot) 초기화
# Spring Initializr로 생성하거나 직접 pom.xml 작성
# groupId: com.promptbuilder
# artifactId: promptbuilder
# dependencies: web, mybatis, postgresql, security, jjwt

# 4. 루트 파일
cp .env.example .env  # 키 입력 필요
```

## 산출물
- front/ Next.js 프로젝트
- back/ Spring Boot 프로젝트
- docker-compose.yml
- .env.example
