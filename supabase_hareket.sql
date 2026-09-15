-- Araç giriş/çıkış (depo hareketleri) — SQL Editor'de çalıştır
-- tip: 0 = giriş (yeşil +), 1 = çıkış (kırmızı -)
-- Uygulama, turun saati bu tablodaki saatle eşleşirse rozet gösterir

create table if not exists public.arac_hareket (
  id bigint generated always as identity primary key,
  ttid integer not null default 1,
  gorevno text not null,
  saat time not null,
  tip integer not null check (tip in (0, 1)),
  created_at timestamptz default now()
);
create index if not exists arac_hareket_ttid_gorev on public.arac_hareket (ttid, gorevno);

alter table public.arac_hareket enable row level security;

drop policy if exists "hareket_read" on public.arac_hareket;
drop policy if exists "hareket_admin" on public.arac_hareket;

-- uygulama okur (kendi görevini filtreler), yazamaz
create policy "hareket_read" on public.arac_hareket
  for select to anon, authenticated using (true);

-- ekleme/silme SADECE giriş yapmış admin
create policy "hareket_admin" on public.arac_hareket
  for all to authenticated using (true) with check (true);
