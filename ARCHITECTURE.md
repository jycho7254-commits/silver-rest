# 둥지 ARCHITECTURE

## 사이트 구조

```
둥지 (silver-rest)
├─ index.html — 방문용 SPA (7탭)
│   ├─ 쉼터(shelter) — 24h 온라인, 오늘의 따뜻함(31문구, KST 08:00 시드)
│   ├─ 마음 주고받기(board) — 게시판: 비밀글 sha256(pw+salt), 따뜻해요/힘내요
│   ├─ 함께듣기(music) — 장르 카드→팝업 플레이리스트(YT Music), 신청곡
│   ├─ 표현하는 프로그램(programs) — 8종 중장년 맞춤, 카드→모달(영상+문의)
│   ├─ 마음체크(check) — PHQ-9/GAD-7/WHO-5 클라이언트 채점, 비저장
│   │   └─ PHQ-9 문항9 1점+ → 109 크라이시스 박스 즉시 노출
│   ├─ 상담 신청(counsel) — 대면/온라인/전화, 50인 기업 배지
│   └─ 소개(about) — 아트인터치(박소영)
├─ admin.html — 운영툴 (비밀번호 게이트)
│   ├─ 게시글 관리 — 원본 테이블 직접 조회(비밀글 포함), RPC 삭제, 답글
│   ├─ 상담 신청함 — NEW 배지, 확인 처리
│   ├─ 마음체크 현황 — ⚠️고위험(15점+) 하이라이트
│   └─ 음악 관리 — 플레이리스트 편성, 신청곡 승인
└─ supabase_setup.sql — dungji_* 스키마
```

## 데이터베이스 (dungji_* — 어울림 eoullim_*와 완전 분리)

| 테이블 | 용도 | RLS |
|---|---|---|
| dungji_board | 게시글(제목/내용/비밀여부/pw_hash/따뜻해요/힘내요/admin_reply) | 공개 select/insert/update |
| dungji_board_public | 뷰 — 비밀글 내용 null 마스킹 | 운영자는 원본 테이블로 우회 |
| dungji_songs | 신청곡 | 공개 |
| dungji_playlist | 플레이리스트 편성 | 공개 select, 운영자 insert/delete |
| dungji_checks | 마음체크 기록(동의 시만) | insert만 |
| dungji_counsel | 상담 신청 | insert만, 운영자 select |

**현재 상태: localStorage 폴백 모드** (BOARD_DB_URL/KEY 빈값) — 신규 Supabase 프로젝트 키 수령 시 2상수 입력 + setup.sql 실행으로 전환.

## 어울림과의 차이 (같은 코드베이스, 다른 정체성)

```
브랜드: 어울림 → 둥지
타겟: 다문화청소년 → 중장년층(베이비부머)
위기연락: 1393/1388 → 109/1577-0199
솔트: 'eoullim' → 'dungji' (비밀번호 해시 격리)
프로그램: 정체성 탐색 → 인생2막/부모마음/회고
다국어: 4개국(다문화 필수) → 한국어 중심(+EN/中)
DB: puuiviiiltxagoebruuq(공유 금지) → 신규 프로젝트 예정
```

## UI 특성 (중장년층 접근성)

- 기본 폰트 사이즈 어울림 대비 +1~2px 단위 상향 (가독성)
- 터치 영역 최소 44px (모바일)
- 크라이시스 박스: 고대비 + 전 페이지 하단 고정
- 폴백 폰트: 맑은 고딘 (시스템 기본)

## 배포

- GitHub Pages: `jycho7254-commits.github.io/silver-rest/`
- 원본 repo: `jycho7254-commits/silver-rest`
- 업스트림 참조: multicultural-youth (v17) — 기능 패치 시 양쪽 동기화 검토
