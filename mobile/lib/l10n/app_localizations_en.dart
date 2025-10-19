// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dance in ';

  @override
  String get appSubtitle => 'Don\'t Think, Just Dance';

  @override
  String buttonFindEvents(String zone) {
    return 'Find Events In $zone';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSpanish => 'Spanish';

  @override
  String get searchHint => 'Search';

  @override
  String get danceEvents => 'Dance Events';

  @override
  String get noEventsFound => 'No events found in the next 7 days';

  @override
  String get noMoreEvents => 'No more new events';

  @override
  String get free => 'Free';

  @override
  String errorLoadingEvents(String error) {
    return 'Error loading events: $error';
  }

  @override
  String get dateFormat => 'EEEE, MMM d';

  @override
  String get weekdayNames =>
      'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday';

  @override
  String get weekdayAbbreviations => 'M,T,W,Th,F,Sa,Su';

  @override
  String get eventNotFound => 'Event not found.';

  @override
  String get linkCopied => 'Link copied to clipboard!';

  @override
  String get linkToEvent => 'Link to Event';

  @override
  String get oneTime => 'One-time';

  @override
  String repeatWeekly(String day) {
    return 'Repeat Weekly, Every $day';
  }

  @override
  String repeatMonthly(String week, String day) {
    return 'Monthly, Every $week $day';
  }

  @override
  String get weekOfMonthFirst => 'first';

  @override
  String get weekOfMonthSecond => 'second';

  @override
  String get weekOfMonthThird => 'third';

  @override
  String get weekOfMonthFourth => 'fourth';

  @override
  String get weekOfMonthLast => 'last';

  @override
  String get areYouExcited => 'Are you going for this event?';

  @override
  String get maintainedByCommunity =>
      'This listing is maintained by the Community';

  @override
  String get suggestCorrection => 'Suggest a correction';

  @override
  String suggestedCorrections(int count) {
    return 'Suggested Corrections ($count)';
  }

  @override
  String onlyThisEvent(String date) {
    return 'Only this event on $date';
  }

  @override
  String get allFutureEvents => 'All future versions of this event';

  @override
  String get needToVerify =>
      'Need to verify your phone number to vote on proposals';

  @override
  String get verificationFailed =>
      'Failed to verify phone number. Please try again.';

  @override
  String changeFromTo(String field, String oldValue, String newValue) {
    return 'Change $field from $oldValue to $newValue';
  }

  @override
  String get none => 'None';

  @override
  String get forAllEvents => 'For All Events';

  @override
  String get onlyThisEventInstance => 'Only This Event';

  @override
  String get date => 'Date';

  @override
  String get dayOfWeek => 'Day of Week';

  @override
  String get weeksOfMonth => 'Weeks of Month';

  @override
  String get repeat => 'Repeat';

  @override
  String get once => 'Once';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get first => '1st';

  @override
  String get second => '2nd';

  @override
  String get third => '3rd';

  @override
  String get fourth => '4th';

  @override
  String get drawerMenu => 'Menu';

  @override
  String get drawerHelp => 'Help & FAQ';

  @override
  String get drawerContact => 'Contact';

  @override
  String get drawerAdmin => 'Admin';

  @override
  String get drawerRevokeOTP => 'Revoke OTP';

  @override
  String get drawerLogin => 'Login';

  @override
  String get verifyTitle => 'Verify';

  @override
  String get verifyMessage => 'Verify your phone number';

  @override
  String get verifyMessageRate => 'Verify your phone number to rate this event';

  @override
  String get verifyMessageAdd => 'Verify your phone number to add an event';

  @override
  String get verifyMessageEdit => 'Verify your phone number to edit this event';

  @override
  String get verifyMessageVote =>
      'Verify your phone number to vote on proposals';

  @override
  String get enterOTPCode => 'Enter OTP Code';

  @override
  String get otpCode => 'OTP Code';

  @override
  String get send => 'Send';

  @override
  String get verify => 'Verify';

  @override
  String get filters => 'Filters';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get danceStyle => 'Dance Style';

  @override
  String get eventType => 'Event Type';

  @override
  String get frequency => 'Frequency';

  @override
  String get city => 'City';

  @override
  String get social => 'Social';

  @override
  String get classType => 'Class';

  @override
  String get salsa => 'Salsa';

  @override
  String get bachata => 'Bachata';

  @override
  String get downloadBanner => 'For faster experience';

  @override
  String get downloadButton => 'Download App';

  @override
  String get downloadingSnackbar => 'Downloading app from';

  @override
  String get bankInfoTitle => 'Bank Information';

  @override
  String get bankInfoBank => 'Bank';

  @override
  String get bankInfoAccountHolder => 'Account Holder';

  @override
  String get bankInfoCardNumber => 'Card Number';

  @override
  String get bankInfoClabe => 'CLABE';

  @override
  String bankInfoCopied(String field) {
    return '$field copied to clipboard';
  }

  @override
  String get eventDescriptionTitle => 'Description';
}
