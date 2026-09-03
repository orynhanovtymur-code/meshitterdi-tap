-- Мешіттерді тап — mosques content table + storage bucket for admin panel.
-- Run this once in the Supabase SQL Editor, AFTER supabase/schema.sql.
--
-- This grants write access (insert/update/delete) on mosque content and
-- photos ONLY to the account signed in with the email below. Create that
-- account first: Dashboard → Authentication → Users → Add user
-- (email: digital@muftyat.kz, set your own password there — never in SQL).

create table if not exists public.mosques (
  id uuid primary key default gen_random_uuid(),
  name_kz text not null,
  name_ru text not null,
  city_kz text not null,
  city_ru text not null,
  fact_kz text not null,
  fact_ru text not null,
  image_url text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.mosques enable row level security;

drop policy if exists "mosques_select_all" on public.mosques;
create policy "mosques_select_all"
  on public.mosques for select
  using (true);

drop policy if exists "mosques_admin_insert" on public.mosques;
create policy "mosques_admin_insert"
  on public.mosques for insert
  with check (auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop policy if exists "mosques_admin_update" on public.mosques;
create policy "mosques_admin_update"
  on public.mosques for update
  using (auth.jwt() ->> 'email' = 'digital@muftyat.kz')
  with check (auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop policy if exists "mosques_admin_delete" on public.mosques;
create policy "mosques_admin_delete"
  on public.mosques for delete
  using (auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop trigger if exists mosques_set_updated_at on public.mosques;
create trigger mosques_set_updated_at
  before update on public.mosques
  for each row execute function public.set_updated_at();

create index if not exists mosques_sort_order_idx on public.mosques (sort_order, created_at);

-- Storage bucket for uploaded mosque photos, publicly readable.
insert into storage.buckets (id, name, public)
values ('mosque-photos', 'mosque-photos', true)
on conflict (id) do nothing;

drop policy if exists "mosque_photos_public_read" on storage.objects;
create policy "mosque_photos_public_read"
  on storage.objects for select
  using (bucket_id = 'mosque-photos');

drop policy if exists "mosque_photos_admin_insert" on storage.objects;
create policy "mosque_photos_admin_insert"
  on storage.objects for insert
  with check (bucket_id = 'mosque-photos' and auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop policy if exists "mosque_photos_admin_update" on storage.objects;
create policy "mosque_photos_admin_update"
  on storage.objects for update
  using (bucket_id = 'mosque-photos' and auth.jwt() ->> 'email' = 'digital@muftyat.kz')
  with check (bucket_id = 'mosque-photos' and auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop policy if exists "mosque_photos_admin_delete" on storage.objects;
create policy "mosque_photos_admin_delete"
  on storage.objects for delete
  using (bucket_id = 'mosque-photos' and auth.jwt() ->> 'email' = 'digital@muftyat.kz');
