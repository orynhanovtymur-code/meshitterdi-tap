-- Мешіттерді тап — Supabase schema
-- Run this once in the Supabase SQL Editor (Dashboard → SQL Editor → New query).
--
-- Before running: enable Anonymous Sign-ins so each device gets its own
-- auth.uid() without a login screen — Dashboard → Authentication → Sign In / Providers
-- → Anonymous Sign-ins → toggle on. Without this, reads (leaderboard) still work,
-- but writes (saving progress) will silently fail RLS.

create extension if not exists pgcrypto;

create table if not exists public.players (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default 'Ойыншы',
  city text,
  lang text not null default 'kz' check (lang in ('kz','ru')),
  coins integer not null default 0,
  found text[] not null default '{}',
  best_score integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.players enable row level security;

drop policy if exists "players_select_all" on public.players;
create policy "players_select_all"
  on public.players for select
  using (true);

drop policy if exists "players_insert_own" on public.players;
create policy "players_insert_own"
  on public.players for insert
  with check (auth.uid() = id);

drop policy if exists "players_update_own" on public.players;
create policy "players_update_own"
  on public.players for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists players_set_updated_at on public.players;
create trigger players_set_updated_at
  before update on public.players
  for each row execute function public.set_updated_at();

-- Helpful index for the leaderboard query (top scores first).
create index if not exists players_best_score_idx on public.players (best_score desc);
