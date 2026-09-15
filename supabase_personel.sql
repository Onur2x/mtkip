-- Personel girişi + günlük görev takibi (60 kullanıcı sorun değil)
-- Supabase Dashboard > SQL Editor > çalıştır

create table if not exists public.personel (
  sicil text primary key,
  ad text not null,
  aktif boolean not null default true
);

create table if not exists public.gorev_log (
  id bigint generated always as identity primary key,
  sicil text not null,
  gorevno text not null,
  ttid integer,
  tarih date not null default CURRENT_DATE,
  created_at timestamptz default now()
);
create index if not exists gorev_log_sicil_tarih on public.gorev_log (sicil, tarih);
-- günde 1 kayıt: aynı gün ikinci görev yazılırsa güncellenir (çift kayıt olmaz)
create unique index if not exists gorev_log_sicil_tarih_uniq on public.gorev_log (sicil, tarih);

alter table public.personel enable row level security;
alter table public.gorev_log enable row level security;

drop policy if exists "personel_read" on public.personel;
drop policy if exists "personel_admin" on public.personel;
drop policy if exists "log_insert" on public.gorev_log;
drop policy if exists "log_admin" on public.gorev_log;

-- giriş kontrolü için herkes sicil+ad okuyabilir (yazamaz)
create policy "personel_read" on public.personel
  for select to anon, authenticated using (true);

-- günlük kayıt: herkes ekleyebilir, okuyamaz/değiştiremez
create policy "log_insert" on public.gorev_log
  for insert to anon, authenticated with check (true);

-- admin (giriş yapmış) her şeyi yapar
create policy "personel_admin" on public.personel
  for all to authenticated using (true) with check (true);
create policy "log_admin" on public.gorev_log
  for all to authenticated using (true) with check (true);

-- ÖRNEK (kendi listeni Table Editor > personel > CSV import ile toplu gir):
-- insert into public.personel (sicil, ad) values ('1001','Ad Soyad');

-- KİM HANGİ GÜN HANGİ GÖREVDE (rapor):
-- select tarih, sicil, gorevno from public.gorev_log order by tarih desc, sicil;
