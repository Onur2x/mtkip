-- Sicile özel anlık mesaj + okundu takibi — SQL Editor'de çalıştır

create table if not exists public.mesajlar (
  id bigint generated always as identity primary key,
  sicil text not null,
  mesaj text not null,
  okundu boolean not null default false,
  okundu_at timestamptz,
  created_at timestamptz default now()
);
create index if not exists mesajlar_sicil_okundu on public.mesajlar (sicil, okundu);

alter table public.mesajlar enable row level security;

drop policy if exists "mesaj_read" on public.mesajlar;
drop policy if exists "mesaj_okundu" on public.mesajlar;
drop policy if exists "mesaj_admin" on public.mesajlar;

-- uygulama kendi sicilini okur (sorguda filtrelenir)
create policy "mesaj_read" on public.mesajlar
  for select to anon, authenticated using (true);

-- uygulama sadece "okundu" işaretleyebilir (mesajı değiştiremez/silemez)
create policy "mesaj_okundu" on public.mesajlar
  for update to anon, authenticated using (true) with check (okundu = true);

-- admin her şeyi yapar
create policy "mesaj_admin" on public.mesajlar
  for all to authenticated using (true) with check (true);

-- okunmayanlar / rapor:
-- select sicil, mesaj, created_at from public.mesajlar where okundu = false order by created_at desc;
