import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Dance in '**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Think, Just Dance'**
  String get appSubtitle;

  /// No description provided for @buttonFindEvents.
  ///
  /// In en, this message translates to:
  /// **'Find Events In {zone}'**
  String buttonFindEvents(String zone);

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get settingsLanguageSpanish;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @danceEvents.
  ///
  /// In en, this message translates to:
  /// **'Dance Events'**
  String get danceEvents;

  /// No description provided for @noEventsFound.
  ///
  /// In en, this message translates to:
  /// **'No events found in the next 7 days'**
  String get noEventsFound;

  /// No description provided for @noMoreEvents.
  ///
  /// In en, this message translates to:
  /// **'No more new events'**
  String get noMoreEvents;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @errorLoadingEvents.
  ///
  /// In en, this message translates to:
  /// **'Error loading events: {error}'**
  String errorLoadingEvents(String error);

  /// The format pattern for displaying dates. EEEE is full weekday name, MMM is abbreviated month name, d is day of month
  ///
  /// In en, this message translates to:
  /// **'EEEE, MMM d'**
  String get dateFormat;

  /// Comma-separated list of full weekday names, starting with Monday
  ///
  /// In en, this message translates to:
  /// **'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday'**
  String get weekdayNames;

  /// Comma-separated list of weekday abbreviations (Monday through Sunday)
  ///
  /// In en, this message translates to:
  /// **'M,T,W,Th,F,Sa,Su'**
  String get weekdayAbbreviations;

  /// No description provided for @eventNotFound.
  ///
  /// In en, this message translates to:
  /// **'Event not found.'**
  String get eventNotFound;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard!'**
  String get linkCopied;

  /// No description provided for @linkToEvent.
  ///
  /// In en, this message translates to:
  /// **'Link to Event'**
  String get linkToEvent;

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get oneTime;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Repeat Weekly, Every {day}'**
  String repeatWeekly(String day);

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly, Every {week} {day}'**
  String repeatMonthly(String week, String day);

  /// No description provided for @weekOfMonthFirst.
  ///
  /// In en, this message translates to:
  /// **'first'**
  String get weekOfMonthFirst;

  /// No description provided for @weekOfMonthSecond.
  ///
  /// In en, this message translates to:
  /// **'second'**
  String get weekOfMonthSecond;

  /// No description provided for @weekOfMonthThird.
  ///
  /// In en, this message translates to:
  /// **'third'**
  String get weekOfMonthThird;

  /// No description provided for @weekOfMonthFourth.
  ///
  /// In en, this message translates to:
  /// **'fourth'**
  String get weekOfMonthFourth;

  /// No description provided for @weekOfMonthLast.
  ///
  /// In en, this message translates to:
  /// **'last'**
  String get weekOfMonthLast;

  /// No description provided for @areYouExcited.
  ///
  /// In en, this message translates to:
  /// **'Are you going for this event?'**
  String get areYouExcited;

  /// No description provided for @maintainedByCommunity.
  ///
  /// In en, this message translates to:
  /// **'This listing is maintained by the Community'**
  String get maintainedByCommunity;

  /// No description provided for @suggestCorrection.
  ///
  /// In en, this message translates to:
  /// **'Suggest a correction'**
  String get suggestCorrection;

  /// No description provided for @suggestedCorrections.
  ///
  /// In en, this message translates to:
  /// **'Suggested Corrections ({count})'**
  String suggestedCorrections(int count);

  /// No description provided for @onlyThisEvent.
  ///
  /// In en, this message translates to:
  /// **'Only this event on {date}'**
  String onlyThisEvent(String date);

  /// No description provided for @allFutureEvents.
  ///
  /// In en, this message translates to:
  /// **'All future versions of this event'**
  String get allFutureEvents;

  /// No description provided for @needToVerify.
  ///
  /// In en, this message translates to:
  /// **'Need to verify your phone number to vote on proposals'**
  String get needToVerify;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify phone number. Please try again.'**
  String get verificationFailed;

  /// No description provided for @changeFromTo.
  ///
  /// In en, this message translates to:
  /// **'Change {field} from {oldValue} to {newValue}'**
  String changeFromTo(String field, String oldValue, String newValue);

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @forAllEvents.
  ///
  /// In en, this message translates to:
  /// **'For All Events'**
  String get forAllEvents;

  /// No description provided for @onlyThisEventInstance.
  ///
  /// In en, this message translates to:
  /// **'Only This Event'**
  String get onlyThisEventInstance;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dayOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Day of Week'**
  String get dayOfWeek;

  /// No description provided for @weeksOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Weeks of Month'**
  String get weeksOfMonth;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @once.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get once;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @first.
  ///
  /// In en, this message translates to:
  /// **'1st'**
  String get first;

  /// No description provided for @second.
  ///
  /// In en, this message translates to:
  /// **'2nd'**
  String get second;

  /// No description provided for @third.
  ///
  /// In en, this message translates to:
  /// **'3rd'**
  String get third;

  /// No description provided for @fourth.
  ///
  /// In en, this message translates to:
  /// **'4th'**
  String get fourth;

  /// No description provided for @drawerMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get drawerMenu;

  /// No description provided for @drawerHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get drawerHelp;

  /// No description provided for @drawerContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get drawerContact;

  /// No description provided for @drawerAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get drawerAdmin;

  /// No description provided for @drawerRevokeOTP.
  ///
  /// In en, this message translates to:
  /// **'Revoke OTP'**
  String get drawerRevokeOTP;

  /// No description provided for @drawerLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get drawerLogin;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyTitle;

  /// No description provided for @verifyMessage.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number'**
  String get verifyMessage;

  /// No description provided for @verifyMessageRate.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number to rate this event'**
  String get verifyMessageRate;

  /// No description provided for @verifyMessageAdd.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number to add an event'**
  String get verifyMessageAdd;

  /// No description provided for @verifyMessageEdit.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number to edit this event'**
  String get verifyMessageEdit;

  /// No description provided for @verifyMessageVote.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number to vote on proposals'**
  String get verifyMessageVote;

  /// No description provided for @enterOTPCode.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get enterOTPCode;

  /// No description provided for @otpCode.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCode;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @danceStyle.
  ///
  /// In en, this message translates to:
  /// **'Dance Style'**
  String get danceStyle;

  /// No description provided for @eventType.
  ///
  /// In en, this message translates to:
  /// **'Event Type'**
  String get eventType;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @classType.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classType;

  /// No description provided for @salsa.
  ///
  /// In en, this message translates to:
  /// **'Salsa'**
  String get salsa;

  /// No description provided for @bachata.
  ///
  /// In en, this message translates to:
  /// **'Bachata'**
  String get bachata;

  /// No description provided for @downloadBanner.
  ///
  /// In en, this message translates to:
  /// **'For faster experience'**
  String get downloadBanner;

  /// No description provided for @downloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download App'**
  String get downloadButton;

  /// No description provided for @downloadingSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Downloading app from'**
  String get downloadingSnackbar;

  /// No description provided for @bankInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Bank Information'**
  String get bankInfoTitle;

  /// No description provided for @bankInfoBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bankInfoBank;

  /// No description provided for @bankInfoAccountHolder.
  ///
  /// In en, this message translates to:
  /// **'Account Holder'**
  String get bankInfoAccountHolder;

  /// No description provided for @bankInfoCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get bankInfoCardNumber;

  /// No description provided for @bankInfoClabe.
  ///
  /// In en, this message translates to:
  /// **'CLABE'**
  String get bankInfoClabe;

  /// No description provided for @bankInfoCopied.
  ///
  /// In en, this message translates to:
  /// **'{field} copied to clipboard'**
  String bankInfoCopied(String field);

  /// No description provided for @eventDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get eventDescriptionTitle;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
