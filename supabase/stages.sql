-- DIN MEN DASTUR — level progression ("кезеңдер").
-- Run this once in the Supabase SQL Editor, AFTER schema.sql.
--
-- The game no longer sorts items into player-chosen categories —
-- everything (mosques, alphabet letters, national items, ...) is
-- pooled together. Instead, players progress through numbered
-- stages: stage 1 is open, each next stage unlocks once the
-- previous one is completed, and the total number of stages grows
-- automatically as more items accumulate in game_items.

alter table public.players add column if not exists unlocked_stage integer not null default 1;
