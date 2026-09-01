-- leaderboard_entries was defined with a spurious `field` column and a
-- (period, field, user_id) unique constraint. The original Firestore design
-- (khelo/functions/src/leaderboard) keeps exactly one document per
-- (period, user) holding runs/wickets/catches together - `field` was never
-- a partition key, just a query-time choice of which column to sort by
-- (batting -> runs, bowling -> wickets, fielding -> catches). Fix the
-- schema to match before any real rows are written (leaderboard has been
-- stubbed to empty until now, so there's nothing to migrate).
alter table public.leaderboard_entries drop constraint if exists leaderboard_entries_period_field_user_id_key;
alter table public.leaderboard_entries drop column if exists field;
alter table public.leaderboard_entries add constraint leaderboard_entries_period_user_id_key unique (period, user_id);
