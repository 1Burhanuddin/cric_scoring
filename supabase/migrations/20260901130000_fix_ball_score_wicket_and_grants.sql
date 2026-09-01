-- Bug found via live API testing (2026-09-01): add_ball_score_and_update /
-- delete_ball_score_and_update wrote the batting team's wicket count onto
-- the BOWLING team's match_teams.wicket / innings.total_wickets row, and
-- never updated the batting team's own wicket count at all. Every ball
-- bowled was stamping team A's wickets-down onto team B's row before team B
-- had even batted. Confirmed empirically: scoring a ball on the running
-- match's 1st innings flipped the 2nd (not-yet-started) innings'
-- total_wickets from 0 to 3.
--
-- Fix: wicket belongs on the batting team's row, not the bowling team's.

create or replace function public.add_ball_score_and_update(
  p_id text,
  p_inning_id text,
  p_match_id text,
  p_over_number int,
  p_ball_number int,
  p_bowler_id uuid,
  p_batsman_id uuid,
  p_non_striker_id uuid,
  p_runs_scored int,
  p_extras_type smallint,
  p_extras_awarded int,
  p_wicket_type smallint,
  p_fielding_position smallint,
  p_player_out_id uuid,
  p_wicket_taker_id uuid,
  p_is_four boolean,
  p_is_six boolean,
  p_time timestamptz,
  p_batting_team_id text,
  p_batting_team_inning_id text,
  p_match_total_runs int,
  p_inning_total_runs int,
  p_bowling_team_id text,
  p_bowling_team_inning_id text,
  p_match_wicket_taken int,
  p_inning_wicket_taken int,
  p_match_bowling_team_runs int default null,
  p_inning_bowling_team_runs int default null,
  p_match_over numeric default null,
  p_inning_over numeric default null,
  p_updated_player_id uuid default null,
  p_updated_player_status smallint default null
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_match_team_id uuid;
begin
  if not public.is_match_participant(p_match_id) then
    raise exception 'not a match participant' using errcode = '42501';
  end if;

  update public.match_teams
    set run = p_match_total_runs, wicket = p_match_wicket_taken, over = coalesce(p_match_over, over)
    where match_id = p_match_id and team_id = p_batting_team_id;
  update public.match_teams
    set run = coalesce(p_match_bowling_team_runs, run)
    where match_id = p_match_id and team_id = p_bowling_team_id;

  update public.innings
    set total_runs = p_inning_total_runs, total_wickets = p_inning_wicket_taken, overs = coalesce(p_inning_over, overs)
    where id = p_batting_team_inning_id;
  update public.innings
    set total_runs = coalesce(p_inning_bowling_team_runs, total_runs)
    where id = p_bowling_team_inning_id;

  if p_updated_player_id is not null then
    select id into v_match_team_id from public.match_teams
      where match_id = p_match_id and team_id = p_batting_team_id;
    insert into public.match_players (match_team_id, user_id, status)
      values (v_match_team_id, p_updated_player_id, p_updated_player_status)
      on conflict (match_team_id, user_id) do update set status = excluded.status;
  end if;

  insert into public.ball_scores (
    id, inning_id, match_id, over_number, ball_number, bowler_id, batsman_id, non_striker_id,
    runs_scored, extras_type, extras_awarded, wicket_type, fielding_position, player_out_id,
    wicket_taker_id, is_four, is_six, time
  ) values (
    p_id, p_inning_id, p_match_id, p_over_number, p_ball_number, p_bowler_id, p_batsman_id, p_non_striker_id,
    p_runs_scored, p_extras_type, p_extras_awarded, p_wicket_type, p_fielding_position, p_player_out_id,
    p_wicket_taker_id, p_is_four, p_is_six, p_time
  )
  on conflict (id) do update set
    inning_id = excluded.inning_id, match_id = excluded.match_id, over_number = excluded.over_number,
    ball_number = excluded.ball_number, bowler_id = excluded.bowler_id, batsman_id = excluded.batsman_id,
    non_striker_id = excluded.non_striker_id, runs_scored = excluded.runs_scored,
    extras_type = excluded.extras_type, extras_awarded = excluded.extras_awarded,
    wicket_type = excluded.wicket_type, fielding_position = excluded.fielding_position,
    player_out_id = excluded.player_out_id, wicket_taker_id = excluded.wicket_taker_id,
    is_four = excluded.is_four, is_six = excluded.is_six, time = excluded.time;
end;
$$;

create or replace function public.delete_ball_score_and_update(
  p_ball_id text,
  p_batting_team_id text,
  p_batting_team_inning_id text,
  p_match_total_runs int,
  p_inning_total_runs int,
  p_bowling_team_id text,
  p_bowling_team_inning_id text,
  p_match_wicket_taken int,
  p_inning_wicket_taken int,
  p_match_bowling_team_runs int default null,
  p_inning_bowling_team_runs int default null,
  p_match_over numeric default null,
  p_inning_over numeric default null,
  p_updated_players jsonb default '[]'
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_match_id text;
  v_match_team_id uuid;
  v_player jsonb;
begin
  select match_id into v_match_id from public.ball_scores where id = p_ball_id;
  if v_match_id is null then
    raise exception 'ball score not found';
  end if;
  if not public.is_match_participant(v_match_id) then
    raise exception 'not a match participant' using errcode = '42501';
  end if;

  update public.match_teams
    set run = p_match_total_runs, wicket = p_match_wicket_taken, over = coalesce(p_match_over, over)
    where match_id = v_match_id and team_id = p_batting_team_id;
  update public.match_teams
    set run = coalesce(p_match_bowling_team_runs, run)
    where match_id = v_match_id and team_id = p_bowling_team_id;

  update public.innings
    set total_runs = p_inning_total_runs, total_wickets = p_inning_wicket_taken, overs = coalesce(p_inning_over, overs)
    where id = p_batting_team_inning_id;
  update public.innings
    set total_runs = coalesce(p_inning_bowling_team_runs, total_runs)
    where id = p_bowling_team_inning_id;

  if jsonb_array_length(p_updated_players) > 0 then
    select id into v_match_team_id from public.match_teams
      where match_id = v_match_id and team_id = p_batting_team_id;
    for v_player in select * from jsonb_array_elements(p_updated_players) loop
      update public.match_players
        set status = (v_player ->> 'status')::smallint
        where match_team_id = v_match_team_id and user_id = (v_player ->> 'id')::uuid;
    end loop;
  end if;

  delete from public.ball_scores where id = p_ball_id;
end;
$$;

-- Postgres grants EXECUTE to PUBLIC by default on function creation; the
-- "grant ... to authenticated" in the original migrations never revoked
-- that, so anon (and anyone) could invoke these SECURITY DEFINER/INVOKER
-- functions. Harmless in practice today (auth.uid() is null for anon, so
-- is_match_participant()/delete_own_account's own WHERE clause end up as
-- safe no-ops) but worth closing off explicitly rather than relying on that.
revoke execute on function public.add_ball_score_and_update from public;
revoke execute on function public.delete_ball_score_and_update from public;
revoke execute on function public.delete_own_account from public;
grant execute on function public.add_ball_score_and_update to authenticated;
grant execute on function public.delete_ball_score_and_update to authenticated;
grant execute on function public.delete_own_account to authenticated;
