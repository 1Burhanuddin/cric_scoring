-- Row Level Security for every table. RLS enabled + no policy = deny by
-- default, so each table gets explicit policies rather than relying on that.
--
-- is_match_participant() mirrors the old firestore.rules isMatchParticipant()
-- helper: true for the match's creator, a participating team's creator, or
-- an assigned scorer/umpire/commentator.

create or replace function public.is_match_participant(p_match_id text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.matches m
    where m.id = p_match_id
      and (
        m.created_by = auth.uid()
        or auth.uid() = any(m.team_creator_ids)
        or auth.uid() = any(m.scorer_ids)
        or auth.uid() = any(m.umpire_ids)
        or auth.uid() = any(m.commentator_ids)
      )
  );
$$;

create or replace function public.is_team_admin(p_team_id text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.teams t
    where t.id = p_team_id and t.created_by = auth.uid()
  ) or exists (
    select 1 from public.team_players tp
    where tp.team_id = p_team_id and tp.user_id = auth.uid() and tp.role = 'admin'
  );
$$;

-- ---- users --------------------------------------------------------------
alter table public.users enable row level security;

create policy "users_select_authenticated" on public.users
  for select to authenticated using (true);

create policy "users_update_own" on public.users
  for update to authenticated using (id = auth.uid());

create policy "users_delete_own" on public.users
  for delete to authenticated using (id = auth.uid());

-- ---- user_devices ---------------------------------------------------------
alter table public.user_devices enable row level security;

create policy "user_devices_all_own" on public.user_devices
  for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ---- user_stats -----------------------------------------------------------
alter table public.user_stats enable row level security;

create policy "user_stats_select_authenticated" on public.user_stats
  for select to authenticated using (true);

create policy "user_stats_write_authenticated" on public.user_stats
  for insert to authenticated with check (true);

create policy "user_stats_update_authenticated" on public.user_stats
  for update to authenticated using (true);

-- ---- teams ------------------------------------------------------------
alter table public.teams enable row level security;

create policy "teams_select_authenticated" on public.teams
  for select to authenticated using (true);

create policy "teams_insert_authenticated" on public.teams
  for insert to authenticated with check (created_by = auth.uid());

create policy "teams_update_admin" on public.teams
  for update to authenticated using (public.is_team_admin(id));

create policy "teams_delete_admin" on public.teams
  for delete to authenticated using (public.is_team_admin(id));

alter table public.team_players enable row level security;

create policy "team_players_select_authenticated" on public.team_players
  for select to authenticated using (true);

create policy "team_players_insert_authenticated" on public.team_players
  for insert to authenticated with check (true);

create policy "team_players_update_admin" on public.team_players
  for update to authenticated using (public.is_team_admin(team_id));

create policy "team_players_delete_admin" on public.team_players
  for delete to authenticated using (public.is_team_admin(team_id));

alter table public.team_stats enable row level security;

create policy "team_stats_select_authenticated" on public.team_stats
  for select to authenticated using (true);

create policy "team_stats_write_authenticated" on public.team_stats
  for insert to authenticated with check (true);

create policy "team_stats_update_authenticated" on public.team_stats
  for update to authenticated using (true);

-- ---- matches ------------------------------------------------------------
alter table public.matches enable row level security;

create policy "matches_select_authenticated" on public.matches
  for select to authenticated using (true);

create policy "matches_insert_own" on public.matches
  for insert to authenticated with check (created_by = auth.uid());

create policy "matches_update_participant" on public.matches
  for update to authenticated using (
    created_by = auth.uid() or auth.uid() = any(team_creator_ids)
  );

create policy "matches_delete_owner" on public.matches
  for delete to authenticated using (created_by = auth.uid());

alter table public.match_teams enable row level security;
create policy "match_teams_select_authenticated" on public.match_teams for select to authenticated using (true);
create policy "match_teams_write_participant" on public.match_teams
  for all to authenticated using (public.is_match_participant(match_id)) with check (public.is_match_participant(match_id));

alter table public.match_players enable row level security;
create policy "match_players_select_authenticated" on public.match_players for select to authenticated using (true);
create policy "match_players_write_participant" on public.match_players
  for all to authenticated using (
    exists (select 1 from public.match_teams mt where mt.id = match_team_id and public.is_match_participant(mt.match_id))
  ) with check (
    exists (select 1 from public.match_teams mt where mt.id = match_team_id and public.is_match_participant(mt.match_id))
  );

alter table public.match_settings enable row level security;
create policy "match_settings_select_authenticated" on public.match_settings for select to authenticated using (true);
create policy "match_settings_write_participant" on public.match_settings
  for all to authenticated using (public.is_match_participant(match_id)) with check (public.is_match_participant(match_id));

-- ---- live scoring -----------------------------------------------------
alter table public.innings enable row level security;
create policy "innings_select_authenticated" on public.innings for select to authenticated using (true);
create policy "innings_write_participant" on public.innings
  for all to authenticated using (public.is_match_participant(match_id)) with check (public.is_match_participant(match_id));

alter table public.ball_scores enable row level security;
create policy "ball_scores_select_authenticated" on public.ball_scores for select to authenticated using (true);
create policy "ball_scores_write_participant" on public.ball_scores
  for all to authenticated using (public.is_match_participant(match_id)) with check (public.is_match_participant(match_id));

alter table public.partnerships enable row level security;
create policy "partnerships_select_authenticated" on public.partnerships for select to authenticated using (true);
create policy "partnerships_write_participant" on public.partnerships
  for all to authenticated using (public.is_match_participant(match_id)) with check (public.is_match_participant(match_id));

alter table public.match_events enable row level security;
create policy "match_events_select_authenticated" on public.match_events for select to authenticated using (true);
create policy "match_events_write_participant" on public.match_events
  for all to authenticated using (public.is_match_participant(match_id)) with check (public.is_match_participant(match_id));

-- ---- tournaments (stub scope - see cric_scoring issue #3) -------------
alter table public.tournaments enable row level security;
create policy "tournaments_select_authenticated" on public.tournaments for select to authenticated using (true);
create policy "tournaments_insert_own" on public.tournaments for insert to authenticated with check (created_by = auth.uid());
create policy "tournaments_update_own" on public.tournaments for update to authenticated using (created_by = auth.uid());
create policy "tournaments_delete_own" on public.tournaments for delete to authenticated using (created_by = auth.uid());

alter table public.tournament_members enable row level security;
create policy "tournament_members_select_authenticated" on public.tournament_members for select to authenticated using (true);
create policy "tournament_members_write_authenticated" on public.tournament_members for all to authenticated using (true) with check (true);

alter table public.tournament_teams enable row level security;
create policy "tournament_teams_select_authenticated" on public.tournament_teams for select to authenticated using (true);
create policy "tournament_teams_write_authenticated" on public.tournament_teams for all to authenticated using (true) with check (true);

alter table public.tournament_team_stats enable row level security;
create policy "tournament_team_stats_select_authenticated" on public.tournament_team_stats for select to authenticated using (true);
create policy "tournament_team_stats_write_authenticated" on public.tournament_team_stats for all to authenticated using (true) with check (true);

alter table public.tournament_player_key_stats enable row level security;
create policy "tournament_player_key_stats_select_authenticated" on public.tournament_player_key_stats for select to authenticated using (true);
create policy "tournament_player_key_stats_write_authenticated" on public.tournament_player_key_stats for all to authenticated using (true) with check (true);

-- ---- leaderboard (stub scope - see cric_scoring issue #4) -------------
alter table public.leaderboard_entries enable row level security;
create policy "leaderboard_select_authenticated" on public.leaderboard_entries for select to authenticated using (true);
create policy "leaderboard_write_authenticated" on public.leaderboard_entries for all to authenticated using (true) with check (true);

-- ---- support ------------------------------------------------------------
alter table public.contact_support enable row level security;
create policy "contact_support_insert_own" on public.contact_support
  for insert to authenticated with check (user_id = auth.uid());
-- No select policy: users can create tickets but not read any (matches the
-- old firestore.rules `allow read: if false` for this collection).
