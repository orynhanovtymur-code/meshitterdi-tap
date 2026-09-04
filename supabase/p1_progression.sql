-- ДІН МЕН ДӘСТҮР — P1: XP/level, achievements data, weekly leaderboard.
-- Run this once in the Supabase SQL Editor, AFTER schema.sql and profile_stats.sql.
--
-- No new tables: achievements are computed client-side from these
-- real stat columns (no fake "unlocked" flags stored separately —
-- the columns themselves ARE the source of truth).

alter table public.players add column if not exists xp integer not null default 0;
alter table public.players add column if not exists has_flawless_win boolean not null default false;
alter table public.players add column if not exists has_fast_win boolean not null default false;
alter table public.players add column if not exists current_streak integer not null default 0;
alter table public.players add column if not exists last_played_date date;

-- Weekly leaderboard: best score achieved within the current ISO week.
-- weekly_score_week holds a label like '2026-W36'; the client resets
-- weekly_score to 0 whenever it detects the label has changed.
alter table public.players add column if not exists weekly_score integer not null default 0;
alter table public.players add column if not exists weekly_score_week text;
