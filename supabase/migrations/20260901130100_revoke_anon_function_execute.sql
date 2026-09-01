-- The previous migration's "revoke ... from public" didn't actually close
-- the gap: Supabase's public-schema default ACL grants EXECUTE directly to
-- anon/authenticated/service_role on every new function (not via the PUBLIC
-- pseudo-role), and CREATE OR REPLACE FUNCTION preserves a function's
-- existing ACL rather than resetting it. Verified via
-- has_function_privilege('anon', ...) still returning true after the prior
-- migration. Revoke the direct anon grant explicitly.
revoke execute on function public.add_ball_score_and_update from anon;
revoke execute on function public.delete_ball_score_and_update from anon;
revoke execute on function public.delete_own_account from anon;
