-- DIN MEN DASTUR — code-based friend adding.
-- Run this once in the Supabase SQL Editor, AFTER schema.sql and friends.sql.
--
-- Replaces the link-based friend invite with a short personal code:
-- each player generates their own code (Profile → "Дос шақыру"), a
-- friend types it in (Profile → "Досыма қосылу") and the two accounts
-- are linked immediately via the existing friend_requests table.

alter table public.players add column if not exists friend_code text unique;

-- Players are already publicly readable (players_select_all), which is
-- required so a friend's code can be looked up by anyone; no RLS change
-- needed here. The existing players_update_own policy already lets a
-- player set their own friend_code.
