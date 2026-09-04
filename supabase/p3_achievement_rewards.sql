-- ДІН МЕН ДӘСТҮР — P3: one-time achievement rewards.
-- Run this once in the Supabase SQL Editor, AFTER p1_progression.sql.
--
-- Achievements themselves stay computed client-side from real stat
-- columns (games_played, has_flawless_win, etc — see p1_progression.sql).
-- This column only records WHICH achievement ids have already paid out
-- their one-time coin/XP reward, and WHEN, so a refresh or a later
-- session can never grant the same reward twice.
--
-- Shape: a JSON array of {"id": "<achievement id>", "unlockedAt": "<ISO timestamp>"}.

alter table public.players add column if not exists claimed_achievements jsonb not null default '[]'::jsonb;
