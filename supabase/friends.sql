-- Мешіттерді тап — friends + friend-based duel invites.
-- Run this once in the Supabase SQL Editor, AFTER schema.sql, mosques.sql and duels.sql.

create table if not exists public.friend_requests (
  id uuid primary key default gen_random_uuid(),
  from_id uuid not null references auth.users(id) on delete cascade,
  to_id uuid references auth.users(id) on delete cascade,
  invite_token text unique not null,
  status text not null default 'pending' check (status in ('pending','accepted','declined')),
  created_at timestamptz not null default now(),
  responded_at timestamptz
);

alter table public.friend_requests enable row level security;

-- A pending, not-yet-claimed invite (to_id is null) must be readable by whoever
-- holds the link so they can redeem it; once claimed, only the two people
-- involved can see it.
drop policy if exists "friend_requests_select" on public.friend_requests;
create policy "friend_requests_select"
  on public.friend_requests for select
  using (auth.uid() = from_id or auth.uid() = to_id or to_id is null);

drop policy if exists "friend_requests_insert" on public.friend_requests;
create policy "friend_requests_insert"
  on public.friend_requests for insert
  with check (auth.uid() = from_id);

drop policy if exists "friend_requests_update" on public.friend_requests;
create policy "friend_requests_update"
  on public.friend_requests for update
  using (auth.uid() = from_id or auth.uid() = to_id or to_id is null)
  with check (auth.uid() = from_id or auth.uid() = to_id);

create index if not exists friend_requests_token_idx on public.friend_requests (invite_token);
create index if not exists friend_requests_from_idx on public.friend_requests (from_id);
create index if not exists friend_requests_to_idx on public.friend_requests (to_id);

-- Duel rooms can now be created directly targeting a friend (status
-- 'invited'), instead of only via a shared code.
alter table public.duel_rooms drop constraint if exists duel_rooms_status_check;
alter table public.duel_rooms add constraint duel_rooms_status_check
  check (status in ('waiting','invited','countdown','playing','finished','declined'));

alter publication supabase_realtime add table public.friend_requests;
