-- ДІН МЕН ДӘСТҮР — real profile stats (games played, best time).
-- Run this once in the Supabase SQL Editor, AFTER schema.sql.
--
-- The profile screen used to show hardcoded fake numbers ("124"
-- games played, "0:38" best time) that never changed. This adds real
-- columns so those tiles reflect actual play history instead.

alter table public.players add column if not exists games_played integer not null default 0;
alter table public.players add column if not exists best_time_seconds integer;
