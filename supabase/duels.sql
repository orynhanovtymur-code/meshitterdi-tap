-- Мешіттерді тап — "Досыммен ойнау" (real-time duel) schema.
-- Run this once in the Supabase SQL Editor, AFTER schema.sql and mosques.sql.

create table if not exists public.duel_rooms (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  host_id uuid not null references auth.users(id) on delete cascade,
  guest_id uuid references auth.users(id) on delete set null,
  status text not null default 'waiting' check (status in ('waiting','countdown','playing','finished')),
  pairs integer not null default 8,
  deck jsonb,
  winner_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.duel_rooms enable row level security;

drop policy if exists "duel_rooms_select" on public.duel_rooms;
create policy "duel_rooms_select"
  on public.duel_rooms for select
  using (auth.uid() is not null);

drop policy if exists "duel_rooms_insert" on public.duel_rooms;
create policy "duel_rooms_insert"
  on public.duel_rooms for insert
  with check (auth.uid() = host_id);

-- Anyone signed in may update a room while it still has no guest (to join it),
-- and the two participants may update it afterwards (status/deck transitions).
drop policy if exists "duel_rooms_update" on public.duel_rooms;
create policy "duel_rooms_update"
  on public.duel_rooms for update
  using (auth.uid() = host_id or auth.uid() = guest_id or guest_id is null)
  with check (auth.uid() = host_id or auth.uid() = guest_id);

drop trigger if exists duel_rooms_set_updated_at on public.duel_rooms;
create trigger duel_rooms_set_updated_at
  before update on public.duel_rooms
  for each row execute function public.set_updated_at();

create index if not exists duel_rooms_code_idx on public.duel_rooms (code);

-- One row per claimed pair per room. The primary key makes claiming a pair
-- atomic: if both players flip the same pair at nearly the same instant,
-- only the first insert succeeds — the second fails with a unique violation.
create table if not exists public.duel_matches (
  room_id uuid not null references public.duel_rooms(id) on delete cascade,
  mosque_id text not null,
  claimed_by uuid not null references auth.users(id) on delete cascade,
  claimed_at timestamptz not null default now(),
  primary key (room_id, mosque_id)
);

alter table public.duel_matches enable row level security;

drop policy if exists "duel_matches_select" on public.duel_matches;
create policy "duel_matches_select"
  on public.duel_matches for select
  using (auth.uid() is not null);

drop policy if exists "duel_matches_insert" on public.duel_matches;
create policy "duel_matches_insert"
  on public.duel_matches for insert
  with check (
    auth.uid() = claimed_by
    and exists (
      select 1 from public.duel_rooms r
      where r.id = room_id
        and r.status = 'playing'
        and (r.host_id = auth.uid() or r.guest_id = auth.uid())
    )
  );

-- Push row-level changes to subscribed clients in real time.
alter publication supabase_realtime add table public.duel_rooms;
alter publication supabase_realtime add table public.duel_matches;
