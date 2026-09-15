-- Supabase şeması: tren kalkış uygulaması (salt-okunur mobil app)
-- Kurulum: Supabase Dashboard > SQL Editor > bu dosyayı yapıştır > Run

-- 1) Gruplar: Hafta İçi / Cumartesi / Pazar
create table if not exists public.timetable_groups (
  id integer primary key,
  ttadi text not null
);

-- 2) Satırlar: her tur (run) için 2 satır -> yon=0 ilk istasyon (PAR), yon=1 son istasyon (BOS)
create table if not exists public.timetable_rows (
  id bigint generated always as identity primary key,
  ttid integer not null references public.timetable_groups (id) on delete cascade,
  gorevno text not null,
  run integer not null,
  yon integer not null check (yon in (0, 1)),
  saat time not null,
  dinlenme_dk integer not null default 0,
  tur_suresi_dk integer not null default 51,
  created_at timestamptz default now(),
  unique (ttid, gorevno, run, yon)
);

-- 3) Örnek veri (senin görseldeki 6 tur, görev 6, Hafta İçi)
insert into public.timetable_groups (id, ttadi) values
  (1, 'Hafta Ici'),
  (2, 'Cumartesi'),
  (3, 'Pazar')
on conflict (id) do update set ttadi = excluded.ttadi;

-- görev 6, run 1..6 (k1 = yon 0, k2 = yon 1)
-- önce varsa temizle (sadece örnek görev için)
delete from public.timetable_rows where ttid = 1 and gorevno = '6';

insert into public.timetable_rows (ttid, gorevno, run, yon, saat, dinlenme_dk, tur_suresi_dk) values
  (1, '6', 1, 0, '07:33:19', 28, 51),
  (1, '6', 1, 1, '08:00:04', 28, 51),
  (1, '6', 2, 0, '08:54:46', 49, 51),
  (1, '6', 2, 1, '09:21:31', 49, 51),
  (1, '6', 3, 0, '10:36:36', 49, 51),
  (1, '6', 3, 1, '11:03:21', 49, 51),
  (1, '6', 4, 0, '12:18:26', 49, 51),
  (1, '6', 4, 1, '12:45:11', 49, 51),
  (1, '6', 5, 0, '14:10:27', 59, 51),
  (1, '6', 5, 1, '14:37:12', 59, 51),
  (1, '6', 6, 0, '15:21:44', 18, 51),
  (1, '6', 6, 1, '15:48:29', 18, 51);

-- 4) GÜVENLİK: RLS açık, app SADECE okur (anon SELECT), yazma yok
alter table public.timetable_groups enable row level security;
alter table public.timetable_rows enable row level security;

-- eski politikaları temizle (tekrar çalıştırılabilir olsun)
drop policy if exists "groups_read" on public.timetable_groups;
drop policy if exists "rows_read" on public.timetable_rows;
drop policy if exists "groups_admin" on public.timetable_groups;
drop policy if exists "rows_admin" on public.timetable_rows;

-- herkes (anon dahil) SADECE okuyabilir
create policy "groups_read" on public.timetable_groups
  for select to anon, authenticated using (true);

create policy "rows_read" on public.timetable_rows
  for select to anon, authenticated using (true);

-- yazma (insert/update/delete) SADECE giriş yapmış admine:
-- önce Supabase > Authentication > Users'tan kendine kullanıcı aç,
-- sonra aşağıdaki policy yazmaya izin verir (anon yine yazamaz)
create policy "groups_admin" on public.timetable_groups
  for all to authenticated using (true) with check (true);

create policy "rows_admin" on public.timetable_rows
  for all to authenticated using (true) with check (true);

-- NOT:
-- * service_role anahtarını ASLA uygulamaya/telefona koyma (sadece sende kalsın).
-- * Uygulamaya sadece Project URL + anon public key konur.
-- * Veri girişi Supabase Dashboard > Table Editor'dan yapılır, app'ten yazma kodu yok.
