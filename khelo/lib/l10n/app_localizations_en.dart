// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Khelo';

  @override
  String get common_none_title => 'None';

  @override
  String get common_anonymous_title => 'Anonymous';

  @override
  String get common_delete_title => 'Delete';

  @override
  String get common_cancel_title => 'Cancel';

  @override
  String get common_sign_out_title => 'Sign out';

  @override
  String get common_add_title => 'Add';

  @override
  String get common_edit_title => 'Edit';

  @override
  String get common_remove_title => 'Remove';

  @override
  String get common_reset_title => 'Reset';

  @override
  String get common_okay_title => 'Okay';

  @override
  String get common_save_title => 'Save';

  @override
  String get common_next_title => 'Next';

  @override
  String get common_yes_title => 'Yes';

  @override
  String get common_no_title => 'No';

  @override
  String get common_retry_title => 'Retry';

  @override
  String get common_submit_title => 'Submit';

  @override
  String get common_not_now => 'Not now';

  @override
  String get common_create => 'Create';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_not_specified_title => 'Not Specified';

  @override
  String get commonRunning => 'Running';

  @override
  String get commonFinish => 'Finish';

  @override
  String get commonDeactivatedUser => 'Deactivated User';

  @override
  String common_runs_title(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count runs',
      one: '$count run',
      zero: '$count runs',
    );
    return '$_temp0';
  }

  @override
  String common_wickets_title(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wickets',
      one: '$count wicket',
      zero: '$count wickets',
    );
    return '$_temp0';
  }

  @override
  String common_players_title(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Players',
      one: '$count Player',
      zero: '$count Players',
    );
    return '$_temp0';
  }

  @override
  String get common_tie_title => 'Tie';

  @override
  String get common_wicket_taken_title => ' Wicket taken';

  @override
  String get common_matches_title => 'Matches';

  @override
  String get common_teams_title => 'Teams';

  @override
  String get common_stats_title => 'Stats';

  @override
  String get common_edit_team_title => 'Edit team';

  @override
  String get common_create_team_title => 'Create team';

  @override
  String get common_create_team_description =>
      'Create Your Dream Cricket Team Today!';

  @override
  String get common_your_teams_title => 'Your Teams';

  @override
  String get common_location_title => 'Location';

  @override
  String get common_gender_title => 'Gender';

  @override
  String get common_batting_style_title => 'Batting style';

  @override
  String get common_bowling_style_title => 'Bowling style';

  @override
  String get common_camera_text => 'Camera';

  @override
  String get common_gallery_text => 'Gallery';

  @override
  String get common_versus_short_title => 'VS';

  @override
  String get common_other_title => 'Other';

  @override
  String get common_city_title => 'City';

  @override
  String get common_select_squad_title => 'Select Squad';

  @override
  String get common_power_play_title => 'Power Play Overs';

  @override
  String get common_select_title => 'Select';

  @override
  String get common_a_title => 'A';

  @override
  String get common_m_title => 'M';

  @override
  String get common_batting_average_title => 'Batting Average';

  @override
  String get common_bowling_average_title => 'Bowling Average';

  @override
  String get common_overs_title => 'Overs';

  @override
  String get common_run_out_title => 'Run Out';

  @override
  String get common_wickets_text => 'Wickets';

  @override
  String get common_end_match_title => 'End Match';

  @override
  String get common_first_inning_title => 'First inning';

  @override
  String get common_second_inning_title => 'Second inning';

  @override
  String get common_qr_code_title => 'QR Code';

  @override
  String get common_verify_title => 'Verify';

  @override
  String get common_verified_title => 'Verified';

  @override
  String get common_view_all => 'View all';

  @override
  String get common_today => 'Today';

  @override
  String get common_tomorrow => 'Tomorrow';

  @override
  String get common_owner => 'Owner';

  @override
  String get common_make_admin => 'Make admin';

  @override
  String get common_remove_admin => 'Remove admin';

  @override
  String get common_transfer_ownership => 'Transfer ownership';

  @override
  String get common_tournaments => 'Tournaments';

  @override
  String get common_leaderboard => 'Leaderboard';

  @override
  String get common_batting => 'Batting';

  @override
  String get common_bowling => 'Bowling';

  @override
  String get common_fielding => 'Fielding';

  @override
  String common_obscure_phone_number_text(
      String countryCode, String lastDigits) {
    return '$countryCode ***** ***$lastDigits';
  }

  @override
  String get alert_confirm_default_title => 'Are you sure?';

  @override
  String alert_confirm_default_message(String deleteText) {
    return 'Are you sure you want to $deleteText?';
  }

  @override
  String get error_something_went_wrong =>
      'Something went wrong! Please try again later.';

  @override
  String get error_no_internet =>
      'No internet connection! Please check your network connectivity.';

  @override
  String get no_internet_error_title => 'No internet!';

  @override
  String get no_internet_error_description =>
      'Network error. Please check connection and try again.';

  @override
  String get something_went_wrong_error_title => 'Something went wrong';

  @override
  String get something_went_wrong_error_description =>
      'This is all the information we have, but we won\'t rest until we resolve the issue!';

  @override
  String get intro_get_your_cricket_title => 'Get Your Cricket On!';

  @override
  String get intro_get_your_cricket_description =>
      'Turn backyard games into pro matches with our app. Create matches, manage teams, and track stats!';

  @override
  String get intro_continue_btn_text => 'Continue';

  @override
  String get sign_in_verify_phone_number_title => 'Enter phone number';

  @override
  String get sign_in_verify_phone_number_description =>
      'We’ll verify your phone number with a verification code.';

  @override
  String get sign_in_phone_number_placeholder => '00000 00000';

  @override
  String get sign_in_get_otp_btn_text => 'Get OTP';

  @override
  String get sign_in_invalid_phone_number_text =>
      'Please enter valid phone number';

  @override
  String get otp_verification_verification_title => 'Verification code';

  @override
  String get otp_verification_incorrect_otp_error_text =>
      '*Please enter correct OTP';

  @override
  String get otp_verification_verify_placeholder => '0 0 0 0 0 0';

  @override
  String otp_verification_verification_description(Object phone) {
    return 'We\'ve sent a verification code to your phone $phone';
  }

  @override
  String get home_screen_title => 'Home';

  @override
  String get home_screen_live_title => 'Live';

  @override
  String get home_screen_upcoming_title => 'Upcoming';

  @override
  String get home_screen_finished_title => 'Finished';

  @override
  String get home_screen_set_up_match_title => 'Set up a match in minutes.';

  @override
  String get home_screen_create_match_btn => 'Create match';

  @override
  String get home_screen_set_up_team_title => 'Set up a team in minutes.';

  @override
  String get home_screen_create_team_btn => 'Create team';

  @override
  String get home_screen_set_up_tournament_title =>
      'Set up a tournament in minutes.';

  @override
  String get home_screen_create_tournament_btn => 'Create tournament';

  @override
  String get home_screen_no_matches_title => 'No Matches in this area!';

  @override
  String get home_screen_no_matches_description_text =>
      'Enjoy the freedom of creating your own cricket matches or teams.';

  @override
  String get home_search_hint_title => 'Search matches by team name...';

  @override
  String get home_search_empty_title => 'Start your search here!';

  @override
  String get home_search_empty_message =>
      'Type your search above to find what you need fast.';

  @override
  String get home_search_results_title => 'Results';

  @override
  String get home_search_users_title => 'Users';

  @override
  String get home_search_list_empty_title => 'No results';

  @override
  String get home_search_list_empty_message =>
      'We couldn\'t find any results for your search. Please try different keywords.';

  @override
  String get leaderboard_empty_title => 'Nothing to Show Yet';

  @override
  String get leaderboard_empty_description =>
      'No scores available yet. Make your move and take the lead!';

  @override
  String leaderboard_catches_title(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count catches',
      one: '$count catch',
      zero: '$count catches',
    );
    return '$_temp0';
  }

  @override
  String get notification_popup_title => 'Turn on notifications?';

  @override
  String get notification_popup_description =>
      'Never miss a moment of your matches. \nTurn on notifications for real-time updates and important match information.';

  @override
  String get notification_popup_later => 'Later';

  @override
  String get my_cricket_screen_title => 'My Cricket';

  @override
  String get add_tournament_screen_title => 'Add Tournament';

  @override
  String get add_tournament_name => 'Tournament Name';

  @override
  String get add_tournament_type => 'Tournament Type';

  @override
  String get add_tournament_type_placeholder => 'Select tournament type';

  @override
  String get add_tournament_start_date => 'Start Date';

  @override
  String get add_tournament_end_date => 'End Date';

  @override
  String get add_tournament_team_selection => 'Team selection';

  @override
  String get add_tournament_match_selection => 'Match selection';

  @override
  String get add_tournament_edit_banner => 'Edit banner';

  @override
  String get add_tournament_add_banner_placeholder => 'Add banner image';

  @override
  String get add_tournament_delete_title => 'Delete tournament!';

  @override
  String get add_tournament_delete_description =>
      'This action will permanently delete the tournament, along with all match data. Are you sure you want to delete?';

  @override
  String get add_tournament_date_error =>
      'End date should be greater than start date';

  @override
  String add_tournament_select_min_team_error(Object count) {
    return 'Please select minimum $count teams';
  }

  @override
  String add_tournament_teams_title(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teams',
      one: '$count Team',
      zero: 'No teams',
    );
    return '$_temp0';
  }

  @override
  String get tournament_list_empty_list_title => 'No tournaments created';

  @override
  String get tournament_list_empty_list_description =>
      'Tap on the “ + ” icon to create a tournament';

  @override
  String tournament_list_match_title(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Matches',
      one: '$count Match',
      zero: 'No matches',
    );
    return '$_temp0';
  }

  @override
  String get team_selection_screen_title => 'Select Teams';

  @override
  String get team_selection_select_team_title => 'Select teams';

  @override
  String get team_selection_verify_team_to_add_title => 'Verify teams to add';

  @override
  String get match_selection_screen_title => 'Select Matches';

  @override
  String get match_selection_select_matches_title => 'Select matches';

  @override
  String match_selection_round_title(Object round) {
    return 'Round $round';
  }

  @override
  String get match_selection_no_matches_title => 'No Matches Scheduled Yet';

  @override
  String get match_selection_no_matches_description =>
      'There are currently no matches scheduled. Tap the \'+\' button to schedule new matches.';

  @override
  String match_selection_not_found_title(Object team) {
    return 'No Matches Found for $team';
  }

  @override
  String match_selection_not_found_description(Object team) {
    return 'We couldn’t find any match results for $team at this time. Please check again later.';
  }

  @override
  String get match_group_round_title => 'Round';

  @override
  String get match_group_quarter_final_title => 'Quarter final';

  @override
  String get match_group_semi_final_title => 'Semi final';

  @override
  String get match_group_final_title => 'Final';

  @override
  String get tournament_detail_not_found_title => 'No Tournament found';

  @override
  String get tournament_detail_not_found_description =>
      'The tournament you are looking for is not available.';

  @override
  String tournament_detail_start_from_title(String date) {
    return 'Start from $date';
  }

  @override
  String get tournament_detail_overview_tab => 'Overview';

  @override
  String get tournament_detail_points_table_tab => 'Points Table';

  @override
  String get tournament_detail_edit_title => 'Edit tournament';

  @override
  String get tournament_detail_members_title => 'Members';

  @override
  String get tournament_detail_overview_info_title => 'Tournament info';

  @override
  String get tournament_detail_overview_name_title => 'Tournament Name';

  @override
  String get tournament_detail_overview_type_title => 'Type';

  @override
  String get tournament_detail_overview_duration_title => 'Duration';

  @override
  String get tournament_detail_overview_teams_squads_title => 'Teams Squads';

  @override
  String get tournament_detail_overview_key_stats_title => 'Key Stats';

  @override
  String get tournament_detail_overview_featured_matches_title =>
      'Featured Matches';

  @override
  String get tournament_detail_teams_empty_title => 'Select Your Teams!';

  @override
  String get tournament_detail_teams_empty_description =>
      'You haven\'t added any teams to this tournament yet. Please select or create teams to get started.';

  @override
  String get tournament_detail_teams_select_btn => 'Add teams';

  @override
  String get tournament_detail_matches_empty_title => 'Schedule Your Matches!';

  @override
  String get tournament_detail_matches_empty_description =>
      'Create matches to kick off your tournament and get the games started!';

  @override
  String get tournament_detail_matches_filter_empty_title => 'No Results Found';

  @override
  String get tournament_detail_matches_filter_empty_description =>
      'No matches match the selected filters. Try adjusting them.';

  @override
  String get tournament_detail_matches_add_btn => 'Add matches';

  @override
  String get tournament_detail_matches_filter_by_teams_title =>
      'Filter by teams';

  @override
  String get tournament_detail_matches_filter_all_teams_option => 'All Teams';

  @override
  String get tournament_detail_key_stat_most_runs_title => 'Most Runs';

  @override
  String get tournament_detail_key_stat_most_wickets_title => 'Most Wickets';

  @override
  String get tournament_detail_key_stat_most_fours_title => 'Most Fours';

  @override
  String get tournament_detail_key_stat_most_sixes_title => 'Most Sixes';

  @override
  String get key_stat_all => 'All';

  @override
  String get key_stat_filter_runs => 'Runs';

  @override
  String get key_stat_filter_wickets => 'Wickets';

  @override
  String get key_stat_filter_fours => 'Fours';

  @override
  String get key_stat_filter_sixes => 'Sixes';

  @override
  String get key_stat_filter_most_hundreds => 'Most hundreds';

  @override
  String get key_stat_filter_most_fifties => 'Most fifties';

  @override
  String get key_stat_filter_boundaries => 'Boundaries';

  @override
  String get tournament_detail_points_table_points_title => 'Points';

  @override
  String get tournament_detail_points_table_empty_title => 'No Points Yet!';

  @override
  String get tournament_detail_points_table_empty_description =>
      'The points table will be updated once matches begin. Stay tuned for the latest standings!';

  @override
  String get tournament_detail_points_table_team => 'Team';

  @override
  String get tournament_detail_points_table_wins => 'W';

  @override
  String get tournament_detail_points_table_losses => 'L';

  @override
  String get tournament_detail_points_table_pts => 'Pts';

  @override
  String get tournament_detail_points_table_nrr => 'NRR';

  @override
  String get tournament_detail_stats_empty_title => 'No stats available yet!';

  @override
  String get tournament_detail_stats_empty_description =>
      'The players are warming up! Stay tuned for exciting stats as the team progresses.';

  @override
  String get tournament_detail_stats_empty_filter_title => 'No Stats Found';

  @override
  String get tournament_detail_stats_empty_filter_description =>
      'Please try a different filter.';

  @override
  String get tournament_detail_stats_player_title => 'Player';

  @override
  String get tournament_detail_stats_avg_title => 'Avg';

  @override
  String get tournament_detail_stats_runs_title => 'Runs';

  @override
  String get tournament_members_empty_title => 'No members yet!';

  @override
  String get tournament_members_empty_description =>
      'Tap the + button to add members and start managing your tournament effectively!';

  @override
  String get tournament_members_search_member_empty_title =>
      'Assign Tournament Role';

  @override
  String get tournament_members_search_member_empty_description =>
      'Search for a user to assign a management role. This role will empower them to help organize and lead the tournament effectively.';

  @override
  String get tournament_members_remove_self => 'Remove self';

  @override
  String get tournament_members_make_organizer => 'Make organizer';

  @override
  String get tournament_members_remove_member => 'Remove member';

  @override
  String get tournament_members_transfer_ownership_description =>
      'Search for a user to transfer tournament ownership. This grants them full management control. Choose someone who can effectively lead the tournament.';

  @override
  String get tournament_type_knock_out => 'Knockout';

  @override
  String get tournament_type_mini_robin => 'Mini Robin';

  @override
  String get tournament_type_box_league => 'Box League';

  @override
  String get tournament_type_double_out => 'Double Out';

  @override
  String get tournament_type_best_of_three => 'Best Of three';

  @override
  String get tournament_type_custom => 'Custom';

  @override
  String tournament_type_knock_out_description(Object count) {
    return 'Teams face off in a single elimination, with the loser immediately knocked out.\nMinimum $count teams required.';
  }

  @override
  String tournament_type_mini_robin_description(Object count) {
    return 'A smaller round-robin format where each team plays once against all others.\nMinimum $count teams required.';
  }

  @override
  String tournament_type_box_league_description(Object count) {
    return 'Teams are divided into groups, with top teams advancing to the knockout stage.\nMinimum $count teams required.';
  }

  @override
  String tournament_type_double_out_description(Object count) {
    return 'Teams get two chances before being knocked out, with a winners and losers bracket.\nMinimum $count teams required.';
  }

  @override
  String tournament_type_best_of_three_description(Object count) {
    return 'Teams play a series of matches, and the first to win the majority is the champion.\nMinimum $count teams required.';
  }

  @override
  String tournament_type_custom_description(Object count) {
    return 'Fully flexible, create a structure that suits your needs.\nMinimum $count teams required.';
  }

  @override
  String get add_team_screen_title => 'Add Team';

  @override
  String get add_team_edit_team_screen_title => 'Edit Team';

  @override
  String get add_team_add_as_member_description_text =>
      'Add me as a team member';

  @override
  String get add_team_enter_team_name_placeholder_text => 'Enter team name';

  @override
  String get add_team_team_initial_placeholder_text =>
      'Team initials (e.g. IND, AUS, PBKS)';

  @override
  String get add_team_player_role_title => 'Playing role';

  @override
  String get add_team_players_text => 'Players';

  @override
  String get add_team_already_added => 'Team already added';

  @override
  String get add_team_add_hint_text =>
      'Added user will be shown here, tap on \'+\' button to add team member.';

  @override
  String get scan_qr_code => 'Scan QR code';

  @override
  String get scan_qr_code_description => 'Place the QR code into the frame';

  @override
  String get scan_qr_permission_title =>
      'Allow camera access to use scanning features';

  @override
  String get scan_qr_permission_description =>
      'Please enable camera access in your device settings to use the scanning feature.';

  @override
  String get scan_qr_permission_settings => 'Go to settings';

  @override
  String get add_team_member_screen_title => 'Add Team Member';

  @override
  String get add_team_member_details_title => 'Details';

  @override
  String get add_team_member_search_placeholder_text => 'Search member name';

  @override
  String get add_team_member_empty_title => 'Your cricket crew awaits!';

  @override
  String get add_team_member_empty_description_text =>
      'The pitch is set, but you need your players. Find them with a quick search.';

  @override
  String get add_team_member_search_no_result_title => 'Oops! No User Found';

  @override
  String get add_team_member_search_description_text =>
      'It seems we don\'t have anyone by that name. Give another name a go!';

  @override
  String get add_team_member_added_text => 'ADDED';

  @override
  String get add_team_member_already_added => 'Member already added';

  @override
  String get add_team_member_verify_error_text => 'Please enter correct digits';

  @override
  String add_team_member_verify_placeholder_text(int count) {
    return 'Enter the last $count digits of the phone number of the selected player.';
  }

  @override
  String get team_list_add_members_title => 'Add Members';

  @override
  String get team_list_all_teams_title => 'All teams';

  @override
  String get team_list_created_by_me_title => 'Created by me';

  @override
  String get team_list_me_as_member_title => 'Me as member';

  @override
  String get team_list_me_as_admin_title => 'Me as admin';

  @override
  String get team_list_no_teams_created_title => 'No teams created';

  @override
  String get team_list_empty_list_description =>
      'Tap on the “ + ” icon to create a team';

  @override
  String get match_list_no_match_here_title => 'No matches here';

  @override
  String get match_list_empty_list_description =>
      'Tap on the “ + ” icon to create a match';

  @override
  String match_list_overs_title(int overs) {
    String _temp0 = intl.Intl.pluralLogic(
      overs,
      locale: localeName,
      other: '$overs overs',
      one: '$overs over',
      zero: '$overs overs',
    );
    return '$_temp0';
  }

  @override
  String get add_match_screen_title => 'Add Match';

  @override
  String get add_match_screen_edit_match_title => 'Edit Match';

  @override
  String get add_match_team_b_title => 'B';

  @override
  String get add_match_team_name_placeholder => 'Team Name';

  @override
  String get add_match_match_type_title => 'Match Type';

  @override
  String get add_match_match_type_limited_overs_title => 'Limited overs';

  @override
  String get add_match_match_type_test_match_title => 'Test match';

  @override
  String get add_match_match_type_the_hundred_title => 'The hundred';

  @override
  String get add_match_match_type_pair_cricket_title => 'Pair cricket';

  @override
  String get add_match_match_type_box_cricket_title => 'Box cricket';

  @override
  String get add_match_ball_type_title => 'Ball Type';

  @override
  String get add_match_ball_type_leather_title => 'Leather';

  @override
  String get add_match_ball_type_tennis_title => 'Tennis';

  @override
  String get add_match_pitch_type_title => 'Pitch Type';

  @override
  String get add_match_pitch_type_rough_title => 'Rough';

  @override
  String get add_match_pitch_type_cement_title => 'Cement';

  @override
  String get add_match_pitch_type_turf_title => 'Turf';

  @override
  String get add_match_pitch_type_astroturf_title => 'Astroturf';

  @override
  String get add_match_pitch_type_matting_title => 'Matting';

  @override
  String get add_match_match_officials_title => 'Match Officials';

  @override
  String get add_match_officials_umpires_title => 'Umpires';

  @override
  String get add_match_officials_scorers_title => 'Scorers';

  @override
  String get add_match_officials_live_streamers_title => 'Live Streamers';

  @override
  String get add_match_officials_referee_title => 'Referee';

  @override
  String get add_match_officials_commentators_title => 'Commentators';

  @override
  String get add_match_officials_others_title => 'Others';

  @override
  String get add_match_ground_title => 'Ground';

  @override
  String get add_match_match_schedule_title => 'Match Schedule';

  @override
  String get add_match_start_match_title => 'Start Match';

  @override
  String get add_match_date_title => 'Date';

  @override
  String get add_match_time_title => 'Time';

  @override
  String get add_match_no_of_over_title => 'No. of over';

  @override
  String get add_match_over_per_bowler_title => 'Over per bowler';

  @override
  String get add_match_joined_on_title => 'Joined on';

  @override
  String get add_match_officials_screen_title => 'Add Match Officials';

  @override
  String get add_match_officials_add_officials_title => 'Add officials';

  @override
  String get add_match_invalid_over_count_error =>
      'Please enter valid total over';

  @override
  String get add_match_empty_fields_error => 'Please fill the required details';

  @override
  String get add_match_unselected_team_error => 'Please select teams';

  @override
  String get add_match_invalid_squad_error => 'Please select valid squad';

  @override
  String get search_user_hint_title => 'Search user name';

  @override
  String get search_user_empty_title => 'Time to gather your officials!';

  @override
  String get search_user_empty_description_text =>
      'Search and assign officials for your next match. Get ready for cricket action!';

  @override
  String get search_team_screen_title => 'Search Team';

  @override
  String get search_team_selection_error_text =>
      'The team must have at least 2 players to add it in a match.';

  @override
  String get search_team_search_placeholder_title => 'Search team name';

  @override
  String power_play_text(int count) {
    return 'Power play $count';
  }

  @override
  String get select_squad_select_admin_captain_title =>
      'Select Captain and Admin';

  @override
  String get select_squad_captain_short_title => 'C';

  @override
  String get select_squad_playing_squad_title => 'Playing Squad';

  @override
  String get select_squad_least_require_text =>
      '*At-least two players required';

  @override
  String get select_squad_rest_of_team_title => 'Rest of The Team';

  @override
  String get select_squad_empty_squad_text =>
      'Select squad via adding it from team members list.';

  @override
  String get select_squad_empty_team_member_text =>
      'No team member added in this team, try to add people you know as a team member.';

  @override
  String get add_toss_detail_screen_title => 'Add Toss Detail';

  @override
  String get add_toss_detail_who_won_toss_text => 'Who won the toss?';

  @override
  String get add_toss_detail_winner_elected_to_text =>
      'Toss-winner elected to - ?';

  @override
  String get add_substitute_search_substitute_title =>
      'Who’s ready to step in?';

  @override
  String get add_substitute_search_substitute_description =>
      'Search and assign a substitute fielder to maintain your fielding edge.';

  @override
  String get team_detail_screen_title => 'Team Detail';

  @override
  String get team_detail_member_tab_title => 'Member';

  @override
  String get team_detail_empty_matches_title => 'No matches scheduled yet!';

  @override
  String get team_detail_empty_matches_description_text =>
      'Get your cricket game on! Schedule your cricket match with ease!';

  @override
  String get team_detail_visitor_empty_matches_description_text =>
      'Until now, the team has not competed.';

  @override
  String get team_detail_empty_member_title => 'You haven\'t any member!';

  @override
  String get team_detail_empty_member_description_text =>
      'Invite your friends to build your dream team and start tracking matches together.';

  @override
  String get team_detail_visitor_empty_member_description_text =>
      'No member has been added to the team.';

  @override
  String get team_detail_empty_stat_title => 'No stats available yet!';

  @override
  String get team_detail_empty_stat_description_text =>
      'The players are warming up! Stay tuned for exciting stats as the team progresses.';

  @override
  String get team_detail_add_members_title => 'Add members';

  @override
  String get team_detail_add_match_title => 'Add match';

  @override
  String get team_detail_use_qr_description =>
      'Use your phone camera or a QR code app to scan the code above and easily add the team to the tournament';

  @override
  String get make_admin_selection_error =>
      'Can\'t select deactivated user as admin';

  @override
  String team_detail_admin(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count admins',
      one: '$count admin',
      zero: '$count admins',
    );
    return '$_temp0';
  }

  @override
  String get team_detail_remove_ownership_title => 'Remove ownership';

  @override
  String get team_detail_transfer_ownership_description =>
      'Search for a user to transfer team ownership. This grants them full management control. Choose someone who can effectively lead the team.';

  @override
  String get team_detail_match_tab_title => 'Match';

  @override
  String get team_detail_stat_tab_title => 'Stat';

  @override
  String team_detail_won_title(int win) {
    return 'Won($win)';
  }

  @override
  String team_detail_lost_title(int lost) {
    return 'Lost($lost)';
  }

  @override
  String team_detail_tie_title(int tie) {
    return 'Tie($tie)';
  }

  @override
  String team_detail_match_title(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Matches',
      one: '$count Match',
      zero: '$count Matches',
    );
    return '$_temp0';
  }

  @override
  String get team_detail_runs_made_title => 'Runs Made';

  @override
  String get team_detail_wickets_taken_title => 'Wickets Taken';

  @override
  String get team_detail_highest_runs_title => 'Highest Runs';

  @override
  String get team_detail_lowest_runs_title => 'Lowest Runs';

  @override
  String get team_detail_run_rate_title => 'Run Rate';

  @override
  String get user_detail_info_title => 'Info';

  @override
  String get user_detail_personal_information_title => 'Personal information';

  @override
  String get user_detail_participation_title => 'Participation';

  @override
  String get user_detail_role_title => 'Role';

  @override
  String get user_detail_joining_date_title => 'Joining date';

  @override
  String get user_detail_test_title => 'Test';

  @override
  String get user_detail_matches_title => 'Matches';

  @override
  String get user_detail_innings_title => 'Innings';

  @override
  String get user_detail_runs_title => 'Runs';

  @override
  String get user_detail_balls_title => 'Balls';

  @override
  String get user_detail_average_title => 'Average';

  @override
  String get user_detail_strike_rate_title => 'SR';

  @override
  String get user_detail_fours_title => 'Fours';

  @override
  String get user_detail_sixes_title => 'Sixes';

  @override
  String get user_detail_fifties_title => '50s';

  @override
  String get user_detail_hundreds_title => '100s';

  @override
  String get user_detail_ducks_title => 'Ducks';

  @override
  String get user_detail_maidens_title => 'Maidens';

  @override
  String get user_detail_wickets_title => 'Wickets';

  @override
  String get user_detail_eco_title => 'Eco';

  @override
  String get user_detail_no_ball_title => 'NB';

  @override
  String get user_detail_wide_ball_title => 'WB';

  @override
  String get user_detail_catches_title => 'Catches';

  @override
  String get user_detail_run_out_title => 'Run out';

  @override
  String get user_detail_stumping_title => 'Stumping';

  @override
  String get match_status_yet_to_start_title => 'Yet to start';

  @override
  String get match_status_abandoned_title => 'Abandoned';

  @override
  String get wicket_type_bowled_title => 'Bowled';

  @override
  String get wicket_type_caught_title => 'Caught';

  @override
  String get wicket_type_caught_behind_title => 'Caught Behind';

  @override
  String get wicket_type_caught_bowled_title => 'Caught And Bowled';

  @override
  String get wicket_type_leg_before_wicket_title => 'Leg Before Wicket';

  @override
  String get wicket_type_stumped_title => 'Stumped';

  @override
  String get wicket_type_hit_wicket_title => 'Hit Wicket';

  @override
  String get wicket_type_hit_ball_twice_title => 'Hit Ball Twice';

  @override
  String get wicket_type_handled_ball_title => 'Handled Ball';

  @override
  String get wicket_type_obstructing_field_title => 'Obstructing the Field';

  @override
  String get wicket_type_timed_out_title => 'Timed Out';

  @override
  String get wicket_type_retired_title => 'Retired';

  @override
  String get wicket_type_retired_hurt_title => 'Retired Hurt';

  @override
  String get wicket_type_short_timed_out_title => 'TO';

  @override
  String get wicket_type_short_retired_title => 'RT';

  @override
  String get wicket_type_short_retired_hurt_title => 'RTH';

  @override
  String get match_detail_screen_title => 'Match Detail';

  @override
  String get match_detail_commentary_tab_title => 'Commentary';

  @override
  String get match_detail_scorecard_tab_title => 'Scorecard';

  @override
  String get match_detail_squad_tab_title => 'Squad';

  @override
  String get match_detail_match_info_tab_title => 'Info';

  @override
  String get match_detail_highlight_tab_title => 'Highlight';

  @override
  String get match_detail_overs_tab_title => 'Overs';

  @override
  String get match_detail_match_not_started_error_title =>
      'Match has not started yet.';

  @override
  String get match_detail_error_description_text =>
      'The detailed will be available after the start of the match.';

  @override
  String get match_detail_highlight_empty_title =>
      'No highlights currently available.';

  @override
  String get match_detail_highlight_empty_description_text =>
      'No events recorded yet. Check back later for updates and highlights.';

  @override
  String get match_info_match_title => 'Match';

  @override
  String get match_info_date_title => 'Date';

  @override
  String get match_info_toss_title => 'Toss';

  @override
  String get match_info_time_title => 'Time';

  @override
  String get match_info_umpire_title => 'Umpire';

  @override
  String get match_info_referee_title => 'Referee';

  @override
  String get match_info_date_and_time_title => 'Date & Time';

  @override
  String match_info_squad_title(String name) {
    return '$name Squad';
  }

  @override
  String get match_info_venue_title => 'Venue';

  @override
  String get match_info_ground_title => 'Ground';

  @override
  String get match_info_city_title => 'City';

  @override
  String get match_info_captain_short_title => '(c)';

  @override
  String match_info_toss_detail_text(String name, String decision) {
    return '$name won the toss and opt to $decision';
  }

  @override
  String match_commentary_bowler_to_batsman_text(
      String bowler, String batsman) {
    return '$bowler to $batsman';
  }

  @override
  String match_commentary_b_bowler_text(String bowler) {
    return ' b $bowler';
  }

  @override
  String match_commentary_c_fielder_text(String fielder) {
    return ' c $fielder';
  }

  @override
  String match_commentary_by_fielder_text(String fielder) {
    return ' by $fielder';
  }

  @override
  String match_commentary_runs_fours_sixes_text(
      int run, int ballCount, int fours, int sixes) {
    return ' $run($ballCount) [4s-$fours 6s-$sixes]';
  }

  @override
  String match_commentary_runs_text(int run) {
    String _temp0 = intl.Intl.pluralLogic(
      run,
      locale: localeName,
      other: '$run runs',
      one: '$run run',
      zero: 'no runs',
    );
    return '$_temp0';
  }

  @override
  String match_commentary_former_over_short_text(int over) {
    return 'Ov $over';
  }

  @override
  String get match_commentary_four_text => 'Four';

  @override
  String get match_commentary_six_text => 'Six';

  @override
  String get match_commentary_out_text => 'OUT,';

  @override
  String get match_commentary_back_to_attack_text => ' is back to attack';

  @override
  String get match_commentary_end_inning_text_part_1 =>
      ' wraps up their innings, leaving ';

  @override
  String get match_commentary_end_inning_text_part_2 => ' for victory.';

  @override
  String match_commentary_inning_count_text(int count) {
    return 'Inning $count';
  }

  @override
  String get match_scorecard_fall_of_wicket_text => 'Fall of Wicket';

  @override
  String get match_scorecard_over_text => 'Over';

  @override
  String get match_scorecard_run_text => 'Run';

  @override
  String get match_scorecard_power_play_text => 'PowerPlay';

  @override
  String get match_scorecard_run_short_text => 'R';

  @override
  String get match_scorecard_ball_short_text => 'B';

  @override
  String get match_scorecard_fours_short_text => '4s';

  @override
  String get match_scorecard_sixes_short_text => '6s';

  @override
  String get match_scorecard_strike_rate_short_text => 'SR';

  @override
  String get match_scorecard_over_short_text => 'O';

  @override
  String get match_scorecard_maiden_short_text => 'M';

  @override
  String get match_scorecard_wicket_short_text => 'W';

  @override
  String get match_scorecard_no_ball_short_text => 'NB';

  @override
  String get match_scorecard_wide_ball_short_text => 'WB';

  @override
  String get match_scorecard_economy_short_text => 'ECO';

  @override
  String get match_scorecard_batter_text => 'Batter';

  @override
  String get match_scorecard_bowler_text => 'Bowler';

  @override
  String get match_scorecard_not_out_text => 'Not out';

  @override
  String get match_scorecard_did_not_bat_text => 'Did not bat';

  @override
  String match_scorecard_bowler_catcher_short_text(
      String bowler, String fielder) {
    return 'b $bowler c $fielder';
  }

  @override
  String get match_scorecard_extra_text => 'Extra';

  @override
  String get match_scorecard_total_text => 'Total';

  @override
  String get match_scorecard_empty_scorecard_text =>
      'Scorecard will appear once the match starts';

  @override
  String match_scorecard_extras_short_text(
      int bye, int legBye, int wide, int noBall, int penalty) {
    return 'b $bye lb $legBye w $wide  nb $noBall p $penalty';
  }

  @override
  String match_scorecard_wicket_over_text(int wicket, double over) {
    String _temp0 = intl.Intl.pluralLogic(
      wicket,
      locale: localeName,
      other: '$wicket wickets',
      one: '$wicket wicket',
      zero: 'no wickets',
    );
    return '$_temp0 $over over';
  }

  @override
  String match_commentary_trailing_over_short_text(double over) {
    return '($over Ov)';
  }

  @override
  String get match_squad_playing_title => 'Playing';

  @override
  String get match_squad_bench_title => 'Bench';

  @override
  String get match_highlight_filter_all_text => 'All';

  @override
  String get match_highlight_filter_fours_text => 'Fours';

  @override
  String get match_highlight_filter_sixes_text => 'Sixes';

  @override
  String get score_board_screen_title => 'Score Board';

  @override
  String get score_board_wicket_short_text => 'W';

  @override
  String get score_board_no_ball_short_text => 'NB';

  @override
  String get score_board_wide_ball_short_text => 'WB';

  @override
  String get score_board_leg_bye_short_text => 'L';

  @override
  String get score_board_bye_short_text => 'B';

  @override
  String get score_board_zero_text => '0';

  @override
  String get score_board_one_text => '1';

  @override
  String get score_board_two_text => '2';

  @override
  String get score_board_three_text => '3';

  @override
  String get score_board_four_text => '4';

  @override
  String get score_board_four_title => 'Four';

  @override
  String get score_board_six_text => '6';

  @override
  String get score_board_six_title => 'Six';

  @override
  String get score_board_five_or_seven_text => '5, 7';

  @override
  String get score_board_five_text => '5';

  @override
  String get score_board_seven_text => '7';

  @override
  String get score_board_out_text => 'OUT';

  @override
  String get score_board_wicket_text => 'WICKET';

  @override
  String get score_board_leg_bye_text => 'LB';

  @override
  String get score_board_bye_text => 'BYE';

  @override
  String get score_board_undo_title => 'Undo';

  @override
  String get score_board_player_title => 'Player';

  @override
  String get score_board_extras_title => 'Extras';

  @override
  String get score_board_runs_title => 'Runs';

  @override
  String get score_board_not_from_bat_text => 'Not from bat?';

  @override
  String get score_board_is_boundary_text => 'Is that a boundary?';

  @override
  String get score_board_over_complete_title => 'Over complete';

  @override
  String get score_board_inning_complete_title => 'Inning complete';

  @override
  String get score_board_match_complete_title => 'Match complete';

  @override
  String get score_board_match_tied_text => 'The match has been tied';

  @override
  String get score_board_match_tied => 'Match tied';

  @override
  String get score_board_start_next_inning_title => 'Start Next Inning';

  @override
  String get score_board_end_inning_title => 'End Inning';

  @override
  String get score_board_current_team_title => 'Current Team';

  @override
  String get score_board_team_title => 'Team';

  @override
  String get score_board_r_title => 'R';

  @override
  String get score_board_w_title => 'W';

  @override
  String get score_board_o_title => 'O';

  @override
  String get score_board_won_by_title => ' Won By ';

  @override
  String get score_board_won_title => 'Won';

  @override
  String get score_board_by_title => 'by';

  @override
  String get score_board_choose_opening_batsmen_title =>
      'Choose opening Batsmen';

  @override
  String get score_board_choose_fielder_title => 'Choose fielder';

  @override
  String get score_board_injured_tag_title => 'Injured';

  @override
  String get score_board_who_on_strike_title => 'Who\'s on Strike?';

  @override
  String get score_board_who_got_out_title => 'Who got out';

  @override
  String get score_board_start_next_over_title => 'Start Next Over';

  @override
  String get score_board_batsman_title => 'batsMan';

  @override
  String get score_board_bowler_title => 'bowler';

  @override
  String get score_board_change_striker_title => 'Change striker';

  @override
  String get score_board_option_end_match => 'End match';

  @override
  String get score_board_option_handover_scoring => 'Handover scoring';

  @override
  String get score_board_handover_scoring_empty_title =>
      'Handover scoring control';

  @override
  String get score_board_handover_scoring_empty_description =>
      'Find and select another user to hand over the scoring responsibilities. Keep the game flowing with a quick and easy transfer.';

  @override
  String get score_board_can_undo_till_running_over_title =>
      'Undo is only allowed till running over';

  @override
  String get score_board_undo_last_ball_title => 'Undo Last Ball';

  @override
  String get score_board_undo_last_ball_description_text =>
      'are you sure you want to undo last ball?';

  @override
  String get score_board_pause_scoring_title => 'Pause scoring';

  @override
  String get score_board_add_substitute_title => 'Add substitute';

  @override
  String get score_board_substitute_title => 'Substitute';

  @override
  String get score_board_penalty_run_title => 'Penalty run';

  @override
  String get score_board_awarded_to_text => 'Awarded to - ?';

  @override
  String get score_board_continue_with_injured_player_title =>
      'Continue with injured player';

  @override
  String get score_board_show_wheel_for_less_run_title =>
      'Show wheel for 1s, 2s and 3s';

  @override
  String get score_board_show_wheel_for_dot_ball_title =>
      'Show wheel for dot balls';

  @override
  String get score_board_select_fielding_position_title =>
      'Select fielding position';

  @override
  String get score_board_pause_title => 'Pause';

  @override
  String get score_board_revised_target_title => 'Revised target';

  @override
  String get score_board_enter_manual_target_text =>
      'Enter your manually calculated target';

  @override
  String get score_board_runs_text => 'Runs :';

  @override
  String get score_board_in_overs_text => 'in Overs :';

  @override
  String get score_board_confirm_target_text => 'Confirm target';

  @override
  String score_board_current_target_text(num run, num over) {
    String _temp0 = intl.Intl.pluralLogic(
      run,
      locale: localeName,
      other: '$run runs',
      one: '$run run',
      zero: '$run runs',
    );
    String _temp1 = intl.Intl.pluralLogic(
      over,
      locale: localeName,
      other: '$over overs',
      one: '$over over',
      zero: '$over overs',
    );
    return 'Current target is $_temp0 in $_temp1';
  }

  @override
  String get score_board_target_invalid_input_error =>
      'Please enter valid target';

  @override
  String get score_board_pause_scoring_description_text =>
      'are you sure you want to pause scoring?';

  @override
  String get score_board_end_match_description_text =>
      'are you sure you want to end match?';

  @override
  String score_board_run_sup_script_text(String run, Object extra) {
    String _temp0 = intl.Intl.selectLogic(
      run,
      {
        '1': '$extra',
        '2': '$extra²',
        '3': '$extra³',
        '4': '$extra⁴',
        '5': '$extra⁵',
        '6': '$extra⁶',
        '7': '$extra⁷',
        '8': '$extra⁸',
        '9': '$extra⁹',
        'other': '$extra',
      },
    );
    return '$_temp0';
  }

  @override
  String score_board_choose_batsman_title(int pos) {
    return 'Choose Batsman at position $pos';
  }

  @override
  String score_board_choose_bowler_for_over_title(int over) {
    return 'Choose Bowler for over $over';
  }

  @override
  String score_board_end_of_over_by_title(int overNumber, String player) {
    return 'End Of Over $overNumber by $player';
  }

  @override
  String score_board_need_run_text(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Runs',
      one: '$count Run',
      zero: '$count Runs',
    );
    return 'Need $_temp0';
  }

  @override
  String score_board_run_need_in_ball_text(int run, int ball) {
    return 'Need $run in $ball';
  }

  @override
  String get fielding_position_deep_mid_wicket_title => 'Deep mid wicket';

  @override
  String get fielding_position_long_on_title => 'Long on';

  @override
  String get fielding_position_long_off_title => 'Long off';

  @override
  String get fielding_position_deep_cover_title => 'Deep cover';

  @override
  String get fielding_position_deep_point_title => 'Deep point';

  @override
  String get fielding_position_third_man_title => 'Third man';

  @override
  String get fielding_position_deep_fine_leg_title => 'Deep fine leg';

  @override
  String get fielding_position_deep_square_leg_title => 'Deep square leg';

  @override
  String get side_off_title => 'OFF';

  @override
  String get side_leg_title => 'LEG';

  @override
  String get tab_profile_title => 'Profile';

  @override
  String get edit_profile_create_profile_screen_title => 'Create Profile';

  @override
  String get edit_profile_screen_title => 'Edit Profile';

  @override
  String get edit_profile_select_birth_date_placeholder =>
      'Select your date of birth';

  @override
  String get edit_profile_name_placeholder => 'Name';

  @override
  String get edit_profile_email_placeholder => 'Email';

  @override
  String get edit_profile_dob_placeholder => 'Date of birth';

  @override
  String get edit_profile_player_role_placeholder => 'Player role';

  @override
  String get edit_profile_gender_male_title => 'Male';

  @override
  String get edit_profile_gender_female_title => 'Female';

  @override
  String get edit_profile_gender_prefer_not_to_say_title => 'Prefer not to say';

  @override
  String get edit_profile_delete_account_btn_title => 'Delete account';

  @override
  String get edit_profile_delete_account_description_text =>
      'This can not undone. if you delete your account, your data will be gone forever.';

  @override
  String get transfer_teams_title => 'Before You Go...';

  @override
  String get transfer_teams_description =>
      'We\'re sorry to see you go. Before deleting your account, please:\n• Assign new owners and admins for your teams or delete the teams\n• Transfer scoring for ongoing matches\n• Remove any scheduled matches\n•Transfer or assign responsibilities for ongoing tournaments\nThis will ensure everything is properly managed after you leave.';

  @override
  String get transfer_teams_go_to_my_cricket => 'Go to My Cricket';

  @override
  String get profile_settings_title => 'Settings';

  @override
  String get profile_setting_contact_support => 'Contact support';

  @override
  String get profile_setting_privacy_policy_title => 'Privacy policy';

  @override
  String get profile_setting_terms_and_condition_title => 'Terms and condition';

  @override
  String get profile_setting_share_app_title => 'Share app';

  @override
  String get profile_setting_rate_us_title => 'Rate us';

  @override
  String profile_setting_app_version_text(Object version) {
    return 'App Version: $version';
  }

  @override
  String get profile_setting_scan_to_play_text => 'Scan to play!';

  @override
  String get profile_setting_scan_to_play_description =>
      'This QR code allows you to easily add the player to the team.';

  @override
  String get profile_setting_use_scanner_description =>
      'Use your phone camera or a QR code app to scan the code above and easily add the player to the team.';

  @override
  String profile_setting_share_app_message(String androidLink, String iosLink) {
    return 'Elevate your cricket scoring game with Khelo! 🏏\n\nEffortlessly score matches, track stats, and manage your teams.\n\n👉 Download Now:\n📱 Android: $androidLink\n🍎 iOS: $iosLink\n\nStart scoring smarter today!';
  }

  @override
  String get notification_title => 'Notifications';

  @override
  String get notification_turn_on_title =>
      'It seems that your notifications have been turned off. Turn on notifications to stay updated on your teams and matches.';

  @override
  String get notification_turn_on_btn_title => 'Turn on';

  @override
  String get contact_support_screen_title => 'Contact Support';

  @override
  String get contact_support_title_placeholder_text => 'Title';

  @override
  String get contact_support_description_placeholder_text => 'Description...';

  @override
  String get contact_support_attachment => 'Attachment (if any)';

  @override
  String get large_attachment_upload_error_text =>
      'Oops! Your file exceeds the maximum allowed size of 25 MB. Please choose a smaller file and try again.';

  @override
  String get profile_complete_your_profile_title => 'Complete your profile';

  @override
  String get profile_complete_description_title =>
      'Enhance your profile with more details to make it better!';

  @override
  String get profile_complete_add_profile_picture => 'Add profile picture';

  @override
  String get profile_complete_add_personal_details => 'Add personal details';

  @override
  String get profile_complete_add_playing_style => 'Add playing style';

  @override
  String get image_picker_choose_option_title => 'Choose an option';

  @override
  String get image_picker_camera_option_text => 'Camera';

  @override
  String get image_picker_gallery_option_text => 'Gallery';

  @override
  String get image_picker_crop_image_title => 'Crop Image';

  @override
  String get batting_style_right_hand_bat_title => 'Right hand bat';

  @override
  String get batting_style_left_hand_bat_title => 'Left hand bat';

  @override
  String get bowling_style_right_arm_fast_title => 'Right arm fast';

  @override
  String get bowling_style_right_arm_medium_title => 'Right arm medium';

  @override
  String get bowling_style_left_arm_fast_title => 'Left arm fast';

  @override
  String get bowling_style_left_arm_medium_title => 'Left arm medium';

  @override
  String get bowling_style_slow_left_arm_orthodox_title =>
      'Slow left arm orthodox';

  @override
  String get bowling_style_slow_left_arm_chinaman_title =>
      'Slow left arm chinaman';

  @override
  String get bowling_style_right_arm_off_break_title => 'Right arm off break';

  @override
  String get bowling_style_right_arm_leg_break_title => 'Right arm leg break';

  @override
  String get player_role_top_order_batter_title => 'Top order batter';

  @override
  String get player_role_middle_order_batter_title => 'Middle order batter';

  @override
  String get player_role_wicket_keeper_batter_title => 'Wicket keeper batter';

  @override
  String get player_role_wicket_keeper_title => 'Wicket keeper';

  @override
  String get player_role_bowler_title => 'Bowler';

  @override
  String get player_role_all_rounder_title => 'All rounder';

  @override
  String get player_role_lower_order_batter_title => 'Lower order batter';

  @override
  String get player_role_opening_batter_title => 'Opening batter';
}
