-- ДІН МЕН ДӘСТҮР — P7: duel win/loss record, shown on the leaderboard.
-- Run this once in the Supabase SQL Editor, AFTER schema.sql and duels.sql.
--
-- Real duel outcomes only (bot duels never touch Supabase, so they
-- never affect this) -- incremented once per finished duel from
-- computeDuelResult(), which is already guarded by duelResultFinalized
-- so a duel can never double-count its own result.

alter table public.players add column if not exists duel_wins integer not null default 0;
alter table public.players add column if not exists duel_losses integer not null default 0;
