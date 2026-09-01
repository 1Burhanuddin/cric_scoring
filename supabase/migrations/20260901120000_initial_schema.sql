-- CricHeros initial Supabase schema.
--
-- ID convention: public.users.id is a native uuid (it IS auth.users.id, owned
-- by Supabase Auth). Every other table's id is client-generated text (the app
-- already generates ids as 32-char hex strings via Dart's Uuid().v4()) - kept
-- as text rather than forcing them through native uuid formatting.

-- ===================================================================
-- users (profile row, one per auth.users row)
-- ===================================================================
create table public.users (
  id uuid primary key references auth.users (id) on delete cascade,
  phone text unique,
  name text,
  name_lowercase text,
  location text,
  dob date,
  email text,
  profile_img_url text,
  gender smallint,
  player_role smallint,
  batting_style smallint,
  bowling_style smallint,
  is_active boolean not null default true,
  notifications boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index users_name_lowercase_idx on public.users (name_lowercase);

-- Registered devices (FCM push tokens). Supabase Auth owns sessions/refresh
-- tokens itself, so this only tracks what the old user_sessions table's
-- device-token side needed.
create table public.user_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  device_type smallint not null,
  device_id text not null,
  device_name text not null,
  device_fcm_token text,
  app_version integer not null,
  os_version text not null,
  created_at timestamptz not null default now(),
  unique (user_id, device_id)
);

create table public.user_stats (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  type text not null,
  matches integer not null default 0,
  batting jsonb not null default '{}',
  bowling jsonb not null default '{}',
  fielding jsonb not null default '{}',
  updated_at timestamptz not null default now(),
  unique (user_id, type)
);

-- ===================================================================
-- teams
-- ===================================================================
create table public.teams (
  id text primary key,
  name text not null,
  name_lowercase text not null,
  city text,
  name_initial text,
  profile_img_url text,
  created_by uuid references public.users (id) on delete set null,
  created_at timestamptz not null default now()
);

create index teams_name_lowercase_idx on public.teams (name_lowercase);

create table public.team_players (
  id uuid primary key default gen_random_uuid(),
  team_id text not null references public.teams (id) on delete cascade,
  user_id uuid not null references public.users (id) on delete cascade,
  role text not null default 'player',
  unique (team_id, user_id)
);

create table public.team_stats (
  id uuid primary key default gen_random_uuid(),
  team_id text not null unique references public.teams (id) on delete cascade,
  played integer not null default 0,
  win integer not null default 0,
  tie integer not null default 0,
  lost integer not null default 0,
  runs integer not null default 0,
  wickets integer not null default 0,
  batting_average numeric(8, 2) not null default 0,
  bowling_average numeric(8, 2) not null default 0,
  highest_runs integer not null default 0,
  lowest_runs integer not null default 0,
  run_rate numeric(8, 2) not null default 0
);

-- ===================================================================
-- tournaments (minimal - full tournament logic is tracked separately,
-- see cric_scoring issue #3)
-- ===================================================================
create table public.tournaments (
  id text primary key,
  name text not null,
  profile_img_url text,
  banner_img_url text,
  type smallint not null,
  created_by uuid not null references public.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  start_date timestamptz not null,
  end_date timestamptz not null
);

create table public.tournament_members (
  id uuid primary key default gen_random_uuid(),
  tournament_id text not null references public.tournaments (id) on delete cascade,
  user_id uuid not null references public.users (id) on delete cascade,
  role text not null default 'admin',
  unique (tournament_id, user_id)
);

create table public.tournament_teams (
  id uuid primary key default gen_random_uuid(),
  tournament_id text not null references public.tournaments (id) on delete cascade,
  team_id text not null references public.teams (id) on delete cascade,
  unique (tournament_id, team_id)
);

create table public.tournament_team_stats (
  id uuid primary key default gen_random_uuid(),
  tournament_id text not null references public.tournaments (id) on delete cascade,
  team_id text not null references public.teams (id) on delete cascade,
  points integer not null default 0,
  wins integer not null default 0,
  losses integer not null default 0,
  nrr numeric(6, 3) not null default 0,
  played_matches integer not null default 0,
  unique (tournament_id, team_id)
);

create table public.tournament_player_key_stats (
  id uuid primary key default gen_random_uuid(),
  tournament_id text not null references public.tournaments (id) on delete cascade,
  player_id uuid not null references public.users (id) on delete cascade,
  team_name text not null,
  stats jsonb not null default '{}',
  tag text,
  value integer
);

create table public.leaderboard_entries (
  id uuid primary key default gen_random_uuid(),
  period text not null,
  field text not null,
  user_id uuid not null references public.users (id) on delete cascade,
  date date not null,
  runs integer not null default 0,
  wickets integer not null default 0,
  catches integer not null default 0,
  unique (period, field, user_id)
);

create table public.contact_support (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  title text not null,
  description text,
  attachment_urls text[] not null default '{}',
  created_at timestamptz not null default now()
);

-- ===================================================================
-- matches
-- ===================================================================
create table public.matches (
  id text primary key,
  tournament_id text references public.tournaments (id) on delete set null,
  match_group smallint,
  match_group_number integer,
  match_type smallint not null,
  number_of_over integer not null,
  over_per_bowler integer not null,
  team_creator_ids uuid[] not null default '{}',
  power_play_overs1 integer[] not null default '{}',
  power_play_overs2 integer[] not null default '{}',
  power_play_overs3 integer[] not null default '{}',
  city text not null,
  ground text not null,
  start_time timestamptz,
  start_at timestamptz,
  ball_type smallint not null,
  pitch_type smallint not null,
  created_by uuid not null references public.users (id) on delete cascade,
  umpire_ids uuid[] not null default '{}',
  scorer_ids uuid[] not null default '{}',
  commentator_ids uuid[] not null default '{}',
  referee_id uuid references public.users (id) on delete set null,
  match_status smallint not null,
  toss_decision smallint,
  toss_winner_id text references public.teams (id) on delete set null,
  current_playing_team_id text references public.teams (id) on delete set null,
  revised_target jsonb,
  updated_at timestamptz not null default now()
);

create index matches_status_idx on public.matches (match_status);
create index matches_start_at_idx on public.matches (start_at);
create index matches_tournament_idx on public.matches (tournament_id);

create table public.match_teams (
  id uuid primary key default gen_random_uuid(),
  match_id text not null references public.matches (id) on delete cascade,
  team_id text not null references public.teams (id) on delete cascade,
  captain_id uuid references public.users (id) on delete set null,
  admin_id uuid references public.users (id) on delete set null,
  over numeric(6, 2) not null default 0,
  run integer not null default 0,
  wicket integer not null default 0,
  unique (match_id, team_id)
);

create table public.match_players (
  id uuid primary key default gen_random_uuid(),
  match_team_id uuid not null references public.match_teams (id) on delete cascade,
  user_id uuid not null references public.users (id) on delete cascade,
  status smallint not null default 3,
  performance jsonb not null default '[]',
  unique (match_team_id, user_id)
);

create table public.match_settings (
  match_id text primary key references public.matches (id) on delete cascade,
  continue_with_injured_player boolean not null default true,
  show_wagon_wheel_for_less_run boolean not null default true,
  show_wagon_wheel_for_dot_ball boolean not null default true
);

-- ===================================================================
-- live scoring
-- ===================================================================
create table public.innings (
  id text primary key,
  match_id text not null references public.matches (id) on delete cascade,
  team_id text not null references public.teams (id) on delete cascade,
  overs numeric(6, 2) not null default 0,
  index integer not null default 0,
  total_runs integer not null default 0,
  total_wickets integer not null default 0,
  innings_status smallint
);

create index innings_match_idx on public.innings (match_id);

create table public.ball_scores (
  id text primary key,
  inning_id text not null references public.innings (id) on delete cascade,
  match_id text not null references public.matches (id) on delete cascade,
  over_number integer not null,
  ball_number integer not null,
  bowler_id uuid not null references public.users (id),
  batsman_id uuid not null references public.users (id),
  non_striker_id uuid not null references public.users (id),
  runs_scored integer not null default 0,
  extras_type smallint,
  extras_awarded integer,
  wicket_type smallint,
  fielding_position smallint,
  player_out_id uuid references public.users (id) on delete set null,
  wicket_taker_id uuid references public.users (id) on delete set null,
  is_four boolean not null default false,
  is_six boolean not null default false,
  time timestamptz,
  score_time timestamptz not null default now()
);

create index ball_scores_inning_idx on public.ball_scores (inning_id);
create index ball_scores_match_idx on public.ball_scores (match_id);

create table public.partnerships (
  id text primary key,
  match_id text not null references public.matches (id) on delete cascade,
  inning_id text not null references public.innings (id) on delete cascade,
  player_ids uuid[] not null default '{}',
  players jsonb not null default '[]',
  runs integer not null default 0,
  extras integer not null default 0,
  ball_faced integer not null default 0,
  start_over numeric(6, 2) not null default 0,
  end_over numeric(6, 2) not null default 0
);

create index partnerships_match_idx on public.partnerships (match_id);

create table public.match_events (
  id text primary key,
  match_id text not null references public.matches (id) on delete cascade,
  inning_id text not null references public.innings (id) on delete cascade,
  type smallint not null,
  time timestamptz not null,
  bowler_id uuid references public.users (id) on delete set null,
  batsman_id uuid references public.users (id) on delete set null,
  fielding_position smallint,
  over numeric(6, 2) not null default 0,
  ball_ids text[] not null default '{}',
  wickets jsonb not null default '[]',
  milestone jsonb not null default '[]'
);

create index match_events_match_idx on public.match_events (match_id);

-- ===================================================================
-- new-user trigger: auth.users row -> public.users profile row
-- ===================================================================
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.users (id, phone)
  values (new.id, new.phone)
  on conflict (id) do nothing;
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
