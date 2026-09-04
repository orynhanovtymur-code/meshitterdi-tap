-- ДІН МЕН ДӘСТҮР — P4: server-side duel winner integrity.
-- Run this once in the Supabase SQL Editor, AFTER duels.sql.
--
-- duel_rooms RLS lets either participant update the room (needed so a
-- guest can claim an empty seat, and so either side can write the
-- 'finished' status). That also means, without this trigger, a
-- participant could send a raw REST update setting winner_id to
-- themselves regardless of the real duel_matches counts.
--
-- This trigger recomputes the winner from the real claimed pairs in
-- duel_matches whenever a room transitions into 'finished', and
-- overwrites whatever winner_id the client tried to submit. The
-- client's own winner_id is now advisory only — the database is the
-- one source of truth for who actually won.

create or replace function public.compute_duel_winner()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  host_count integer;
  guest_count integer;
begin
  if new.status = 'finished' and (old.status is distinct from 'finished') then
    select count(*) into host_count from public.duel_matches
      where room_id = new.id and claimed_by = new.host_id;
    select count(*) into guest_count from public.duel_matches
      where room_id = new.id and claimed_by = new.guest_id;
    if host_count > guest_count then
      new.winner_id := new.host_id;
    elsif guest_count > host_count then
      new.winner_id := new.guest_id;
    else
      new.winner_id := null;
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists duel_rooms_compute_winner on public.duel_rooms;
create trigger duel_rooms_compute_winner
  before update on public.duel_rooms
  for each row execute function public.compute_duel_winner();
