-- ДІН МЕН ДӘСТҮР — P10: make admin's item categories match the site's.
-- Run this once in the Supabase SQL Editor, AFTER categories.sql.
--
-- categories.sql seeded generic keys (mosques/arabic/figures/values)
-- that don't match the actual category names shown on the site's
-- Жинақ (Collection) screen (kzMosques/scholars/holyPlaces/tradition/
-- islamHist/hajj/quran). The "жаңа зат қосу" admin form picks a
-- category from this same table, so the two need to agree.
--
-- Renaming the existing 'mosques' row's key/names in place (rather
-- than deleting+inserting) keeps every existing game_items row's
-- category_id pointing at the same row -- no data migration needed
-- for the 21 mosque items already in the game.

update public.categories
set key = 'kzMosques', name_kz = 'Қазақстан мешіттері', name_ru = 'Мечети Казахстана'
where key = 'mosques';

-- The old arabic/figures/values seed rows aren't part of the site's
-- category set at all -- drop them (they were never assigned to any
-- game_items row, since the site never exposed them for picking).
delete from public.categories where key in ('arabic','figures','values');

insert into public.categories (key, name_kz, name_ru, sort_order) values
  ('scholars',   'Қазақ даласының ғұламалары', 'Учёные казахской степи', 1),
  ('holyPlaces', 'Қасиетті орындар', 'Святые места', 2),
  ('tradition',  'Дін мен дәстүр', 'Религия и традиции', 3),
  ('islamHist',  'Ислам тарихы', 'История ислама', 4),
  ('hajj',       'Қажылық', 'Хадж', 5),
  ('quran',      'Құран әлемі', 'Мир Корана', 6)
on conflict (key) do nothing;
