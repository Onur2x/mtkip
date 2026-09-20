-- Talimatlar + Takas + Eğitim testi + Dokümanlar — SQL Editor'de çalıştır

-- 1) sürekli talimatlar
create table if not exists public.talimatlar (
  id bigint generated always as identity primary key,
  baslik text not null,
  icerik text not null,
  aktif boolean not null default true,
  created_at timestamptz default now()
);
create table if not exists public.talimat_okuma (
  talimat_id bigint not null references public.talimatlar (id) on delete cascade,
  sicil text not null,
  okundu_at timestamptz default now(),
  primary key (talimat_id, sicil)
);

-- 2) vardiya takas talepleri (durum: bekliyor/onay/red)
create table if not exists public.takas (
  id bigint generated always as identity primary key,
  isteyen_sicil text not null,
  hedef_sicil text,
  tarih date not null,
  gorevno text not null,
  durum text not null default 'bekliyor' check (durum in ('bekliyor','onay','red')),
  created_at timestamptz default now()
);

-- 3) eğitim soruları + sonuçlar
create table if not exists public.sorular (
  id bigint generated always as identity primary key,
  soru text not null,
  a text not null, b text not null, c text not null, d text not null,
  dogru integer not null check (dogru between 1 and 4),
  aktif boolean not null default true
);
create table if not exists public.sinav_sonuc (
  id bigint generated always as identity primary key,
  sicil text not null,
  dogru integer not null,
  yanlis integer not null,
  created_at timestamptz default now()
);

-- 4) doküman kovası (herkese açık okuma)
insert into storage.buckets (id, name, public)
values ('dokumanlar','dokumanlar', true)
on conflict (id) do update set public = true;

alter table public.talimatlar enable row level security;
alter table public.talimat_okuma enable row level security;
alter table public.takas enable row level security;
alter table public.sorular enable row level security;
alter table public.sinav_sonuc enable row level security;

drop policy if exists "talimat_read" on public.talimatlar;
drop policy if exists "tokuma_rw" on public.talimat_okuma;
drop policy if exists "tokuma_ins" on public.talimat_okuma;
drop policy if exists "takas_rw" on public.takas;
drop policy if exists "takas_ins" on public.takas;
drop policy if exists "takas_upd" on public.takas;
drop policy if exists "soru_read" on public.sorular;
drop policy if exists "sonuc_ins" on public.sinav_sonuc;
drop policy if exists "kurumsal_admin_t" on public.talimatlar;
drop policy if exists "kurumsal_admin_to" on public.talimat_okuma;
drop policy if exists "kurumsal_admin_k" on public.takas;
drop policy if exists "kurumsal_admin_s" on public.sorular;
drop policy if exists "kurumsal_admin_ss" on public.sinav_sonuc;
drop policy if exists "dokuman_read" on storage.objects;
drop policy if exists "dokuman_write" on storage.objects;
drop policy if exists "dokuman_del" on storage.objects;

create policy "talimat_read" on public.talimatlar for select to anon, authenticated using (true);
create policy "tokuma_rw" on public.talimat_okuma for select to anon, authenticated using (true);
create policy "tokuma_ins" on public.talimat_okuma for insert to anon, authenticated with check (true);
create policy "takas_rw" on public.takas for select to anon, authenticated using (true);
create policy "takas_ins" on public.takas for insert to anon, authenticated with check (true);
create policy "takas_upd" on public.takas for update to anon, authenticated using (true) with check (true);
create policy "soru_read" on public.sorular for select to anon, authenticated using (true);
create policy "sonuc_ins" on public.sinav_sonuc for insert to anon, authenticated with check (true);

create policy "kurumsal_admin_t" on public.talimatlar for all to authenticated using (true) with check (true);
create policy "kurumsal_admin_to" on public.talimat_okuma for all to authenticated using (true) with check (true);
create policy "kurumsal_admin_k" on public.takas for all to authenticated using (true) with check (true);
create policy "kurumsal_admin_s" on public.sorular for all to authenticated using (true) with check (true);
create policy "kurumsal_admin_ss" on public.sinav_sonuc for all to authenticated using (true) with check (true);

create policy "dokuman_read" on storage.objects for select to anon, authenticated using (bucket_id = 'dokumanlar');
create policy "dokuman_write" on storage.objects for insert to authenticated with check (bucket_id = 'dokumanlar');
create policy "dokuman_del" on storage.objects for delete to authenticated using (bucket_id = 'dokumanlar');

-- örnek soru:
-- insert into public.sorular (soru,a,b,c,d,dogru) values ('Kırmızı ışık ne anlama gelir?','Dur','Yavaşla','Devam et','Dikkat',1);
