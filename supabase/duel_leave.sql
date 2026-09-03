-- DIN MEN DASTUR — allow a duel room to end in "left".
-- Run this once in the Supabase SQL Editor, AFTER duels.sql and friends.sql.
--
-- Lets either player bail out of an active room (waiting for accept,
-- countdown, or mid-game); the other side's client is watching this
-- row via Realtime and exits automatically when it sees this status.

alter table public.duel_rooms drop constraint if exists duel_rooms_status_check;
alter table public.duel_rooms add constraint duel_rooms_status_check
  check (status in ('waiting','invited','countdown','playing','finished','declined','left'));
