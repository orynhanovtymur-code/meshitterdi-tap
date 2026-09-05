-- ДІН МЕН ДӘСТҮР — P9: admin player management (Ойыншылар tab in admin.html).
-- Run this once in the Supabase SQL Editor, AFTER schema.sql.
--
-- Two things the admin panel needs that the current RLS doesn't allow:
--   1. Deleting another player's row (players_update_own/insert_own are
--      owner-only; there was no delete policy at all).
--   2. Sending a "reset your password" email for a player, which needs
--      their email address. The admin page never sets a password
--      directly -- doing that would require the service_role key,
--      which must never be shipped to a static client-side page (it
--      bypasses every RLS policy in the database). Instead we store
--      each player's email (copied once from auth.users, which RLS
--      normally hides from anon/client access) and the admin panel
--      calls the standard supabase.auth.resetPasswordForEmail() flow,
--      so the player themselves sets the new password via the email
--      link -- the admin never sees or types it.

alter table public.players add column if not exists email text;

-- SECURITY DEFINER: runs as the function owner (not the caller), so it
-- can read auth.users (normally hidden by RLS from anon/authenticated
-- roles) to copy the email onto the new players row.
create or replace function public.set_player_email()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.email is null then
    select email into new.email from auth.users where id = new.id;
  end if;
  return new;
end;
$$;

drop trigger if exists players_set_email on public.players;
create trigger players_set_email
  before insert on public.players
  for each row execute function public.set_player_email();

-- Backfill existing players.
update public.players p
set email = u.email
from auth.users u
where p.id = u.id and p.email is null;

drop policy if exists "players_admin_delete" on public.players;
create policy "players_admin_delete"
  on public.players for delete
  using (auth.jwt() ->> 'email' = 'digital@muftyat.kz');
