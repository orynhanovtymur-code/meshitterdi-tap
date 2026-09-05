-- ДІН МЕН ДӘСТҮР — P8: duel draw count, to go with duel_wins/duel_losses.
-- Run this once in the Supabase SQL Editor, AFTER p7_duel_stats.sql.

alter table public.players add column if not exists duel_draws integer not null default 0;
