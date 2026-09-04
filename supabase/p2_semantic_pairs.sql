-- ДІН МЕН ДӘСТҮР — P2: semantic pairs.
-- Run this once in the Supabase SQL Editor, AFTER schema.sql.
--
-- Lets two DIFFERENT game_items match each other (e.g. "Қожа Ахмет
-- Ясауи" <-> "Ясауи кесенесі") instead of only matching an identical
-- image with itself. Any two rows sharing the same non-null
-- pair_key form a pair; items with pair_key left null keep matching
-- themselves exactly as before (fully backward compatible).

alter table public.game_items add column if not exists pair_key text;

create index if not exists game_items_pair_key_idx on public.game_items (pair_key) where pair_key is not null;
