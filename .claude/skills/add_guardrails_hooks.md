# Skill: add_guardrails_hooks

## 목적
승인 전 배포/원격반영 차단 훅/가드를 추가한다.

## 파일 구조
- .claude/hooks/guardrails.md: 정책 문서
- .claude/hooks/blocked_commands.txt: 차단 목록
- .claude/hooks/preflight.sh: 엔트리 포인트
- scripts/guard_prod_commands.sh: 차단 로직

## 차단 방식
1. 커맨드 실행 전 preflight.sh 호출
2. ALLOW_PROD=0 이면 blocked_commands.txt 패턴 매칭
3. 매칭 시 exit 1 (차단)

## 해제
```bash
export ALLOW_PROD=1
# PR 승인 확인 후에만 사용
```
