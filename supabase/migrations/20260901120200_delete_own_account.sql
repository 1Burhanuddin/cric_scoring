-- Deleting an account means deleting the auth.users row, which the
-- authenticated (non-admin) role cannot do directly. This runs as security
-- definer so a user can delete *their own* row only (auth.uid() bound at
-- call time - it's a function, not a passed-in id, precisely so it can't be
-- used to delete anyone else's account).
create or replace function public.delete_own_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;

grant execute on function public.delete_own_account() to authenticated;
