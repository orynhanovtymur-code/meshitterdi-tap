-- ДІН МЕН ДӘСТҮР — P6: avatar templates + player's chosen avatar.
-- Run this once in the Supabase SQL Editor, AFTER schema.sql.
--
-- Same admin-only-write pattern as mosques.sql: only the account
-- signed in as digital@muftyat.kz can add/remove avatar templates.
-- Players themselves can only ever update their OWN players.avatar_url
-- (already covered by the existing players_update_own policy from
-- schema.sql -- no RLS change needed there).

create table if not exists public.avatars (
  id uuid primary key default gen_random_uuid(),
  image_url text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.avatars enable row level security;

drop policy if exists "avatars_select_all" on public.avatars;
create policy "avatars_select_all"
  on public.avatars for select
  using (true);

drop policy if exists "avatars_admin_insert" on public.avatars;
create policy "avatars_admin_insert"
  on public.avatars for insert
  with check (auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop policy if exists "avatars_admin_update" on public.avatars;
create policy "avatars_admin_update"
  on public.avatars for update
  using (auth.jwt() ->> 'email' = 'digital@muftyat.kz')
  with check (auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop policy if exists "avatars_admin_delete" on public.avatars;
create policy "avatars_admin_delete"
  on public.avatars for delete
  using (auth.jwt() ->> 'email' = 'digital@muftyat.kz');

create index if not exists avatars_sort_order_idx on public.avatars (sort_order, created_at);

-- The player's chosen avatar. Null until they pick one in Settings --
-- the UI falls back to initials, never a fake/placeholder image.
alter table public.players add column if not exists avatar_url text;

-- Storage bucket for uploaded avatar PNGs, publicly readable.
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

drop policy if exists "avatars_bucket_public_read" on storage.objects;
create policy "avatars_bucket_public_read"
  on storage.objects for select
  using (bucket_id = 'avatars');

drop policy if exists "avatars_bucket_admin_insert" on storage.objects;
create policy "avatars_bucket_admin_insert"
  on storage.objects for insert
  with check (bucket_id = 'avatars' and auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop policy if exists "avatars_bucket_admin_update" on storage.objects;
create policy "avatars_bucket_admin_update"
  on storage.objects for update
  using (bucket_id = 'avatars' and auth.jwt() ->> 'email' = 'digital@muftyat.kz')
  with check (bucket_id = 'avatars' and auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop policy if exists "avatars_bucket_admin_delete" on storage.objects;
create policy "avatars_bucket_admin_delete"
  on storage.objects for delete
  using (bucket_id = 'avatars' and auth.jwt() ->> 'email' = 'digital@muftyat.kz');
