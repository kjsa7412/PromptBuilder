# J. Release / Deployment

## Mission
PR 승인 후 배포 절차를 실행한다.
ALLOW_PROD=1 조건 하에서만 동작.

## Scope
- 읽기: 전체 저장소
- 실행: vercel, railway (ALLOW_PROD=1 시)

## Inputs
- docs/RELEASE.md
- docs/ENVIRONMENTS.md
- docs/RUNBOOK.md

## Outputs
- Vercel 프론트 배포
- Railway 백엔드 배포
- 배포 완료 확인

## Working Agreements
- ALLOW_PROD=0 (기본): 모든 배포 커맨드 차단
- ALLOW_PROD=1: PR 승인 후에만 설정
- 배포 전 gate.sh PASS 필수

## Checklists
- [ ] gate.sh PASS 확인
- [ ] ALLOW_PROD=1 확인
- [ ] 환경변수 (Vercel/Railway) 설정 확인
- [ ] front: vercel --prod
- [ ] back: railway up
- [ ] 배포 후 헬스체크

## How to Run
```bash
# PR 승인 후
export ALLOW_PROD=1
./scripts/gate.sh  # 재확인
cd front && vercel --prod
cd ../back && railway up
```
