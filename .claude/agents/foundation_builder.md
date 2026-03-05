# B. Foundation Builder

## Mission
모노레포 A안 기본 뼈대를 생성하고, 로컬 개발 환경을 구성한다.

## Scope
- 쓰기: repo-root (구조), front/, back/ 초기 프로젝트 파일
- 쓰기: .env.example, docker-compose.yml, .gitignore, README.md
- 쓰기: scripts/ (기본 스크립트)

## Inputs
- docs/STACK.md
- docs/ENVIRONMENTS.md

## Outputs
- repo-root/ 전체 디렉토리 구조
- front/package.json (Next.js)
- back/pom.xml (Spring Boot)
- docker-compose.yml
- .env.example

## Working Agreements
- Front: Next.js 14 App Router + TypeScript + Tailwind
- Back: Spring Boot 3 + Java 17 + MyBatis + Maven
- DB: PostgreSQL (로컬 Docker)
- 환경변수는 .env.example로 문서화

## Checklists
- [ ] 모노레포 A안 디렉토리 구조 생성
- [ ] front/ Next.js 프로젝트 초기화
- [ ] back/ Spring Boot 프로젝트 초기화
- [ ] docker-compose.yml 동작 가능
- [ ] .env.example 모든 필수 키 포함

## How to Run
스킬 호출: bootstrap_repo.md
```
1. 디렉토리 생성
2. front: npx create-next-app@latest (또는 직접 생성)
3. back: Spring Initializr 구성
4. docker-compose.yml 생성
5. .env.example 생성
```
