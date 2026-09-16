-- SOS + sefer iptali + günlük saha görünürlüğü — SQL Editor'de çalıştır

-- 1) SOS çağrıları
create table if not exists public.sos (
  id bigint generated always as identity primary key,
  sicil text not null,
  gorevno text,
  created_at timestamptz default now()
);

-- 2) sefer iptal bayrağı
alter table public.timetable_rows add column if not exists iptal boolean not null default false;

alter table public.sos enable row level security;

drop policy if exists "sos_insert" on public.sos;
drop policy if exists "sos_admin" on public.sos;

-- uygulama SOS gönderebilir (okuyamaz)
create policy "sos_insert" on public.sos
  for insert to anon, authenticated with check (true);

create policy "sos_admin" on public.sos
  for all to authenticated using (true) with check (true);

-- 3) günlük saha: herkes BUGÜNKÜ görev listesini görebilir (geçmiş gizli)
drop policy if exists "gunluk_saha" on public.gorev_log;
create policy "gunluk_saha" on public.gorev_log
  for select to anon, authenticated using (tarih = CURRENT_DATE);
