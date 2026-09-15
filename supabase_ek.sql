-- Ek sefer (artırım) + toplu duyuru — SQL Editor'de çalıştır

-- 1) artırım bayrağı (yeşil satırlar / ek seferler)
alter table public.timetable_rows add column if not exists artirim boolean not null default false;

-- 2) duyurular (hedef: 'all' herkes veya '1'/'2'/'3' gün grubu)
create table if not exists public.duyurular (
  id bigint generated always as identity primary key,
  mesaj text not null,
  hedef text not null default 'all',
  created_at timestamptz default now()
);

-- 3) duyuru okuma takibi (kim, neyi, ne zaman okudu)
create table if not exists public.duyuru_okuma (
  duyuru_id bigint not null references public.duyurular (id) on delete cascade,
  sicil text not null,
  okundu_at timestamptz default now(),
  primary key (duyuru_id, sicil)
);

alter table public.duyurular enable row level security;
alter table public.duyuru_okuma enable row level security;

drop policy if exists "duyuru_read" on public.duyurular;
drop policy if exists "duyuru_okuma_rw" on public.duyuru_okuma;
drop policy if exists "duyuru_admin" on public.duyurular;
drop policy if exists "duyuru_okuma_admin" on public.duyuru_okuma;

create policy "duyuru_read" on public.duyurular
  for select to anon, authenticated using (true);

create policy "duyuru_okuma_rw" on public.duyuru_okuma
  for select to anon, authenticated using (true);
create policy "duyuru_okuma_ins" on public.duyuru_okuma
  for insert to anon, authenticated with check (true);

create policy "duyuru_admin" on public.duyurular
  for all to authenticated using (true) with check (true);
create policy "duyuru_okuma_admin" on public.duyuru_okuma
  for all to authenticated using (true) with check (true);

-- okunmayan duyurular / okunma oranı raporu:
-- select d.id, d.mesaj, count(o.sicil) as okuyan
-- from public.duyurular d left join public.duyuru_okuma o on o.duyuru_id = d.id
-- group by d.id order by d.id desc;
