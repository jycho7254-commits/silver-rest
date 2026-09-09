-- ═══ 둥지(silver-rest) Supabase 설정 SQL ═══
-- 실행 위치: Supabase Dashboard → SQL Editor → New query → 전체 붙여넣기 → Run
-- 기존 프로젝트(puuiviiiltxagoebruuq)에 dungji_* 테이블 추가 — 어울림 eoullim_*와 완전 분리
-- 전부 IF NOT EXISTS라 재실행해도 안전

-- 1) 게시판
create table if not exists dungji_board (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  nick text not null,
  title text,
  text text not null,
  secret boolean default false,
  pw_hash text,
  warm int default 0,
  cheer int default 0,
  admin_reply text,
  admin_reply_secret boolean default false,
  owner_key text
);

-- 2) 신청곡
create table if not exists dungji_songs (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  nick text,
  song text not null
);

-- 3) 플레이리스트 편성
create table if not exists dungji_playlist (
  id bigint generated always as identity primary key,
  genre text not null,
  title text not null,
  q text not null
);

-- 4) 마음체크 (동의 시만 저장)
create table if not exists dungji_checks (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  nick text,
  age_band text,
  contact text,
  kind text not null,
  score int not null
);

-- 5) 상담 신청
create table if not exists dungji_counsel (
  id bigint generated always as identity primary key,
  created_at timestamptz default now(),
  name text not null,
  contact text not null,
  type text,
  message text,
  done boolean default false
);

-- ═══ RLS 정책 (공개 read/insert + 반응 update만 — 삭제는 RPC로만) ═══
alter table dungji_board enable row level security;
alter table dungji_songs enable row level security;
alter table dungji_playlist enable row level security;
alter table dungji_checks enable row level security;
alter table dungji_counsel enable row level security;

drop policy if exists "dungji_pub_select" on dungji_board;
create policy "dungji_pub_select" on dungji_board for select using (true);
drop policy if exists "dungji_pub_insert" on dungji_board;
create policy "dungji_pub_insert" on dungji_board for insert with check (true);
drop policy if exists "dungji_pub_update" on dungji_board;
create policy "dungji_pub_update" on dungji_board for update using (true) with check (true);

drop policy if exists "dungji_songs_select" on dungji_songs;
create policy "dungji_songs_select" on dungji_songs for select using (true);
drop policy if exists "dungji_songs_insert" on dungji_songs;
create policy "dungji_songs_insert" on dungji_songs for insert with check (true);
drop policy if exists "dungji_songs_delete" on dungji_songs;
create policy "dungji_songs_delete" on dungji_songs for delete using (true);

drop policy if exists "dungji_pl_select" on dungji_playlist;
create policy "dungji_pl_select" on dungji_playlist for select using (true);
drop policy if exists "dungji_pl_insert" on dungji_playlist;
create policy "dungji_pl_insert" on dungji_playlist for insert with check (true);
drop policy if exists "dungji_pl_delete" on dungji_playlist;
create policy "dungji_pl_delete" on dungji_playlist for delete using (true);

drop policy if exists "dungji_checks_insert" on dungji_checks;
create policy "dungji_checks_insert" on dungji_checks for insert with check (true);

drop policy if exists "dungji_counsel_insert" on dungji_counsel;
create policy "dungji_counsel_insert" on dungji_counsel for insert with check (true);

-- ═══ 비밀글 마스킹 뷰 (운영자는 원본 테이블, 방문자는 이 뷰) ═══
drop view if exists dungji_board_public;
create view dungji_board_public as
  select id, created_at, nick, title,
         case when secret then null else text end as text,
         secret, (pw_hash is not null) as has_pw, owner_key,
         warm, cheer, admin_reply, admin_reply_secret
  from dungji_board;
grant select on dungji_board_public to anon, authenticated;

-- ═══ 운영자 삭제 RPC (비밀번호 검증 — 방문자 삭제 불가) ═══
create or replace function admin_delete_post_dungji(post_id bigint, pw text)
returns boolean language plpgsql security definer as $$
declare ok boolean;
begin
  ok := (pw = 'dungji2026!op');
  if not ok then return false; end if;
  delete from dungji_board where id = post_id;
  return true;
end $$;
