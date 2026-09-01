import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Khelo'**
  String get app_title;

  /// No description provided for @common_none_title.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get common_none_title;

  /// No description provided for @common_anonymous_title.
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get common_anonymous_title;

  /// No description provided for @common_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete_title;

  /// No description provided for @common_cancel_title.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel_title;

  /// No description provided for @common_sign_out_title.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get common_sign_out_title;

  /// No description provided for @common_add_title.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add_title;

  /// No description provided for @common_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit_title;

  /// No description provided for @common_remove_title.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get common_remove_title;

  /// No description provided for @common_reset_title.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get common_reset_title;

  /// No description provided for @common_okay_title.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get common_okay_title;

  /// No description provided for @common_save_title.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save_title;

  /// No description provided for @common_next_title.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next_title;

  /// No description provided for @common_yes_title.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes_title;

  /// No description provided for @common_no_title.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no_title;

  /// No description provided for @common_retry_title.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry_title;

  /// No description provided for @common_submit_title.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get common_submit_title;

  /// No description provided for @common_not_now.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get common_not_now;

  /// No description provided for @common_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get common_create;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_not_specified_title.
  ///
  /// In en, this message translates to:
  /// **'Not Specified'**
  String get common_not_specified_title;

  /// No description provided for @commonRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get commonRunning;

  /// No description provided for @commonFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get commonFinish;

  /// No description provided for @commonDeactivatedUser.
  ///
  /// In en, this message translates to:
  /// **'Deactivated User'**
  String get commonDeactivatedUser;

  /// No description provided for @common_runs_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{count} runs} =1{{count} run} other{{count} runs}}'**
  String common_runs_title(num count);

  /// No description provided for @common_wickets_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{count} wickets} =1{{count} wicket} other{{count} wickets}}'**
  String common_wickets_title(num count);

  /// No description provided for @common_players_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{count} Players} =1{{count} Player} other{{count} Players}}'**
  String common_players_title(num count);

  /// No description provided for @common_tie_title.
  ///
  /// In en, this message translates to:
  /// **'Tie'**
  String get common_tie_title;

  /// No description provided for @common_wicket_taken_title.
  ///
  /// In en, this message translates to:
  /// **' Wicket taken'**
  String get common_wicket_taken_title;

  /// No description provided for @common_matches_title.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get common_matches_title;

  /// No description provided for @common_teams_title.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get common_teams_title;

  /// No description provided for @common_stats_title.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get common_stats_title;

  /// No description provided for @common_edit_team_title.
  ///
  /// In en, this message translates to:
  /// **'Edit team'**
  String get common_edit_team_title;

  /// No description provided for @common_create_team_title.
  ///
  /// In en, this message translates to:
  /// **'Create team'**
  String get common_create_team_title;

  /// No description provided for @common_create_team_description.
  ///
  /// In en, this message translates to:
  /// **'Create Your Dream Cricket Team Today!'**
  String get common_create_team_description;

  /// No description provided for @common_your_teams_title.
  ///
  /// In en, this message translates to:
  /// **'Your Teams'**
  String get common_your_teams_title;

  /// No description provided for @common_location_title.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get common_location_title;

  /// No description provided for @common_gender_title.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get common_gender_title;

  /// No description provided for @common_batting_style_title.
  ///
  /// In en, this message translates to:
  /// **'Batting style'**
  String get common_batting_style_title;

  /// No description provided for @common_bowling_style_title.
  ///
  /// In en, this message translates to:
  /// **'Bowling style'**
  String get common_bowling_style_title;

  /// No description provided for @common_camera_text.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get common_camera_text;

  /// No description provided for @common_gallery_text.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get common_gallery_text;

  /// No description provided for @common_versus_short_title.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get common_versus_short_title;

  /// No description provided for @common_other_title.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get common_other_title;

  /// No description provided for @common_city_title.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get common_city_title;

  /// No description provided for @common_select_squad_title.
  ///
  /// In en, this message translates to:
  /// **'Select Squad'**
  String get common_select_squad_title;

  /// No description provided for @common_power_play_title.
  ///
  /// In en, this message translates to:
  /// **'Power Play Overs'**
  String get common_power_play_title;

  /// No description provided for @common_select_title.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get common_select_title;

  /// No description provided for @common_a_title.
  ///
  /// In en, this message translates to:
  /// **'A'**
  String get common_a_title;

  /// No description provided for @common_m_title.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get common_m_title;

  /// No description provided for @common_batting_average_title.
  ///
  /// In en, this message translates to:
  /// **'Batting Average'**
  String get common_batting_average_title;

  /// No description provided for @common_bowling_average_title.
  ///
  /// In en, this message translates to:
  /// **'Bowling Average'**
  String get common_bowling_average_title;

  /// No description provided for @common_overs_title.
  ///
  /// In en, this message translates to:
  /// **'Overs'**
  String get common_overs_title;

  /// No description provided for @common_run_out_title.
  ///
  /// In en, this message translates to:
  /// **'Run Out'**
  String get common_run_out_title;

  /// No description provided for @common_wickets_text.
  ///
  /// In en, this message translates to:
  /// **'Wickets'**
  String get common_wickets_text;

  /// No description provided for @common_end_match_title.
  ///
  /// In en, this message translates to:
  /// **'End Match'**
  String get common_end_match_title;

  /// No description provided for @common_first_inning_title.
  ///
  /// In en, this message translates to:
  /// **'First inning'**
  String get common_first_inning_title;

  /// No description provided for @common_second_inning_title.
  ///
  /// In en, this message translates to:
  /// **'Second inning'**
  String get common_second_inning_title;

  /// No description provided for @common_qr_code_title.
  ///
  /// In en, this message translates to:
  /// **'QR Code'**
  String get common_qr_code_title;

  /// No description provided for @common_verify_title.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get common_verify_title;

  /// No description provided for @common_verified_title.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get common_verified_title;

  /// No description provided for @common_view_all.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get common_view_all;

  /// No description provided for @common_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_today;

  /// No description provided for @common_tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get common_tomorrow;

  /// No description provided for @common_owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get common_owner;

  /// No description provided for @common_make_admin.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get common_make_admin;

  /// No description provided for @common_remove_admin.
  ///
  /// In en, this message translates to:
  /// **'Remove admin'**
  String get common_remove_admin;

  /// No description provided for @common_transfer_ownership.
  ///
  /// In en, this message translates to:
  /// **'Transfer ownership'**
  String get common_transfer_ownership;

  /// No description provided for @common_tournaments.
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get common_tournaments;

  /// No description provided for @common_leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get common_leaderboard;

  /// No description provided for @common_batting.
  ///
  /// In en, this message translates to:
  /// **'Batting'**
  String get common_batting;

  /// No description provided for @common_bowling.
  ///
  /// In en, this message translates to:
  /// **'Bowling'**
  String get common_bowling;

  /// No description provided for @common_fielding.
  ///
  /// In en, this message translates to:
  /// **'Fielding'**
  String get common_fielding;

  /// +{countryCode} ***** ***{lastDigits}
  ///
  /// In en, this message translates to:
  /// **'{countryCode} ***** ***{lastDigits}'**
  String common_obscure_phone_number_text(
      String countryCode, String lastDigits);

  /// No description provided for @alert_confirm_default_title.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get alert_confirm_default_title;

  /// Are you sure you want to {deleteText}?
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to {deleteText}?'**
  String alert_confirm_default_message(String deleteText);

  /// No description provided for @error_something_went_wrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong! Please try again later.'**
  String get error_something_went_wrong;

  /// No description provided for @error_no_internet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection! Please check your network connectivity.'**
  String get error_no_internet;

  /// No description provided for @no_internet_error_title.
  ///
  /// In en, this message translates to:
  /// **'No internet!'**
  String get no_internet_error_title;

  /// No description provided for @no_internet_error_description.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check connection and try again.'**
  String get no_internet_error_description;

  /// No description provided for @something_went_wrong_error_title.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get something_went_wrong_error_title;

  /// No description provided for @something_went_wrong_error_description.
  ///
  /// In en, this message translates to:
  /// **'This is all the information we have, but we won\'t rest until we resolve the issue!'**
  String get something_went_wrong_error_description;

  /// No description provided for @intro_get_your_cricket_title.
  ///
  /// In en, this message translates to:
  /// **'Get Your Cricket On!'**
  String get intro_get_your_cricket_title;

  /// No description provided for @intro_get_your_cricket_description.
  ///
  /// In en, this message translates to:
  /// **'Turn backyard games into pro matches with our app. Create matches, manage teams, and track stats!'**
  String get intro_get_your_cricket_description;

  /// No description provided for @intro_continue_btn_text.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get intro_continue_btn_text;

  /// No description provided for @sign_in_verify_phone_number_title.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get sign_in_verify_phone_number_title;

  /// No description provided for @sign_in_verify_phone_number_description.
  ///
  /// In en, this message translates to:
  /// **'We’ll verify your phone number with a verification code.'**
  String get sign_in_verify_phone_number_description;

  /// No description provided for @sign_in_phone_number_placeholder.
  ///
  /// In en, this message translates to:
  /// **'00000 00000'**
  String get sign_in_phone_number_placeholder;

  /// No description provided for @sign_in_get_otp_btn_text.
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get sign_in_get_otp_btn_text;

  /// No description provided for @sign_in_invalid_phone_number_text.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid phone number'**
  String get sign_in_invalid_phone_number_text;

  /// No description provided for @otp_verification_verification_title.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get otp_verification_verification_title;

  /// No description provided for @otp_verification_incorrect_otp_error_text.
  ///
  /// In en, this message translates to:
  /// **'*Please enter correct OTP'**
  String get otp_verification_incorrect_otp_error_text;

  /// No description provided for @otp_verification_verify_placeholder.
  ///
  /// In en, this message translates to:
  /// **'0 0 0 0 0 0'**
  String get otp_verification_verify_placeholder;

  /// No description provided for @otp_verification_verification_description.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification code to your phone {phone}'**
  String otp_verification_verification_description(Object phone);

  /// No description provided for @home_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home_screen_title;

  /// No description provided for @home_screen_live_title.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get home_screen_live_title;

  /// No description provided for @home_screen_upcoming_title.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get home_screen_upcoming_title;

  /// No description provided for @home_screen_finished_title.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get home_screen_finished_title;

  /// No description provided for @home_screen_set_up_match_title.
  ///
  /// In en, this message translates to:
  /// **'Set up a match in minutes.'**
  String get home_screen_set_up_match_title;

  /// No description provided for @home_screen_create_match_btn.
  ///
  /// In en, this message translates to:
  /// **'Create match'**
  String get home_screen_create_match_btn;

  /// No description provided for @home_screen_set_up_team_title.
  ///
  /// In en, this message translates to:
  /// **'Set up a team in minutes.'**
  String get home_screen_set_up_team_title;

  /// No description provided for @home_screen_create_team_btn.
  ///
  /// In en, this message translates to:
  /// **'Create team'**
  String get home_screen_create_team_btn;

  /// No description provided for @home_screen_set_up_tournament_title.
  ///
  /// In en, this message translates to:
  /// **'Set up a tournament in minutes.'**
  String get home_screen_set_up_tournament_title;

  /// No description provided for @home_screen_create_tournament_btn.
  ///
  /// In en, this message translates to:
  /// **'Create tournament'**
  String get home_screen_create_tournament_btn;

  /// No description provided for @home_screen_no_matches_title.
  ///
  /// In en, this message translates to:
  /// **'No Matches in this area!'**
  String get home_screen_no_matches_title;

  /// No description provided for @home_screen_no_matches_description_text.
  ///
  /// In en, this message translates to:
  /// **'Enjoy the freedom of creating your own cricket matches or teams.'**
  String get home_screen_no_matches_description_text;

  /// No description provided for @home_search_hint_title.
  ///
  /// In en, this message translates to:
  /// **'Search matches by team name...'**
  String get home_search_hint_title;

  /// No description provided for @home_search_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Start your search here!'**
  String get home_search_empty_title;

  /// No description provided for @home_search_empty_message.
  ///
  /// In en, this message translates to:
  /// **'Type your search above to find what you need fast.'**
  String get home_search_empty_message;

  /// No description provided for @home_search_results_title.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get home_search_results_title;

  /// No description provided for @home_search_users_title.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get home_search_users_title;

  /// No description provided for @home_search_list_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get home_search_list_empty_title;

  /// No description provided for @home_search_list_empty_message.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find any results for your search. Please try different keywords.'**
  String get home_search_list_empty_message;

  /// No description provided for @leaderboard_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Nothing to Show Yet'**
  String get leaderboard_empty_title;

  /// No description provided for @leaderboard_empty_description.
  ///
  /// In en, this message translates to:
  /// **'No scores available yet. Make your move and take the lead!'**
  String get leaderboard_empty_description;

  /// No description provided for @leaderboard_catches_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{count} catches} =1{{count} catch} other{{count} catches}}'**
  String leaderboard_catches_title(num count);

  /// No description provided for @notification_popup_title.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications?'**
  String get notification_popup_title;

  /// No description provided for @notification_popup_description.
  ///
  /// In en, this message translates to:
  /// **'Never miss a moment of your matches. \nTurn on notifications for real-time updates and important match information.'**
  String get notification_popup_description;

  /// No description provided for @notification_popup_later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get notification_popup_later;

  /// No description provided for @my_cricket_screen_title.
  ///
  /// In en, this message translates to:
  /// **'My Cricket'**
  String get my_cricket_screen_title;

  /// No description provided for @add_tournament_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Add Tournament'**
  String get add_tournament_screen_title;

  /// No description provided for @add_tournament_name.
  ///
  /// In en, this message translates to:
  /// **'Tournament Name'**
  String get add_tournament_name;

  /// No description provided for @add_tournament_type.
  ///
  /// In en, this message translates to:
  /// **'Tournament Type'**
  String get add_tournament_type;

  /// No description provided for @add_tournament_type_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Select tournament type'**
  String get add_tournament_type_placeholder;

  /// No description provided for @add_tournament_start_date.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get add_tournament_start_date;

  /// No description provided for @add_tournament_end_date.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get add_tournament_end_date;

  /// No description provided for @add_tournament_team_selection.
  ///
  /// In en, this message translates to:
  /// **'Team selection'**
  String get add_tournament_team_selection;

  /// No description provided for @add_tournament_match_selection.
  ///
  /// In en, this message translates to:
  /// **'Match selection'**
  String get add_tournament_match_selection;

  /// No description provided for @add_tournament_edit_banner.
  ///
  /// In en, this message translates to:
  /// **'Edit banner'**
  String get add_tournament_edit_banner;

  /// No description provided for @add_tournament_add_banner_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Add banner image'**
  String get add_tournament_add_banner_placeholder;

  /// No description provided for @add_tournament_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete tournament!'**
  String get add_tournament_delete_title;

  /// No description provided for @add_tournament_delete_description.
  ///
  /// In en, this message translates to:
  /// **'This action will permanently delete the tournament, along with all match data. Are you sure you want to delete?'**
  String get add_tournament_delete_description;

  /// No description provided for @add_tournament_date_error.
  ///
  /// In en, this message translates to:
  /// **'End date should be greater than start date'**
  String get add_tournament_date_error;

  /// No description provided for @add_tournament_select_min_team_error.
  ///
  /// In en, this message translates to:
  /// **'Please select minimum {count} teams'**
  String add_tournament_select_min_team_error(Object count);

  /// No description provided for @add_tournament_teams_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No teams} =1{{count} Team} other{{count} Teams}}'**
  String add_tournament_teams_title(num count);

  /// No description provided for @tournament_list_empty_list_title.
  ///
  /// In en, this message translates to:
  /// **'No tournaments created'**
  String get tournament_list_empty_list_title;

  /// No description provided for @tournament_list_empty_list_description.
  ///
  /// In en, this message translates to:
  /// **'Tap on the “ + ” icon to create a tournament'**
  String get tournament_list_empty_list_description;

  /// No description provided for @tournament_list_match_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No matches} =1{{count} Match} other{{count} Matches}}'**
  String tournament_list_match_title(num count);

  /// No description provided for @team_selection_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Select Teams'**
  String get team_selection_screen_title;

  /// No description provided for @team_selection_select_team_title.
  ///
  /// In en, this message translates to:
  /// **'Select teams'**
  String get team_selection_select_team_title;

  /// No description provided for @team_selection_verify_team_to_add_title.
  ///
  /// In en, this message translates to:
  /// **'Verify teams to add'**
  String get team_selection_verify_team_to_add_title;

  /// No description provided for @match_selection_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Select Matches'**
  String get match_selection_screen_title;

  /// No description provided for @match_selection_select_matches_title.
  ///
  /// In en, this message translates to:
  /// **'Select matches'**
  String get match_selection_select_matches_title;

  /// No description provided for @match_selection_round_title.
  ///
  /// In en, this message translates to:
  /// **'Round {round}'**
  String match_selection_round_title(Object round);

  /// No description provided for @match_selection_no_matches_title.
  ///
  /// In en, this message translates to:
  /// **'No Matches Scheduled Yet'**
  String get match_selection_no_matches_title;

  /// No description provided for @match_selection_no_matches_description.
  ///
  /// In en, this message translates to:
  /// **'There are currently no matches scheduled. Tap the \'+\' button to schedule new matches.'**
  String get match_selection_no_matches_description;

  /// No description provided for @match_selection_not_found_title.
  ///
  /// In en, this message translates to:
  /// **'No Matches Found for {team}'**
  String match_selection_not_found_title(Object team);

  /// No description provided for @match_selection_not_found_description.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t find any match results for {team} at this time. Please check again later.'**
  String match_selection_not_found_description(Object team);

  /// No description provided for @match_group_round_title.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get match_group_round_title;

  /// No description provided for @match_group_quarter_final_title.
  ///
  /// In en, this message translates to:
  /// **'Quarter final'**
  String get match_group_quarter_final_title;

  /// No description provided for @match_group_semi_final_title.
  ///
  /// In en, this message translates to:
  /// **'Semi final'**
  String get match_group_semi_final_title;

  /// No description provided for @match_group_final_title.
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get match_group_final_title;

  /// No description provided for @tournament_detail_not_found_title.
  ///
  /// In en, this message translates to:
  /// **'No Tournament found'**
  String get tournament_detail_not_found_title;

  /// No description provided for @tournament_detail_not_found_description.
  ///
  /// In en, this message translates to:
  /// **'The tournament you are looking for is not available.'**
  String get tournament_detail_not_found_description;

  /// Start from {date}
  ///
  /// In en, this message translates to:
  /// **'Start from {date}'**
  String tournament_detail_start_from_title(String date);

  /// No description provided for @tournament_detail_overview_tab.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get tournament_detail_overview_tab;

  /// No description provided for @tournament_detail_points_table_tab.
  ///
  /// In en, this message translates to:
  /// **'Points Table'**
  String get tournament_detail_points_table_tab;

  /// No description provided for @tournament_detail_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit tournament'**
  String get tournament_detail_edit_title;

  /// No description provided for @tournament_detail_members_title.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get tournament_detail_members_title;

  /// No description provided for @tournament_detail_overview_info_title.
  ///
  /// In en, this message translates to:
  /// **'Tournament info'**
  String get tournament_detail_overview_info_title;

  /// No description provided for @tournament_detail_overview_name_title.
  ///
  /// In en, this message translates to:
  /// **'Tournament Name'**
  String get tournament_detail_overview_name_title;

  /// No description provided for @tournament_detail_overview_type_title.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get tournament_detail_overview_type_title;

  /// No description provided for @tournament_detail_overview_duration_title.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get tournament_detail_overview_duration_title;

  /// No description provided for @tournament_detail_overview_teams_squads_title.
  ///
  /// In en, this message translates to:
  /// **'Teams Squads'**
  String get tournament_detail_overview_teams_squads_title;

  /// No description provided for @tournament_detail_overview_key_stats_title.
  ///
  /// In en, this message translates to:
  /// **'Key Stats'**
  String get tournament_detail_overview_key_stats_title;

  /// No description provided for @tournament_detail_overview_featured_matches_title.
  ///
  /// In en, this message translates to:
  /// **'Featured Matches'**
  String get tournament_detail_overview_featured_matches_title;

  /// No description provided for @tournament_detail_teams_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Select Your Teams!'**
  String get tournament_detail_teams_empty_title;

  /// No description provided for @tournament_detail_teams_empty_description.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any teams to this tournament yet. Please select or create teams to get started.'**
  String get tournament_detail_teams_empty_description;

  /// No description provided for @tournament_detail_teams_select_btn.
  ///
  /// In en, this message translates to:
  /// **'Add teams'**
  String get tournament_detail_teams_select_btn;

  /// No description provided for @tournament_detail_matches_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Schedule Your Matches!'**
  String get tournament_detail_matches_empty_title;

  /// No description provided for @tournament_detail_matches_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Create matches to kick off your tournament and get the games started!'**
  String get tournament_detail_matches_empty_description;

  /// No description provided for @tournament_detail_matches_filter_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get tournament_detail_matches_filter_empty_title;

  /// No description provided for @tournament_detail_matches_filter_empty_description.
  ///
  /// In en, this message translates to:
  /// **'No matches match the selected filters. Try adjusting them.'**
  String get tournament_detail_matches_filter_empty_description;

  /// No description provided for @tournament_detail_matches_add_btn.
  ///
  /// In en, this message translates to:
  /// **'Add matches'**
  String get tournament_detail_matches_add_btn;

  /// No description provided for @tournament_detail_matches_filter_by_teams_title.
  ///
  /// In en, this message translates to:
  /// **'Filter by teams'**
  String get tournament_detail_matches_filter_by_teams_title;

  /// No description provided for @tournament_detail_matches_filter_all_teams_option.
  ///
  /// In en, this message translates to:
  /// **'All Teams'**
  String get tournament_detail_matches_filter_all_teams_option;

  /// No description provided for @tournament_detail_key_stat_most_runs_title.
  ///
  /// In en, this message translates to:
  /// **'Most Runs'**
  String get tournament_detail_key_stat_most_runs_title;

  /// No description provided for @tournament_detail_key_stat_most_wickets_title.
  ///
  /// In en, this message translates to:
  /// **'Most Wickets'**
  String get tournament_detail_key_stat_most_wickets_title;

  /// No description provided for @tournament_detail_key_stat_most_fours_title.
  ///
  /// In en, this message translates to:
  /// **'Most Fours'**
  String get tournament_detail_key_stat_most_fours_title;

  /// No description provided for @tournament_detail_key_stat_most_sixes_title.
  ///
  /// In en, this message translates to:
  /// **'Most Sixes'**
  String get tournament_detail_key_stat_most_sixes_title;

  /// No description provided for @key_stat_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get key_stat_all;

  /// No description provided for @key_stat_filter_runs.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get key_stat_filter_runs;

  /// No description provided for @key_stat_filter_wickets.
  ///
  /// In en, this message translates to:
  /// **'Wickets'**
  String get key_stat_filter_wickets;

  /// No description provided for @key_stat_filter_fours.
  ///
  /// In en, this message translates to:
  /// **'Fours'**
  String get key_stat_filter_fours;

  /// No description provided for @key_stat_filter_sixes.
  ///
  /// In en, this message translates to:
  /// **'Sixes'**
  String get key_stat_filter_sixes;

  /// No description provided for @key_stat_filter_most_hundreds.
  ///
  /// In en, this message translates to:
  /// **'Most hundreds'**
  String get key_stat_filter_most_hundreds;

  /// No description provided for @key_stat_filter_most_fifties.
  ///
  /// In en, this message translates to:
  /// **'Most fifties'**
  String get key_stat_filter_most_fifties;

  /// No description provided for @key_stat_filter_boundaries.
  ///
  /// In en, this message translates to:
  /// **'Boundaries'**
  String get key_stat_filter_boundaries;

  /// No description provided for @tournament_detail_points_table_points_title.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get tournament_detail_points_table_points_title;

  /// No description provided for @tournament_detail_points_table_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No Points Yet!'**
  String get tournament_detail_points_table_empty_title;

  /// No description provided for @tournament_detail_points_table_empty_description.
  ///
  /// In en, this message translates to:
  /// **'The points table will be updated once matches begin. Stay tuned for the latest standings!'**
  String get tournament_detail_points_table_empty_description;

  /// No description provided for @tournament_detail_points_table_team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get tournament_detail_points_table_team;

  /// No description provided for @tournament_detail_points_table_wins.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get tournament_detail_points_table_wins;

  /// No description provided for @tournament_detail_points_table_losses.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get tournament_detail_points_table_losses;

  /// No description provided for @tournament_detail_points_table_pts.
  ///
  /// In en, this message translates to:
  /// **'Pts'**
  String get tournament_detail_points_table_pts;

  /// No description provided for @tournament_detail_points_table_nrr.
  ///
  /// In en, this message translates to:
  /// **'NRR'**
  String get tournament_detail_points_table_nrr;

  /// No description provided for @tournament_detail_stats_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No stats available yet!'**
  String get tournament_detail_stats_empty_title;

  /// No description provided for @tournament_detail_stats_empty_description.
  ///
  /// In en, this message translates to:
  /// **'The players are warming up! Stay tuned for exciting stats as the team progresses.'**
  String get tournament_detail_stats_empty_description;

  /// No description provided for @tournament_detail_stats_empty_filter_title.
  ///
  /// In en, this message translates to:
  /// **'No Stats Found'**
  String get tournament_detail_stats_empty_filter_title;

  /// No description provided for @tournament_detail_stats_empty_filter_description.
  ///
  /// In en, this message translates to:
  /// **'Please try a different filter.'**
  String get tournament_detail_stats_empty_filter_description;

  /// No description provided for @tournament_detail_stats_player_title.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get tournament_detail_stats_player_title;

  /// No description provided for @tournament_detail_stats_avg_title.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get tournament_detail_stats_avg_title;

  /// No description provided for @tournament_detail_stats_runs_title.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get tournament_detail_stats_runs_title;

  /// No description provided for @tournament_members_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No members yet!'**
  String get tournament_members_empty_title;

  /// No description provided for @tournament_members_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add members and start managing your tournament effectively!'**
  String get tournament_members_empty_description;

  /// No description provided for @tournament_members_search_member_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Assign Tournament Role'**
  String get tournament_members_search_member_empty_title;

  /// No description provided for @tournament_members_search_member_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Search for a user to assign a management role. This role will empower them to help organize and lead the tournament effectively.'**
  String get tournament_members_search_member_empty_description;

  /// No description provided for @tournament_members_remove_self.
  ///
  /// In en, this message translates to:
  /// **'Remove self'**
  String get tournament_members_remove_self;

  /// No description provided for @tournament_members_make_organizer.
  ///
  /// In en, this message translates to:
  /// **'Make organizer'**
  String get tournament_members_make_organizer;

  /// No description provided for @tournament_members_remove_member.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get tournament_members_remove_member;

  /// No description provided for @tournament_members_transfer_ownership_description.
  ///
  /// In en, this message translates to:
  /// **'Search for a user to transfer tournament ownership. This grants them full management control. Choose someone who can effectively lead the tournament.'**
  String get tournament_members_transfer_ownership_description;

  /// No description provided for @tournament_type_knock_out.
  ///
  /// In en, this message translates to:
  /// **'Knockout'**
  String get tournament_type_knock_out;

  /// No description provided for @tournament_type_mini_robin.
  ///
  /// In en, this message translates to:
  /// **'Mini Robin'**
  String get tournament_type_mini_robin;

  /// No description provided for @tournament_type_box_league.
  ///
  /// In en, this message translates to:
  /// **'Box League'**
  String get tournament_type_box_league;

  /// No description provided for @tournament_type_double_out.
  ///
  /// In en, this message translates to:
  /// **'Double Out'**
  String get tournament_type_double_out;

  /// No description provided for @tournament_type_best_of_three.
  ///
  /// In en, this message translates to:
  /// **'Best Of three'**
  String get tournament_type_best_of_three;

  /// No description provided for @tournament_type_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get tournament_type_custom;

  /// No description provided for @tournament_type_knock_out_description.
  ///
  /// In en, this message translates to:
  /// **'Teams face off in a single elimination, with the loser immediately knocked out.\nMinimum {count} teams required.'**
  String tournament_type_knock_out_description(Object count);

  /// No description provided for @tournament_type_mini_robin_description.
  ///
  /// In en, this message translates to:
  /// **'A smaller round-robin format where each team plays once against all others.\nMinimum {count} teams required.'**
  String tournament_type_mini_robin_description(Object count);

  /// No description provided for @tournament_type_box_league_description.
  ///
  /// In en, this message translates to:
  /// **'Teams are divided into groups, with top teams advancing to the knockout stage.\nMinimum {count} teams required.'**
  String tournament_type_box_league_description(Object count);

  /// No description provided for @tournament_type_double_out_description.
  ///
  /// In en, this message translates to:
  /// **'Teams get two chances before being knocked out, with a winners and losers bracket.\nMinimum {count} teams required.'**
  String tournament_type_double_out_description(Object count);

  /// No description provided for @tournament_type_best_of_three_description.
  ///
  /// In en, this message translates to:
  /// **'Teams play a series of matches, and the first to win the majority is the champion.\nMinimum {count} teams required.'**
  String tournament_type_best_of_three_description(Object count);

  /// No description provided for @tournament_type_custom_description.
  ///
  /// In en, this message translates to:
  /// **'Fully flexible, create a structure that suits your needs.\nMinimum {count} teams required.'**
  String tournament_type_custom_description(Object count);

  /// No description provided for @add_team_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Add Team'**
  String get add_team_screen_title;

  /// No description provided for @add_team_edit_team_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Team'**
  String get add_team_edit_team_screen_title;

  /// No description provided for @add_team_add_as_member_description_text.
  ///
  /// In en, this message translates to:
  /// **'Add me as a team member'**
  String get add_team_add_as_member_description_text;

  /// No description provided for @add_team_enter_team_name_placeholder_text.
  ///
  /// In en, this message translates to:
  /// **'Enter team name'**
  String get add_team_enter_team_name_placeholder_text;

  /// No description provided for @add_team_team_initial_placeholder_text.
  ///
  /// In en, this message translates to:
  /// **'Team initials (e.g. IND, AUS, PBKS)'**
  String get add_team_team_initial_placeholder_text;

  /// No description provided for @add_team_player_role_title.
  ///
  /// In en, this message translates to:
  /// **'Playing role'**
  String get add_team_player_role_title;

  /// No description provided for @add_team_players_text.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get add_team_players_text;

  /// No description provided for @add_team_already_added.
  ///
  /// In en, this message translates to:
  /// **'Team already added'**
  String get add_team_already_added;

  /// No description provided for @add_team_add_hint_text.
  ///
  /// In en, this message translates to:
  /// **'Added user will be shown here, tap on \'+\' button to add team member.'**
  String get add_team_add_hint_text;

  /// No description provided for @scan_qr_code.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scan_qr_code;

  /// No description provided for @scan_qr_code_description.
  ///
  /// In en, this message translates to:
  /// **'Place the QR code into the frame'**
  String get scan_qr_code_description;

  /// No description provided for @scan_qr_permission_title.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access to use scanning features'**
  String get scan_qr_permission_title;

  /// No description provided for @scan_qr_permission_description.
  ///
  /// In en, this message translates to:
  /// **'Please enable camera access in your device settings to use the scanning feature.'**
  String get scan_qr_permission_description;

  /// No description provided for @scan_qr_permission_settings.
  ///
  /// In en, this message translates to:
  /// **'Go to settings'**
  String get scan_qr_permission_settings;

  /// No description provided for @add_team_member_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Add Team Member'**
  String get add_team_member_screen_title;

  /// No description provided for @add_team_member_details_title.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get add_team_member_details_title;

  /// No description provided for @add_team_member_search_placeholder_text.
  ///
  /// In en, this message translates to:
  /// **'Search member name'**
  String get add_team_member_search_placeholder_text;

  /// No description provided for @add_team_member_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Your cricket crew awaits!'**
  String get add_team_member_empty_title;

  /// No description provided for @add_team_member_empty_description_text.
  ///
  /// In en, this message translates to:
  /// **'The pitch is set, but you need your players. Find them with a quick search.'**
  String get add_team_member_empty_description_text;

  /// No description provided for @add_team_member_search_no_result_title.
  ///
  /// In en, this message translates to:
  /// **'Oops! No User Found'**
  String get add_team_member_search_no_result_title;

  /// No description provided for @add_team_member_search_description_text.
  ///
  /// In en, this message translates to:
  /// **'It seems we don\'t have anyone by that name. Give another name a go!'**
  String get add_team_member_search_description_text;

  /// No description provided for @add_team_member_added_text.
  ///
  /// In en, this message translates to:
  /// **'ADDED'**
  String get add_team_member_added_text;

  /// No description provided for @add_team_member_already_added.
  ///
  /// In en, this message translates to:
  /// **'Member already added'**
  String get add_team_member_already_added;

  /// No description provided for @add_team_member_verify_error_text.
  ///
  /// In en, this message translates to:
  /// **'Please enter correct digits'**
  String get add_team_member_verify_error_text;

  /// Enter the last {count} digits of the phone number of the selected player.
  ///
  /// In en, this message translates to:
  /// **'Enter the last {count} digits of the phone number of the selected player.'**
  String add_team_member_verify_placeholder_text(int count);

  /// No description provided for @team_list_add_members_title.
  ///
  /// In en, this message translates to:
  /// **'Add Members'**
  String get team_list_add_members_title;

  /// No description provided for @team_list_all_teams_title.
  ///
  /// In en, this message translates to:
  /// **'All teams'**
  String get team_list_all_teams_title;

  /// No description provided for @team_list_created_by_me_title.
  ///
  /// In en, this message translates to:
  /// **'Created by me'**
  String get team_list_created_by_me_title;

  /// No description provided for @team_list_me_as_member_title.
  ///
  /// In en, this message translates to:
  /// **'Me as member'**
  String get team_list_me_as_member_title;

  /// No description provided for @team_list_me_as_admin_title.
  ///
  /// In en, this message translates to:
  /// **'Me as admin'**
  String get team_list_me_as_admin_title;

  /// No description provided for @team_list_no_teams_created_title.
  ///
  /// In en, this message translates to:
  /// **'No teams created'**
  String get team_list_no_teams_created_title;

  /// No description provided for @team_list_empty_list_description.
  ///
  /// In en, this message translates to:
  /// **'Tap on the “ + ” icon to create a team'**
  String get team_list_empty_list_description;

  /// No description provided for @match_list_no_match_here_title.
  ///
  /// In en, this message translates to:
  /// **'No matches here'**
  String get match_list_no_match_here_title;

  /// No description provided for @match_list_empty_list_description.
  ///
  /// In en, this message translates to:
  /// **'Tap on the “ + ” icon to create a match'**
  String get match_list_empty_list_description;

  /// overs, plural, =0{{overs} overs} =1{{overs} over} other{{overs} overs}}
  ///
  /// In en, this message translates to:
  /// **'{overs, plural, =0{{overs} overs} =1{{overs} over} other{{overs} overs}}'**
  String match_list_overs_title(int overs);

  /// No description provided for @add_match_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Add Match'**
  String get add_match_screen_title;

  /// No description provided for @add_match_screen_edit_match_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Match'**
  String get add_match_screen_edit_match_title;

  /// No description provided for @add_match_team_b_title.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get add_match_team_b_title;

  /// No description provided for @add_match_team_name_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Team Name'**
  String get add_match_team_name_placeholder;

  /// No description provided for @add_match_match_type_title.
  ///
  /// In en, this message translates to:
  /// **'Match Type'**
  String get add_match_match_type_title;

  /// No description provided for @add_match_match_type_limited_overs_title.
  ///
  /// In en, this message translates to:
  /// **'Limited overs'**
  String get add_match_match_type_limited_overs_title;

  /// No description provided for @add_match_match_type_test_match_title.
  ///
  /// In en, this message translates to:
  /// **'Test match'**
  String get add_match_match_type_test_match_title;

  /// No description provided for @add_match_match_type_the_hundred_title.
  ///
  /// In en, this message translates to:
  /// **'The hundred'**
  String get add_match_match_type_the_hundred_title;

  /// No description provided for @add_match_match_type_pair_cricket_title.
  ///
  /// In en, this message translates to:
  /// **'Pair cricket'**
  String get add_match_match_type_pair_cricket_title;

  /// No description provided for @add_match_match_type_box_cricket_title.
  ///
  /// In en, this message translates to:
  /// **'Box cricket'**
  String get add_match_match_type_box_cricket_title;

  /// No description provided for @add_match_ball_type_title.
  ///
  /// In en, this message translates to:
  /// **'Ball Type'**
  String get add_match_ball_type_title;

  /// No description provided for @add_match_ball_type_leather_title.
  ///
  /// In en, this message translates to:
  /// **'Leather'**
  String get add_match_ball_type_leather_title;

  /// No description provided for @add_match_ball_type_tennis_title.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get add_match_ball_type_tennis_title;

  /// No description provided for @add_match_pitch_type_title.
  ///
  /// In en, this message translates to:
  /// **'Pitch Type'**
  String get add_match_pitch_type_title;

  /// No description provided for @add_match_pitch_type_rough_title.
  ///
  /// In en, this message translates to:
  /// **'Rough'**
  String get add_match_pitch_type_rough_title;

  /// No description provided for @add_match_pitch_type_cement_title.
  ///
  /// In en, this message translates to:
  /// **'Cement'**
  String get add_match_pitch_type_cement_title;

  /// No description provided for @add_match_pitch_type_turf_title.
  ///
  /// In en, this message translates to:
  /// **'Turf'**
  String get add_match_pitch_type_turf_title;

  /// No description provided for @add_match_pitch_type_astroturf_title.
  ///
  /// In en, this message translates to:
  /// **'Astroturf'**
  String get add_match_pitch_type_astroturf_title;

  /// No description provided for @add_match_pitch_type_matting_title.
  ///
  /// In en, this message translates to:
  /// **'Matting'**
  String get add_match_pitch_type_matting_title;

  /// No description provided for @add_match_match_officials_title.
  ///
  /// In en, this message translates to:
  /// **'Match Officials'**
  String get add_match_match_officials_title;

  /// No description provided for @add_match_officials_umpires_title.
  ///
  /// In en, this message translates to:
  /// **'Umpires'**
  String get add_match_officials_umpires_title;

  /// No description provided for @add_match_officials_scorers_title.
  ///
  /// In en, this message translates to:
  /// **'Scorers'**
  String get add_match_officials_scorers_title;

  /// No description provided for @add_match_officials_live_streamers_title.
  ///
  /// In en, this message translates to:
  /// **'Live Streamers'**
  String get add_match_officials_live_streamers_title;

  /// No description provided for @add_match_officials_referee_title.
  ///
  /// In en, this message translates to:
  /// **'Referee'**
  String get add_match_officials_referee_title;

  /// No description provided for @add_match_officials_commentators_title.
  ///
  /// In en, this message translates to:
  /// **'Commentators'**
  String get add_match_officials_commentators_title;

  /// No description provided for @add_match_officials_others_title.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get add_match_officials_others_title;

  /// No description provided for @add_match_ground_title.
  ///
  /// In en, this message translates to:
  /// **'Ground'**
  String get add_match_ground_title;

  /// No description provided for @add_match_match_schedule_title.
  ///
  /// In en, this message translates to:
  /// **'Match Schedule'**
  String get add_match_match_schedule_title;

  /// No description provided for @add_match_start_match_title.
  ///
  /// In en, this message translates to:
  /// **'Start Match'**
  String get add_match_start_match_title;

  /// No description provided for @add_match_date_title.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get add_match_date_title;

  /// No description provided for @add_match_time_title.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get add_match_time_title;

  /// No description provided for @add_match_no_of_over_title.
  ///
  /// In en, this message translates to:
  /// **'No. of over'**
  String get add_match_no_of_over_title;

  /// No description provided for @add_match_over_per_bowler_title.
  ///
  /// In en, this message translates to:
  /// **'Over per bowler'**
  String get add_match_over_per_bowler_title;

  /// No description provided for @add_match_joined_on_title.
  ///
  /// In en, this message translates to:
  /// **'Joined on'**
  String get add_match_joined_on_title;

  /// No description provided for @add_match_officials_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Add Match Officials'**
  String get add_match_officials_screen_title;

  /// No description provided for @add_match_officials_add_officials_title.
  ///
  /// In en, this message translates to:
  /// **'Add officials'**
  String get add_match_officials_add_officials_title;

  /// No description provided for @add_match_invalid_over_count_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid total over'**
  String get add_match_invalid_over_count_error;

  /// No description provided for @add_match_empty_fields_error.
  ///
  /// In en, this message translates to:
  /// **'Please fill the required details'**
  String get add_match_empty_fields_error;

  /// No description provided for @add_match_unselected_team_error.
  ///
  /// In en, this message translates to:
  /// **'Please select teams'**
  String get add_match_unselected_team_error;

  /// No description provided for @add_match_invalid_squad_error.
  ///
  /// In en, this message translates to:
  /// **'Please select valid squad'**
  String get add_match_invalid_squad_error;

  /// No description provided for @search_user_hint_title.
  ///
  /// In en, this message translates to:
  /// **'Search user name'**
  String get search_user_hint_title;

  /// No description provided for @search_user_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Time to gather your officials!'**
  String get search_user_empty_title;

  /// No description provided for @search_user_empty_description_text.
  ///
  /// In en, this message translates to:
  /// **'Search and assign officials for your next match. Get ready for cricket action!'**
  String get search_user_empty_description_text;

  /// No description provided for @search_team_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Search Team'**
  String get search_team_screen_title;

  /// No description provided for @search_team_selection_error_text.
  ///
  /// In en, this message translates to:
  /// **'The team must have at least 2 players to add it in a match.'**
  String get search_team_selection_error_text;

  /// No description provided for @search_team_search_placeholder_title.
  ///
  /// In en, this message translates to:
  /// **'Search team name'**
  String get search_team_search_placeholder_title;

  /// Power play {count}
  ///
  /// In en, this message translates to:
  /// **'Power play {count}'**
  String power_play_text(int count);

  /// No description provided for @select_squad_select_admin_captain_title.
  ///
  /// In en, this message translates to:
  /// **'Select Captain and Admin'**
  String get select_squad_select_admin_captain_title;

  /// No description provided for @select_squad_captain_short_title.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get select_squad_captain_short_title;

  /// No description provided for @select_squad_playing_squad_title.
  ///
  /// In en, this message translates to:
  /// **'Playing Squad'**
  String get select_squad_playing_squad_title;

  /// No description provided for @select_squad_least_require_text.
  ///
  /// In en, this message translates to:
  /// **'*At-least two players required'**
  String get select_squad_least_require_text;

  /// No description provided for @select_squad_rest_of_team_title.
  ///
  /// In en, this message translates to:
  /// **'Rest of The Team'**
  String get select_squad_rest_of_team_title;

  /// No description provided for @select_squad_empty_squad_text.
  ///
  /// In en, this message translates to:
  /// **'Select squad via adding it from team members list.'**
  String get select_squad_empty_squad_text;

  /// No description provided for @select_squad_empty_team_member_text.
  ///
  /// In en, this message translates to:
  /// **'No team member added in this team, try to add people you know as a team member.'**
  String get select_squad_empty_team_member_text;

  /// No description provided for @add_toss_detail_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Add Toss Detail'**
  String get add_toss_detail_screen_title;

  /// No description provided for @add_toss_detail_who_won_toss_text.
  ///
  /// In en, this message translates to:
  /// **'Who won the toss?'**
  String get add_toss_detail_who_won_toss_text;

  /// No description provided for @add_toss_detail_winner_elected_to_text.
  ///
  /// In en, this message translates to:
  /// **'Toss-winner elected to - ?'**
  String get add_toss_detail_winner_elected_to_text;

  /// No description provided for @add_substitute_search_substitute_title.
  ///
  /// In en, this message translates to:
  /// **'Who’s ready to step in?'**
  String get add_substitute_search_substitute_title;

  /// No description provided for @add_substitute_search_substitute_description.
  ///
  /// In en, this message translates to:
  /// **'Search and assign a substitute fielder to maintain your fielding edge.'**
  String get add_substitute_search_substitute_description;

  /// No description provided for @team_detail_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Team Detail'**
  String get team_detail_screen_title;

  /// No description provided for @team_detail_member_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get team_detail_member_tab_title;

  /// No description provided for @team_detail_empty_matches_title.
  ///
  /// In en, this message translates to:
  /// **'No matches scheduled yet!'**
  String get team_detail_empty_matches_title;

  /// No description provided for @team_detail_empty_matches_description_text.
  ///
  /// In en, this message translates to:
  /// **'Get your cricket game on! Schedule your cricket match with ease!'**
  String get team_detail_empty_matches_description_text;

  /// No description provided for @team_detail_visitor_empty_matches_description_text.
  ///
  /// In en, this message translates to:
  /// **'Until now, the team has not competed.'**
  String get team_detail_visitor_empty_matches_description_text;

  /// No description provided for @team_detail_empty_member_title.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t any member!'**
  String get team_detail_empty_member_title;

  /// No description provided for @team_detail_empty_member_description_text.
  ///
  /// In en, this message translates to:
  /// **'Invite your friends to build your dream team and start tracking matches together.'**
  String get team_detail_empty_member_description_text;

  /// No description provided for @team_detail_visitor_empty_member_description_text.
  ///
  /// In en, this message translates to:
  /// **'No member has been added to the team.'**
  String get team_detail_visitor_empty_member_description_text;

  /// No description provided for @team_detail_empty_stat_title.
  ///
  /// In en, this message translates to:
  /// **'No stats available yet!'**
  String get team_detail_empty_stat_title;

  /// No description provided for @team_detail_empty_stat_description_text.
  ///
  /// In en, this message translates to:
  /// **'The players are warming up! Stay tuned for exciting stats as the team progresses.'**
  String get team_detail_empty_stat_description_text;

  /// No description provided for @team_detail_add_members_title.
  ///
  /// In en, this message translates to:
  /// **'Add members'**
  String get team_detail_add_members_title;

  /// No description provided for @team_detail_add_match_title.
  ///
  /// In en, this message translates to:
  /// **'Add match'**
  String get team_detail_add_match_title;

  /// No description provided for @team_detail_use_qr_description.
  ///
  /// In en, this message translates to:
  /// **'Use your phone camera or a QR code app to scan the code above and easily add the team to the tournament'**
  String get team_detail_use_qr_description;

  /// No description provided for @make_admin_selection_error.
  ///
  /// In en, this message translates to:
  /// **'Can\'t select deactivated user as admin'**
  String get make_admin_selection_error;

  /// No description provided for @team_detail_admin.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{count} admins} =1{{count} admin} other{{count} admins}}'**
  String team_detail_admin(num count);

  /// No description provided for @team_detail_remove_ownership_title.
  ///
  /// In en, this message translates to:
  /// **'Remove ownership'**
  String get team_detail_remove_ownership_title;

  /// No description provided for @team_detail_transfer_ownership_description.
  ///
  /// In en, this message translates to:
  /// **'Search for a user to transfer team ownership. This grants them full management control. Choose someone who can effectively lead the team.'**
  String get team_detail_transfer_ownership_description;

  /// No description provided for @team_detail_match_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get team_detail_match_tab_title;

  /// No description provided for @team_detail_stat_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Stat'**
  String get team_detail_stat_tab_title;

  /// Won({win})
  ///
  /// In en, this message translates to:
  /// **'Won({win})'**
  String team_detail_won_title(int win);

  /// Lost({lost})
  ///
  /// In en, this message translates to:
  /// **'Lost({lost})'**
  String team_detail_lost_title(int lost);

  /// Tie({tie})
  ///
  /// In en, this message translates to:
  /// **'Tie({tie})'**
  String team_detail_tie_title(int tie);

  /// No description provided for @team_detail_match_title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{{count} Matches} =1{{count} Match} other{{count} Matches}}'**
  String team_detail_match_title(num count);

  /// No description provided for @team_detail_runs_made_title.
  ///
  /// In en, this message translates to:
  /// **'Runs Made'**
  String get team_detail_runs_made_title;

  /// No description provided for @team_detail_wickets_taken_title.
  ///
  /// In en, this message translates to:
  /// **'Wickets Taken'**
  String get team_detail_wickets_taken_title;

  /// No description provided for @team_detail_highest_runs_title.
  ///
  /// In en, this message translates to:
  /// **'Highest Runs'**
  String get team_detail_highest_runs_title;

  /// No description provided for @team_detail_lowest_runs_title.
  ///
  /// In en, this message translates to:
  /// **'Lowest Runs'**
  String get team_detail_lowest_runs_title;

  /// No description provided for @team_detail_run_rate_title.
  ///
  /// In en, this message translates to:
  /// **'Run Rate'**
  String get team_detail_run_rate_title;

  /// No description provided for @user_detail_info_title.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get user_detail_info_title;

  /// No description provided for @user_detail_personal_information_title.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get user_detail_personal_information_title;

  /// No description provided for @user_detail_participation_title.
  ///
  /// In en, this message translates to:
  /// **'Participation'**
  String get user_detail_participation_title;

  /// No description provided for @user_detail_role_title.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get user_detail_role_title;

  /// No description provided for @user_detail_joining_date_title.
  ///
  /// In en, this message translates to:
  /// **'Joining date'**
  String get user_detail_joining_date_title;

  /// No description provided for @user_detail_test_title.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get user_detail_test_title;

  /// No description provided for @user_detail_matches_title.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get user_detail_matches_title;

  /// No description provided for @user_detail_innings_title.
  ///
  /// In en, this message translates to:
  /// **'Innings'**
  String get user_detail_innings_title;

  /// No description provided for @user_detail_runs_title.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get user_detail_runs_title;

  /// No description provided for @user_detail_balls_title.
  ///
  /// In en, this message translates to:
  /// **'Balls'**
  String get user_detail_balls_title;

  /// No description provided for @user_detail_average_title.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get user_detail_average_title;

  /// No description provided for @user_detail_strike_rate_title.
  ///
  /// In en, this message translates to:
  /// **'SR'**
  String get user_detail_strike_rate_title;

  /// No description provided for @user_detail_fours_title.
  ///
  /// In en, this message translates to:
  /// **'Fours'**
  String get user_detail_fours_title;

  /// No description provided for @user_detail_sixes_title.
  ///
  /// In en, this message translates to:
  /// **'Sixes'**
  String get user_detail_sixes_title;

  /// No description provided for @user_detail_fifties_title.
  ///
  /// In en, this message translates to:
  /// **'50s'**
  String get user_detail_fifties_title;

  /// No description provided for @user_detail_hundreds_title.
  ///
  /// In en, this message translates to:
  /// **'100s'**
  String get user_detail_hundreds_title;

  /// No description provided for @user_detail_ducks_title.
  ///
  /// In en, this message translates to:
  /// **'Ducks'**
  String get user_detail_ducks_title;

  /// No description provided for @user_detail_maidens_title.
  ///
  /// In en, this message translates to:
  /// **'Maidens'**
  String get user_detail_maidens_title;

  /// No description provided for @user_detail_wickets_title.
  ///
  /// In en, this message translates to:
  /// **'Wickets'**
  String get user_detail_wickets_title;

  /// No description provided for @user_detail_eco_title.
  ///
  /// In en, this message translates to:
  /// **'Eco'**
  String get user_detail_eco_title;

  /// No description provided for @user_detail_no_ball_title.
  ///
  /// In en, this message translates to:
  /// **'NB'**
  String get user_detail_no_ball_title;

  /// No description provided for @user_detail_wide_ball_title.
  ///
  /// In en, this message translates to:
  /// **'WB'**
  String get user_detail_wide_ball_title;

  /// No description provided for @user_detail_catches_title.
  ///
  /// In en, this message translates to:
  /// **'Catches'**
  String get user_detail_catches_title;

  /// No description provided for @user_detail_run_out_title.
  ///
  /// In en, this message translates to:
  /// **'Run out'**
  String get user_detail_run_out_title;

  /// No description provided for @user_detail_stumping_title.
  ///
  /// In en, this message translates to:
  /// **'Stumping'**
  String get user_detail_stumping_title;

  /// No description provided for @match_status_yet_to_start_title.
  ///
  /// In en, this message translates to:
  /// **'Yet to start'**
  String get match_status_yet_to_start_title;

  /// No description provided for @match_status_abandoned_title.
  ///
  /// In en, this message translates to:
  /// **'Abandoned'**
  String get match_status_abandoned_title;

  /// No description provided for @wicket_type_bowled_title.
  ///
  /// In en, this message translates to:
  /// **'Bowled'**
  String get wicket_type_bowled_title;

  /// No description provided for @wicket_type_caught_title.
  ///
  /// In en, this message translates to:
  /// **'Caught'**
  String get wicket_type_caught_title;

  /// No description provided for @wicket_type_caught_behind_title.
  ///
  /// In en, this message translates to:
  /// **'Caught Behind'**
  String get wicket_type_caught_behind_title;

  /// No description provided for @wicket_type_caught_bowled_title.
  ///
  /// In en, this message translates to:
  /// **'Caught And Bowled'**
  String get wicket_type_caught_bowled_title;

  /// No description provided for @wicket_type_leg_before_wicket_title.
  ///
  /// In en, this message translates to:
  /// **'Leg Before Wicket'**
  String get wicket_type_leg_before_wicket_title;

  /// No description provided for @wicket_type_stumped_title.
  ///
  /// In en, this message translates to:
  /// **'Stumped'**
  String get wicket_type_stumped_title;

  /// No description provided for @wicket_type_hit_wicket_title.
  ///
  /// In en, this message translates to:
  /// **'Hit Wicket'**
  String get wicket_type_hit_wicket_title;

  /// No description provided for @wicket_type_hit_ball_twice_title.
  ///
  /// In en, this message translates to:
  /// **'Hit Ball Twice'**
  String get wicket_type_hit_ball_twice_title;

  /// No description provided for @wicket_type_handled_ball_title.
  ///
  /// In en, this message translates to:
  /// **'Handled Ball'**
  String get wicket_type_handled_ball_title;

  /// No description provided for @wicket_type_obstructing_field_title.
  ///
  /// In en, this message translates to:
  /// **'Obstructing the Field'**
  String get wicket_type_obstructing_field_title;

  /// No description provided for @wicket_type_timed_out_title.
  ///
  /// In en, this message translates to:
  /// **'Timed Out'**
  String get wicket_type_timed_out_title;

  /// No description provided for @wicket_type_retired_title.
  ///
  /// In en, this message translates to:
  /// **'Retired'**
  String get wicket_type_retired_title;

  /// No description provided for @wicket_type_retired_hurt_title.
  ///
  /// In en, this message translates to:
  /// **'Retired Hurt'**
  String get wicket_type_retired_hurt_title;

  /// No description provided for @wicket_type_short_timed_out_title.
  ///
  /// In en, this message translates to:
  /// **'TO'**
  String get wicket_type_short_timed_out_title;

  /// No description provided for @wicket_type_short_retired_title.
  ///
  /// In en, this message translates to:
  /// **'RT'**
  String get wicket_type_short_retired_title;

  /// No description provided for @wicket_type_short_retired_hurt_title.
  ///
  /// In en, this message translates to:
  /// **'RTH'**
  String get wicket_type_short_retired_hurt_title;

  /// No description provided for @match_detail_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Match Detail'**
  String get match_detail_screen_title;

  /// No description provided for @match_detail_commentary_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Commentary'**
  String get match_detail_commentary_tab_title;

  /// No description provided for @match_detail_scorecard_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Scorecard'**
  String get match_detail_scorecard_tab_title;

  /// No description provided for @match_detail_squad_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Squad'**
  String get match_detail_squad_tab_title;

  /// No description provided for @match_detail_match_info_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get match_detail_match_info_tab_title;

  /// No description provided for @match_detail_highlight_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get match_detail_highlight_tab_title;

  /// No description provided for @match_detail_overs_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Overs'**
  String get match_detail_overs_tab_title;

  /// No description provided for @match_detail_match_not_started_error_title.
  ///
  /// In en, this message translates to:
  /// **'Match has not started yet.'**
  String get match_detail_match_not_started_error_title;

  /// No description provided for @match_detail_error_description_text.
  ///
  /// In en, this message translates to:
  /// **'The detailed will be available after the start of the match.'**
  String get match_detail_error_description_text;

  /// No description provided for @match_detail_highlight_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No highlights currently available.'**
  String get match_detail_highlight_empty_title;

  /// No description provided for @match_detail_highlight_empty_description_text.
  ///
  /// In en, this message translates to:
  /// **'No events recorded yet. Check back later for updates and highlights.'**
  String get match_detail_highlight_empty_description_text;

  /// No description provided for @match_info_match_title.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get match_info_match_title;

  /// No description provided for @match_info_date_title.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get match_info_date_title;

  /// No description provided for @match_info_toss_title.
  ///
  /// In en, this message translates to:
  /// **'Toss'**
  String get match_info_toss_title;

  /// No description provided for @match_info_time_title.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get match_info_time_title;

  /// No description provided for @match_info_umpire_title.
  ///
  /// In en, this message translates to:
  /// **'Umpire'**
  String get match_info_umpire_title;

  /// No description provided for @match_info_referee_title.
  ///
  /// In en, this message translates to:
  /// **'Referee'**
  String get match_info_referee_title;

  /// No description provided for @match_info_date_and_time_title.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get match_info_date_and_time_title;

  /// {name} Squad
  ///
  /// In en, this message translates to:
  /// **'{name} Squad'**
  String match_info_squad_title(String name);

  /// No description provided for @match_info_venue_title.
  ///
  /// In en, this message translates to:
  /// **'Venue'**
  String get match_info_venue_title;

  /// No description provided for @match_info_ground_title.
  ///
  /// In en, this message translates to:
  /// **'Ground'**
  String get match_info_ground_title;

  /// No description provided for @match_info_city_title.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get match_info_city_title;

  /// No description provided for @match_info_captain_short_title.
  ///
  /// In en, this message translates to:
  /// **'(c)'**
  String get match_info_captain_short_title;

  /// {name} won the toss and opt to {decision}
  ///
  /// In en, this message translates to:
  /// **'{name} won the toss and opt to {decision}'**
  String match_info_toss_detail_text(String name, String decision);

  /// {bowler} to {batsman}
  ///
  /// In en, this message translates to:
  /// **'{bowler} to {batsman}'**
  String match_commentary_bowler_to_batsman_text(String bowler, String batsman);

  ///  b {bowler}
  ///
  /// In en, this message translates to:
  /// **' b {bowler}'**
  String match_commentary_b_bowler_text(String bowler);

  ///  c {fielder}
  ///
  /// In en, this message translates to:
  /// **' c {fielder}'**
  String match_commentary_c_fielder_text(String fielder);

  ///  by {fielder}
  ///
  /// In en, this message translates to:
  /// **' by {fielder}'**
  String match_commentary_by_fielder_text(String fielder);

  ///  {run}({ballCount}) [4s-{fours} 6s-{sixes}]
  ///
  /// In en, this message translates to:
  /// **' {run}({ballCount}) [4s-{fours} 6s-{sixes}]'**
  String match_commentary_runs_fours_sixes_text(
      int run, int ballCount, int fours, int sixes);

  /// {run, plural, =0{no} =1{{run} run} other{{run} runs}}
  ///
  /// In en, this message translates to:
  /// **'{run, plural, =0{no runs} =1{{run} run} other{{run} runs}}'**
  String match_commentary_runs_text(int run);

  /// Ov {over}
  ///
  /// In en, this message translates to:
  /// **'Ov {over}'**
  String match_commentary_former_over_short_text(int over);

  /// No description provided for @match_commentary_four_text.
  ///
  /// In en, this message translates to:
  /// **'Four'**
  String get match_commentary_four_text;

  /// No description provided for @match_commentary_six_text.
  ///
  /// In en, this message translates to:
  /// **'Six'**
  String get match_commentary_six_text;

  /// No description provided for @match_commentary_out_text.
  ///
  /// In en, this message translates to:
  /// **'OUT,'**
  String get match_commentary_out_text;

  /// No description provided for @match_commentary_back_to_attack_text.
  ///
  /// In en, this message translates to:
  /// **' is back to attack'**
  String get match_commentary_back_to_attack_text;

  /// No description provided for @match_commentary_end_inning_text_part_1.
  ///
  /// In en, this message translates to:
  /// **' wraps up their innings, leaving '**
  String get match_commentary_end_inning_text_part_1;

  /// No description provided for @match_commentary_end_inning_text_part_2.
  ///
  /// In en, this message translates to:
  /// **' for victory.'**
  String get match_commentary_end_inning_text_part_2;

  /// Inning {count}
  ///
  /// In en, this message translates to:
  /// **'Inning {count}'**
  String match_commentary_inning_count_text(int count);

  /// No description provided for @match_scorecard_fall_of_wicket_text.
  ///
  /// In en, this message translates to:
  /// **'Fall of Wicket'**
  String get match_scorecard_fall_of_wicket_text;

  /// No description provided for @match_scorecard_over_text.
  ///
  /// In en, this message translates to:
  /// **'Over'**
  String get match_scorecard_over_text;

  /// No description provided for @match_scorecard_run_text.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get match_scorecard_run_text;

  /// No description provided for @match_scorecard_power_play_text.
  ///
  /// In en, this message translates to:
  /// **'PowerPlay'**
  String get match_scorecard_power_play_text;

  /// No description provided for @match_scorecard_run_short_text.
  ///
  /// In en, this message translates to:
  /// **'R'**
  String get match_scorecard_run_short_text;

  /// No description provided for @match_scorecard_ball_short_text.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get match_scorecard_ball_short_text;

  /// No description provided for @match_scorecard_fours_short_text.
  ///
  /// In en, this message translates to:
  /// **'4s'**
  String get match_scorecard_fours_short_text;

  /// No description provided for @match_scorecard_sixes_short_text.
  ///
  /// In en, this message translates to:
  /// **'6s'**
  String get match_scorecard_sixes_short_text;

  /// No description provided for @match_scorecard_strike_rate_short_text.
  ///
  /// In en, this message translates to:
  /// **'SR'**
  String get match_scorecard_strike_rate_short_text;

  /// No description provided for @match_scorecard_over_short_text.
  ///
  /// In en, this message translates to:
  /// **'O'**
  String get match_scorecard_over_short_text;

  /// No description provided for @match_scorecard_maiden_short_text.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get match_scorecard_maiden_short_text;

  /// No description provided for @match_scorecard_wicket_short_text.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get match_scorecard_wicket_short_text;

  /// No description provided for @match_scorecard_no_ball_short_text.
  ///
  /// In en, this message translates to:
  /// **'NB'**
  String get match_scorecard_no_ball_short_text;

  /// No description provided for @match_scorecard_wide_ball_short_text.
  ///
  /// In en, this message translates to:
  /// **'WB'**
  String get match_scorecard_wide_ball_short_text;

  /// No description provided for @match_scorecard_economy_short_text.
  ///
  /// In en, this message translates to:
  /// **'ECO'**
  String get match_scorecard_economy_short_text;

  /// No description provided for @match_scorecard_batter_text.
  ///
  /// In en, this message translates to:
  /// **'Batter'**
  String get match_scorecard_batter_text;

  /// No description provided for @match_scorecard_bowler_text.
  ///
  /// In en, this message translates to:
  /// **'Bowler'**
  String get match_scorecard_bowler_text;

  /// No description provided for @match_scorecard_not_out_text.
  ///
  /// In en, this message translates to:
  /// **'Not out'**
  String get match_scorecard_not_out_text;

  /// No description provided for @match_scorecard_did_not_bat_text.
  ///
  /// In en, this message translates to:
  /// **'Did not bat'**
  String get match_scorecard_did_not_bat_text;

  /// b {bowler} c {fielder}
  ///
  /// In en, this message translates to:
  /// **'b {bowler} c {fielder}'**
  String match_scorecard_bowler_catcher_short_text(
      String bowler, String fielder);

  /// No description provided for @match_scorecard_extra_text.
  ///
  /// In en, this message translates to:
  /// **'Extra'**
  String get match_scorecard_extra_text;

  /// No description provided for @match_scorecard_total_text.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get match_scorecard_total_text;

  /// No description provided for @match_scorecard_empty_scorecard_text.
  ///
  /// In en, this message translates to:
  /// **'Scorecard will appear once the match starts'**
  String get match_scorecard_empty_scorecard_text;

  /// b {bye} lb {legBye} w {wide}  nb {noBall} p {penalty}
  ///
  /// In en, this message translates to:
  /// **'b {bye} lb {legBye} w {wide}  nb {noBall} p {penalty}'**
  String match_scorecard_extras_short_text(
      int bye, int legBye, int wide, int noBall, int penalty);

  /// No description provided for @match_scorecard_wicket_over_text.
  ///
  /// In en, this message translates to:
  /// **'{wicket, plural, =0{no wickets} =1{{wicket} wicket} other{{wicket} wickets}} {over} over'**
  String match_scorecard_wicket_over_text(int wicket, double over);

  /// ({over} Ov)
  ///
  /// In en, this message translates to:
  /// **'({over} Ov)'**
  String match_commentary_trailing_over_short_text(double over);

  /// No description provided for @match_squad_playing_title.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get match_squad_playing_title;

  /// No description provided for @match_squad_bench_title.
  ///
  /// In en, this message translates to:
  /// **'Bench'**
  String get match_squad_bench_title;

  /// No description provided for @match_highlight_filter_all_text.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get match_highlight_filter_all_text;

  /// No description provided for @match_highlight_filter_fours_text.
  ///
  /// In en, this message translates to:
  /// **'Fours'**
  String get match_highlight_filter_fours_text;

  /// No description provided for @match_highlight_filter_sixes_text.
  ///
  /// In en, this message translates to:
  /// **'Sixes'**
  String get match_highlight_filter_sixes_text;

  /// No description provided for @score_board_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Score Board'**
  String get score_board_screen_title;

  /// No description provided for @score_board_wicket_short_text.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get score_board_wicket_short_text;

  /// No description provided for @score_board_no_ball_short_text.
  ///
  /// In en, this message translates to:
  /// **'NB'**
  String get score_board_no_ball_short_text;

  /// No description provided for @score_board_wide_ball_short_text.
  ///
  /// In en, this message translates to:
  /// **'WB'**
  String get score_board_wide_ball_short_text;

  /// No description provided for @score_board_leg_bye_short_text.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get score_board_leg_bye_short_text;

  /// No description provided for @score_board_bye_short_text.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get score_board_bye_short_text;

  /// No description provided for @score_board_zero_text.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get score_board_zero_text;

  /// No description provided for @score_board_one_text.
  ///
  /// In en, this message translates to:
  /// **'1'**
  String get score_board_one_text;

  /// No description provided for @score_board_two_text.
  ///
  /// In en, this message translates to:
  /// **'2'**
  String get score_board_two_text;

  /// No description provided for @score_board_three_text.
  ///
  /// In en, this message translates to:
  /// **'3'**
  String get score_board_three_text;

  /// No description provided for @score_board_four_text.
  ///
  /// In en, this message translates to:
  /// **'4'**
  String get score_board_four_text;

  /// No description provided for @score_board_four_title.
  ///
  /// In en, this message translates to:
  /// **'Four'**
  String get score_board_four_title;

  /// No description provided for @score_board_six_text.
  ///
  /// In en, this message translates to:
  /// **'6'**
  String get score_board_six_text;

  /// No description provided for @score_board_six_title.
  ///
  /// In en, this message translates to:
  /// **'Six'**
  String get score_board_six_title;

  /// No description provided for @score_board_five_or_seven_text.
  ///
  /// In en, this message translates to:
  /// **'5, 7'**
  String get score_board_five_or_seven_text;

  /// No description provided for @score_board_five_text.
  ///
  /// In en, this message translates to:
  /// **'5'**
  String get score_board_five_text;

  /// No description provided for @score_board_seven_text.
  ///
  /// In en, this message translates to:
  /// **'7'**
  String get score_board_seven_text;

  /// No description provided for @score_board_out_text.
  ///
  /// In en, this message translates to:
  /// **'OUT'**
  String get score_board_out_text;

  /// No description provided for @score_board_wicket_text.
  ///
  /// In en, this message translates to:
  /// **'WICKET'**
  String get score_board_wicket_text;

  /// No description provided for @score_board_leg_bye_text.
  ///
  /// In en, this message translates to:
  /// **'LB'**
  String get score_board_leg_bye_text;

  /// No description provided for @score_board_bye_text.
  ///
  /// In en, this message translates to:
  /// **'BYE'**
  String get score_board_bye_text;

  /// No description provided for @score_board_undo_title.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get score_board_undo_title;

  /// No description provided for @score_board_player_title.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get score_board_player_title;

  /// No description provided for @score_board_extras_title.
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get score_board_extras_title;

  /// No description provided for @score_board_runs_title.
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get score_board_runs_title;

  /// No description provided for @score_board_not_from_bat_text.
  ///
  /// In en, this message translates to:
  /// **'Not from bat?'**
  String get score_board_not_from_bat_text;

  /// No description provided for @score_board_is_boundary_text.
  ///
  /// In en, this message translates to:
  /// **'Is that a boundary?'**
  String get score_board_is_boundary_text;

  /// No description provided for @score_board_over_complete_title.
  ///
  /// In en, this message translates to:
  /// **'Over complete'**
  String get score_board_over_complete_title;

  /// No description provided for @score_board_inning_complete_title.
  ///
  /// In en, this message translates to:
  /// **'Inning complete'**
  String get score_board_inning_complete_title;

  /// No description provided for @score_board_match_complete_title.
  ///
  /// In en, this message translates to:
  /// **'Match complete'**
  String get score_board_match_complete_title;

  /// No description provided for @score_board_match_tied_text.
  ///
  /// In en, this message translates to:
  /// **'The match has been tied'**
  String get score_board_match_tied_text;

  /// No description provided for @score_board_match_tied.
  ///
  /// In en, this message translates to:
  /// **'Match tied'**
  String get score_board_match_tied;

  /// No description provided for @score_board_start_next_inning_title.
  ///
  /// In en, this message translates to:
  /// **'Start Next Inning'**
  String get score_board_start_next_inning_title;

  /// No description provided for @score_board_end_inning_title.
  ///
  /// In en, this message translates to:
  /// **'End Inning'**
  String get score_board_end_inning_title;

  /// No description provided for @score_board_current_team_title.
  ///
  /// In en, this message translates to:
  /// **'Current Team'**
  String get score_board_current_team_title;

  /// No description provided for @score_board_team_title.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get score_board_team_title;

  /// No description provided for @score_board_r_title.
  ///
  /// In en, this message translates to:
  /// **'R'**
  String get score_board_r_title;

  /// No description provided for @score_board_w_title.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get score_board_w_title;

  /// No description provided for @score_board_o_title.
  ///
  /// In en, this message translates to:
  /// **'O'**
  String get score_board_o_title;

  /// No description provided for @score_board_won_by_title.
  ///
  /// In en, this message translates to:
  /// **' Won By '**
  String get score_board_won_by_title;

  /// No description provided for @score_board_won_title.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get score_board_won_title;

  /// No description provided for @score_board_by_title.
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get score_board_by_title;

  /// No description provided for @score_board_choose_opening_batsmen_title.
  ///
  /// In en, this message translates to:
  /// **'Choose opening Batsmen'**
  String get score_board_choose_opening_batsmen_title;

  /// No description provided for @score_board_choose_fielder_title.
  ///
  /// In en, this message translates to:
  /// **'Choose fielder'**
  String get score_board_choose_fielder_title;

  /// No description provided for @score_board_injured_tag_title.
  ///
  /// In en, this message translates to:
  /// **'Injured'**
  String get score_board_injured_tag_title;

  /// No description provided for @score_board_who_on_strike_title.
  ///
  /// In en, this message translates to:
  /// **'Who\'s on Strike?'**
  String get score_board_who_on_strike_title;

  /// No description provided for @score_board_who_got_out_title.
  ///
  /// In en, this message translates to:
  /// **'Who got out'**
  String get score_board_who_got_out_title;

  /// No description provided for @score_board_start_next_over_title.
  ///
  /// In en, this message translates to:
  /// **'Start Next Over'**
  String get score_board_start_next_over_title;

  /// No description provided for @score_board_batsman_title.
  ///
  /// In en, this message translates to:
  /// **'batsMan'**
  String get score_board_batsman_title;

  /// No description provided for @score_board_bowler_title.
  ///
  /// In en, this message translates to:
  /// **'bowler'**
  String get score_board_bowler_title;

  /// No description provided for @score_board_change_striker_title.
  ///
  /// In en, this message translates to:
  /// **'Change striker'**
  String get score_board_change_striker_title;

  /// No description provided for @score_board_option_end_match.
  ///
  /// In en, this message translates to:
  /// **'End match'**
  String get score_board_option_end_match;

  /// No description provided for @score_board_option_handover_scoring.
  ///
  /// In en, this message translates to:
  /// **'Handover scoring'**
  String get score_board_option_handover_scoring;

  /// No description provided for @score_board_handover_scoring_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Handover scoring control'**
  String get score_board_handover_scoring_empty_title;

  /// No description provided for @score_board_handover_scoring_empty_description.
  ///
  /// In en, this message translates to:
  /// **'Find and select another user to hand over the scoring responsibilities. Keep the game flowing with a quick and easy transfer.'**
  String get score_board_handover_scoring_empty_description;

  /// No description provided for @score_board_can_undo_till_running_over_title.
  ///
  /// In en, this message translates to:
  /// **'Undo is only allowed till running over'**
  String get score_board_can_undo_till_running_over_title;

  /// No description provided for @score_board_undo_last_ball_title.
  ///
  /// In en, this message translates to:
  /// **'Undo Last Ball'**
  String get score_board_undo_last_ball_title;

  /// No description provided for @score_board_undo_last_ball_description_text.
  ///
  /// In en, this message translates to:
  /// **'are you sure you want to undo last ball?'**
  String get score_board_undo_last_ball_description_text;

  /// No description provided for @score_board_pause_scoring_title.
  ///
  /// In en, this message translates to:
  /// **'Pause scoring'**
  String get score_board_pause_scoring_title;

  /// No description provided for @score_board_add_substitute_title.
  ///
  /// In en, this message translates to:
  /// **'Add substitute'**
  String get score_board_add_substitute_title;

  /// No description provided for @score_board_substitute_title.
  ///
  /// In en, this message translates to:
  /// **'Substitute'**
  String get score_board_substitute_title;

  /// No description provided for @score_board_penalty_run_title.
  ///
  /// In en, this message translates to:
  /// **'Penalty run'**
  String get score_board_penalty_run_title;

  /// No description provided for @score_board_awarded_to_text.
  ///
  /// In en, this message translates to:
  /// **'Awarded to - ?'**
  String get score_board_awarded_to_text;

  /// No description provided for @score_board_continue_with_injured_player_title.
  ///
  /// In en, this message translates to:
  /// **'Continue with injured player'**
  String get score_board_continue_with_injured_player_title;

  /// No description provided for @score_board_show_wheel_for_less_run_title.
  ///
  /// In en, this message translates to:
  /// **'Show wheel for 1s, 2s and 3s'**
  String get score_board_show_wheel_for_less_run_title;

  /// No description provided for @score_board_show_wheel_for_dot_ball_title.
  ///
  /// In en, this message translates to:
  /// **'Show wheel for dot balls'**
  String get score_board_show_wheel_for_dot_ball_title;

  /// No description provided for @score_board_select_fielding_position_title.
  ///
  /// In en, this message translates to:
  /// **'Select fielding position'**
  String get score_board_select_fielding_position_title;

  /// No description provided for @score_board_pause_title.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get score_board_pause_title;

  /// No description provided for @score_board_revised_target_title.
  ///
  /// In en, this message translates to:
  /// **'Revised target'**
  String get score_board_revised_target_title;

  /// No description provided for @score_board_enter_manual_target_text.
  ///
  /// In en, this message translates to:
  /// **'Enter your manually calculated target'**
  String get score_board_enter_manual_target_text;

  /// No description provided for @score_board_runs_text.
  ///
  /// In en, this message translates to:
  /// **'Runs :'**
  String get score_board_runs_text;

  /// No description provided for @score_board_in_overs_text.
  ///
  /// In en, this message translates to:
  /// **'in Overs :'**
  String get score_board_in_overs_text;

  /// No description provided for @score_board_confirm_target_text.
  ///
  /// In en, this message translates to:
  /// **'Confirm target'**
  String get score_board_confirm_target_text;

  /// No description provided for @score_board_current_target_text.
  ///
  /// In en, this message translates to:
  /// **'Current target is {run, plural, =0{{run} runs} =1{{run} run} other{{run} runs}} in {over, plural, =0{{over} overs} =1{{over} over} other{{over} overs}}'**
  String score_board_current_target_text(num run, num over);

  /// No description provided for @score_board_target_invalid_input_error.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid target'**
  String get score_board_target_invalid_input_error;

  /// No description provided for @score_board_pause_scoring_description_text.
  ///
  /// In en, this message translates to:
  /// **'are you sure you want to pause scoring?'**
  String get score_board_pause_scoring_description_text;

  /// No description provided for @score_board_end_match_description_text.
  ///
  /// In en, this message translates to:
  /// **'are you sure you want to end match?'**
  String get score_board_end_match_description_text;

  /// No description provided for @score_board_run_sup_script_text.
  ///
  /// In en, this message translates to:
  /// **'{run, select, 1{{extra}} 2{{extra}²} 3{{extra}³} 4{{extra}⁴} 5{{extra}⁵} 6{{extra}⁶} 7{{extra}⁷} 8{{extra}⁸} 9{{extra}⁹} other{{extra}}}'**
  String score_board_run_sup_script_text(String run, Object extra);

  /// Choose Batsman at position {pos}
  ///
  /// In en, this message translates to:
  /// **'Choose Batsman at position {pos}'**
  String score_board_choose_batsman_title(int pos);

  /// Choose Bowler for over {over}
  ///
  /// In en, this message translates to:
  /// **'Choose Bowler for over {over}'**
  String score_board_choose_bowler_for_over_title(int over);

  /// End Of Over {overNumber} by {player}
  ///
  /// In en, this message translates to:
  /// **'End Of Over {overNumber} by {player}'**
  String score_board_end_of_over_by_title(int overNumber, String player);

  /// No description provided for @score_board_need_run_text.
  ///
  /// In en, this message translates to:
  /// **'Need {count, plural, =0{{count} Runs} =1{{count} Run} other{{count} Runs}}'**
  String score_board_need_run_text(num count);

  /// Need {run} in {ball}
  ///
  /// In en, this message translates to:
  /// **'Need {run} in {ball}'**
  String score_board_run_need_in_ball_text(int run, int ball);

  /// No description provided for @fielding_position_deep_mid_wicket_title.
  ///
  /// In en, this message translates to:
  /// **'Deep mid wicket'**
  String get fielding_position_deep_mid_wicket_title;

  /// No description provided for @fielding_position_long_on_title.
  ///
  /// In en, this message translates to:
  /// **'Long on'**
  String get fielding_position_long_on_title;

  /// No description provided for @fielding_position_long_off_title.
  ///
  /// In en, this message translates to:
  /// **'Long off'**
  String get fielding_position_long_off_title;

  /// No description provided for @fielding_position_deep_cover_title.
  ///
  /// In en, this message translates to:
  /// **'Deep cover'**
  String get fielding_position_deep_cover_title;

  /// No description provided for @fielding_position_deep_point_title.
  ///
  /// In en, this message translates to:
  /// **'Deep point'**
  String get fielding_position_deep_point_title;

  /// No description provided for @fielding_position_third_man_title.
  ///
  /// In en, this message translates to:
  /// **'Third man'**
  String get fielding_position_third_man_title;

  /// No description provided for @fielding_position_deep_fine_leg_title.
  ///
  /// In en, this message translates to:
  /// **'Deep fine leg'**
  String get fielding_position_deep_fine_leg_title;

  /// No description provided for @fielding_position_deep_square_leg_title.
  ///
  /// In en, this message translates to:
  /// **'Deep square leg'**
  String get fielding_position_deep_square_leg_title;

  /// No description provided for @side_off_title.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get side_off_title;

  /// No description provided for @side_leg_title.
  ///
  /// In en, this message translates to:
  /// **'LEG'**
  String get side_leg_title;

  /// No description provided for @tab_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tab_profile_title;

  /// No description provided for @edit_profile_create_profile_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Create Profile'**
  String get edit_profile_create_profile_screen_title;

  /// No description provided for @edit_profile_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile_screen_title;

  /// No description provided for @edit_profile_select_birth_date_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get edit_profile_select_birth_date_placeholder;

  /// No description provided for @edit_profile_name_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get edit_profile_name_placeholder;

  /// No description provided for @edit_profile_email_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get edit_profile_email_placeholder;

  /// No description provided for @edit_profile_dob_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get edit_profile_dob_placeholder;

  /// No description provided for @edit_profile_player_role_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Player role'**
  String get edit_profile_player_role_placeholder;

  /// No description provided for @edit_profile_gender_male_title.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get edit_profile_gender_male_title;

  /// No description provided for @edit_profile_gender_female_title.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get edit_profile_gender_female_title;

  /// No description provided for @edit_profile_gender_prefer_not_to_say_title.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get edit_profile_gender_prefer_not_to_say_title;

  /// No description provided for @edit_profile_delete_account_btn_title.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get edit_profile_delete_account_btn_title;

  /// No description provided for @edit_profile_delete_account_description_text.
  ///
  /// In en, this message translates to:
  /// **'This can not undone. if you delete your account, your data will be gone forever.'**
  String get edit_profile_delete_account_description_text;

  /// No description provided for @transfer_teams_title.
  ///
  /// In en, this message translates to:
  /// **'Before You Go...'**
  String get transfer_teams_title;

  /// No description provided for @transfer_teams_description.
  ///
  /// In en, this message translates to:
  /// **'We\'re sorry to see you go. Before deleting your account, please:\n• Assign new owners and admins for your teams or delete the teams\n• Transfer scoring for ongoing matches\n• Remove any scheduled matches\n•Transfer or assign responsibilities for ongoing tournaments\nThis will ensure everything is properly managed after you leave.'**
  String get transfer_teams_description;

  /// No description provided for @transfer_teams_go_to_my_cricket.
  ///
  /// In en, this message translates to:
  /// **'Go to My Cricket'**
  String get transfer_teams_go_to_my_cricket;

  /// No description provided for @profile_settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_settings_title;

  /// No description provided for @profile_setting_contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get profile_setting_contact_support;

  /// No description provided for @profile_setting_privacy_policy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profile_setting_privacy_policy_title;

  /// No description provided for @profile_setting_terms_and_condition_title.
  ///
  /// In en, this message translates to:
  /// **'Terms and condition'**
  String get profile_setting_terms_and_condition_title;

  /// No description provided for @profile_setting_share_app_title.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get profile_setting_share_app_title;

  /// No description provided for @profile_setting_rate_us_title.
  ///
  /// In en, this message translates to:
  /// **'Rate us'**
  String get profile_setting_rate_us_title;

  /// No description provided for @profile_setting_app_version_text.
  ///
  /// In en, this message translates to:
  /// **'App Version: {version}'**
  String profile_setting_app_version_text(Object version);

  /// No description provided for @profile_setting_scan_to_play_text.
  ///
  /// In en, this message translates to:
  /// **'Scan to play!'**
  String get profile_setting_scan_to_play_text;

  /// No description provided for @profile_setting_scan_to_play_description.
  ///
  /// In en, this message translates to:
  /// **'This QR code allows you to easily add the player to the team.'**
  String get profile_setting_scan_to_play_description;

  /// No description provided for @profile_setting_use_scanner_description.
  ///
  /// In en, this message translates to:
  /// **'Use your phone camera or a QR code app to scan the code above and easily add the player to the team.'**
  String get profile_setting_use_scanner_description;

  /// No description provided for @profile_setting_share_app_message.
  ///
  /// In en, this message translates to:
  /// **'Elevate your cricket scoring game with Khelo! 🏏\n\nEffortlessly score matches, track stats, and manage your teams.\n\n👉 Download Now:\n📱 Android: {androidLink}\n🍎 iOS: {iosLink}\n\nStart scoring smarter today!'**
  String profile_setting_share_app_message(String androidLink, String iosLink);

  /// No description provided for @notification_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notification_title;

  /// No description provided for @notification_turn_on_title.
  ///
  /// In en, this message translates to:
  /// **'It seems that your notifications have been turned off. Turn on notifications to stay updated on your teams and matches.'**
  String get notification_turn_on_title;

  /// No description provided for @notification_turn_on_btn_title.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get notification_turn_on_btn_title;

  /// No description provided for @contact_support_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contact_support_screen_title;

  /// No description provided for @contact_support_title_placeholder_text.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get contact_support_title_placeholder_text;

  /// No description provided for @contact_support_description_placeholder_text.
  ///
  /// In en, this message translates to:
  /// **'Description...'**
  String get contact_support_description_placeholder_text;

  /// No description provided for @contact_support_attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment (if any)'**
  String get contact_support_attachment;

  /// No description provided for @large_attachment_upload_error_text.
  ///
  /// In en, this message translates to:
  /// **'Oops! Your file exceeds the maximum allowed size of 25 MB. Please choose a smaller file and try again.'**
  String get large_attachment_upload_error_text;

  /// No description provided for @profile_complete_your_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get profile_complete_your_profile_title;

  /// No description provided for @profile_complete_description_title.
  ///
  /// In en, this message translates to:
  /// **'Enhance your profile with more details to make it better!'**
  String get profile_complete_description_title;

  /// No description provided for @profile_complete_add_profile_picture.
  ///
  /// In en, this message translates to:
  /// **'Add profile picture'**
  String get profile_complete_add_profile_picture;

  /// No description provided for @profile_complete_add_personal_details.
  ///
  /// In en, this message translates to:
  /// **'Add personal details'**
  String get profile_complete_add_personal_details;

  /// No description provided for @profile_complete_add_playing_style.
  ///
  /// In en, this message translates to:
  /// **'Add playing style'**
  String get profile_complete_add_playing_style;

  /// No description provided for @image_picker_choose_option_title.
  ///
  /// In en, this message translates to:
  /// **'Choose an option'**
  String get image_picker_choose_option_title;

  /// No description provided for @image_picker_camera_option_text.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get image_picker_camera_option_text;

  /// No description provided for @image_picker_gallery_option_text.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get image_picker_gallery_option_text;

  /// No description provided for @image_picker_crop_image_title.
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get image_picker_crop_image_title;

  /// No description provided for @batting_style_right_hand_bat_title.
  ///
  /// In en, this message translates to:
  /// **'Right hand bat'**
  String get batting_style_right_hand_bat_title;

  /// No description provided for @batting_style_left_hand_bat_title.
  ///
  /// In en, this message translates to:
  /// **'Left hand bat'**
  String get batting_style_left_hand_bat_title;

  /// No description provided for @bowling_style_right_arm_fast_title.
  ///
  /// In en, this message translates to:
  /// **'Right arm fast'**
  String get bowling_style_right_arm_fast_title;

  /// No description provided for @bowling_style_right_arm_medium_title.
  ///
  /// In en, this message translates to:
  /// **'Right arm medium'**
  String get bowling_style_right_arm_medium_title;

  /// No description provided for @bowling_style_left_arm_fast_title.
  ///
  /// In en, this message translates to:
  /// **'Left arm fast'**
  String get bowling_style_left_arm_fast_title;

  /// No description provided for @bowling_style_left_arm_medium_title.
  ///
  /// In en, this message translates to:
  /// **'Left arm medium'**
  String get bowling_style_left_arm_medium_title;

  /// No description provided for @bowling_style_slow_left_arm_orthodox_title.
  ///
  /// In en, this message translates to:
  /// **'Slow left arm orthodox'**
  String get bowling_style_slow_left_arm_orthodox_title;

  /// No description provided for @bowling_style_slow_left_arm_chinaman_title.
  ///
  /// In en, this message translates to:
  /// **'Slow left arm chinaman'**
  String get bowling_style_slow_left_arm_chinaman_title;

  /// No description provided for @bowling_style_right_arm_off_break_title.
  ///
  /// In en, this message translates to:
  /// **'Right arm off break'**
  String get bowling_style_right_arm_off_break_title;

  /// No description provided for @bowling_style_right_arm_leg_break_title.
  ///
  /// In en, this message translates to:
  /// **'Right arm leg break'**
  String get bowling_style_right_arm_leg_break_title;

  /// No description provided for @player_role_top_order_batter_title.
  ///
  /// In en, this message translates to:
  /// **'Top order batter'**
  String get player_role_top_order_batter_title;

  /// No description provided for @player_role_middle_order_batter_title.
  ///
  /// In en, this message translates to:
  /// **'Middle order batter'**
  String get player_role_middle_order_batter_title;

  /// No description provided for @player_role_wicket_keeper_batter_title.
  ///
  /// In en, this message translates to:
  /// **'Wicket keeper batter'**
  String get player_role_wicket_keeper_batter_title;

  /// No description provided for @player_role_wicket_keeper_title.
  ///
  /// In en, this message translates to:
  /// **'Wicket keeper'**
  String get player_role_wicket_keeper_title;

  /// No description provided for @player_role_bowler_title.
  ///
  /// In en, this message translates to:
  /// **'Bowler'**
  String get player_role_bowler_title;

  /// No description provided for @player_role_all_rounder_title.
  ///
  /// In en, this message translates to:
  /// **'All rounder'**
  String get player_role_all_rounder_title;

  /// No description provided for @player_role_lower_order_batter_title.
  ///
  /// In en, this message translates to:
  /// **'Lower order batter'**
  String get player_role_lower_order_batter_title;

  /// No description provided for @player_role_opening_batter_title.
  ///
  /// In en, this message translates to:
  /// **'Opening batter'**
  String get player_role_opening_batter_title;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
