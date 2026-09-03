-- ДІН МЕН ДӘСТҮР — multi-category content.
-- Run this once in the Supabase SQL Editor, AFTER schema.sql, mosques.sql, duels.sql, friends.sql.
--
-- This renames the existing `mosques` table to the more general
-- `game_items` (same rows, same RLS ownership, same storage bucket —
-- nothing is deleted) and adds a `categories` table so the game can
-- offer several matching-game topics, not just mosques.

create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  key text unique not null,
  name_kz text not null,
  name_ru text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

alter table public.categories enable row level security;

drop policy if exists "categories_select_all" on public.categories;
create policy "categories_select_all"
  on public.categories for select
  using (true);

drop policy if exists "categories_admin_insert" on public.categories;
create policy "categories_admin_insert"
  on public.categories for insert
  with check (auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop policy if exists "categories_admin_update" on public.categories;
create policy "categories_admin_update"
  on public.categories for update
  using (auth.jwt() ->> 'email' = 'digital@muftyat.kz')
  with check (auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop policy if exists "categories_admin_delete" on public.categories;
create policy "categories_admin_delete"
  on public.categories for delete
  using (auth.jwt() ->> 'email' = 'digital@muftyat.kz');

insert into public.categories (key, name_kz, name_ru, sort_order) values
  ('mosques', 'Мешіттер', 'Мечети', 0),
  ('arabic', 'Араб әліппесі', 'Арабский алфавит', 1),
  ('figures', 'Ұлт зиялылары', 'Национальная интеллигенция', 2),
  ('values', 'Ұлттық құндылықтар', 'Национальные ценности', 3)
on conflict (key) do nothing;

-- Rename the mosques table to the generic game_items — existing rows,
-- RLS ownership and the storage bucket are untouched by a rename.
alter table if exists public.mosques rename to game_items;

alter table public.game_items add column if not exists category_id uuid references public.categories(id);

update public.game_items
set category_id = (select id from public.categories where key = 'mosques')
where category_id is null;

alter table public.game_items alter column category_id set not null;

create index if not exists game_items_category_idx on public.game_items (category_id, sort_order, created_at);

-- Re-create the RLS policies under names that match the new table name
-- (functionally identical to the old mosques_* policies).
drop policy if exists "mosques_select_all" on public.game_items;
drop policy if exists "mosques_admin_insert" on public.game_items;
drop policy if exists "mosques_admin_update" on public.game_items;
drop policy if exists "mosques_admin_delete" on public.game_items;

drop policy if exists "game_items_select_all" on public.game_items;
create policy "game_items_select_all"
  on public.game_items for select
  using (true);

drop policy if exists "game_items_admin_insert" on public.game_items;
create policy "game_items_admin_insert"
  on public.game_items for insert
  with check (auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop policy if exists "game_items_admin_update" on public.game_items;
create policy "game_items_admin_update"
  on public.game_items for update
  using (auth.jwt() ->> 'email' = 'digital@muftyat.kz')
  with check (auth.jwt() ->> 'email' = 'digital@muftyat.kz');

drop policy if exists "game_items_admin_delete" on public.game_items;
create policy "game_items_admin_delete"
  on public.game_items for delete
  using (auth.jwt() ->> 'email' = 'digital@muftyat.kz');
