-- DIN MEN DASTUR — allow removing a friend.
-- Run this once in the Supabase SQL Editor, AFTER friends.sql.
--
-- friends.sql never added a DELETE policy on friend_requests, so
-- removing a friend from the Profile screen would otherwise be
-- silently blocked by RLS. Either side of an accepted friendship may
-- delete the row.

drop policy if exists "friend_requests_delete" on public.friend_requests;
create policy "friend_requests_delete"
  on public.friend_requests for delete
  using (auth.uid() = from_id or auth.uid() = to_id);
