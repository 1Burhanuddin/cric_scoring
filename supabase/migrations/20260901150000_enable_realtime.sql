-- Every .stream()/onPostgresChanges() call in the Flutter app (streamUserById,
-- streamTeamById, streamMatchById, streamMatchSetting, streamBallScoresByInningIds,
-- streamUserStats, and everything just added via watchTables in
-- api/network/realtime_watch.dart) depends on Supabase Realtime broadcasting
-- row changes for these tables. Hosted Supabase does NOT do this by default -
-- a table only broadcasts changes once it's added to the `supabase_realtime`
-- publication, either via Dashboard > Database > Replication or this SQL.
-- No migration has ever done this, so none of those streams have been
-- receiving live updates - only their initial fetch. This is the actual fix,
-- not just the watchTables() plumbing.
alter publication supabase_realtime add table
  public.users,
  public.user_stats,
  public.teams,
  public.team_players,
  public.team_stats,
  public.matches,
  public.match_teams,
  public.match_players,
  public.match_settings,
  public.innings,
  public.ball_scores,
  public.partnerships,
  public.match_events,
  public.tournaments,
  public.tournament_members,
  public.tournament_teams,
  public.tournament_team_stats,
  public.tournament_player_key_stats,
  public.leaderboard_entries;
