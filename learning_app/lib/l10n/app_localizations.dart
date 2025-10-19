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
  /// **'My Bachata Moves'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @watchFreePreview.
  ///
  /// In en, this message translates to:
  /// **'Watch Free Preview'**
  String get watchFreePreview;

  /// No description provided for @introLesson.
  ///
  /// In en, this message translates to:
  /// **'3 minute intro lesson'**
  String get introLesson;

  /// No description provided for @whyChooseCourse.
  ///
  /// In en, this message translates to:
  /// **'Why Choose Our Bachata Course?'**
  String get whyChooseCourse;

  /// No description provided for @onlyForSocials.
  ///
  /// In en, this message translates to:
  /// **'Only For Socials'**
  String get onlyForSocials;

  /// No description provided for @onlyForSocialsDescription.
  ///
  /// In en, this message translates to:
  /// **'All our content is focused on social dancing not choreographies. That means you will be taught all the subtle details so you can perform these moves with anybody.'**
  String get onlyForSocialsDescription;

  /// No description provided for @bodyLanguage.
  ///
  /// In en, this message translates to:
  /// **'Body Language'**
  String get bodyLanguage;

  /// No description provided for @bodyLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Dancing Bachata is a conversation between two bodies. We focus on body language and teach you how to communicate with your partner, how to send signals and how to respond to them.'**
  String get bodyLanguageDescription;

  /// No description provided for @noPrizesOnlyFun.
  ///
  /// In en, this message translates to:
  /// **'No Prizes, Only Fun'**
  String get noPrizesOnlyFun;

  /// No description provided for @noPrizesOnlyFunDescription.
  ///
  /// In en, this message translates to:
  /// **'This is not for people who want to win dance competitions, this is for people who just want to dance and enjoy the moment. We will make it easy for you to have fun.'**
  String get noPrizesOnlyFunDescription;

  /// No description provided for @noBasics.
  ///
  /// In en, this message translates to:
  /// **'No Basics'**
  String get noBasics;

  /// No description provided for @noBasicsDescription.
  ///
  /// In en, this message translates to:
  /// **'This course is for intermediate and advanced dancers. We teach you new moves that you can use to express yourself and connect with your partner even better.'**
  String get noBasicsDescription;

  /// No description provided for @unlimitedReplays.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Replays'**
  String get unlimitedReplays;

  /// No description provided for @unlimitedReplaysDescription.
  ///
  /// In en, this message translates to:
  /// **'In workshops it is hard to remember everything you learned, but with pre-recorded videos you can watch them over and over again till it becomes second nature.'**
  String get unlimitedReplaysDescription;

  /// No description provided for @easyReview.
  ///
  /// In en, this message translates to:
  /// **'Easy Review'**
  String get easyReview;

  /// No description provided for @easyReviewDescription.
  ///
  /// In en, this message translates to:
  /// **'We have a dedicated section for reviewing the moves you have learned. So when your memory gets fuzzy, you can quickly refresh it.'**
  String get easyReviewDescription;

  /// No description provided for @buyForPrice.
  ///
  /// In en, this message translates to:
  /// **'Buy for \${price} {currency}'**
  String buyForPrice(int price, String currency);

  /// No description provided for @refundPolicy.
  ///
  /// In en, this message translates to:
  /// **'If you are not satisfied with the course, you can cancel within 48 hours and get a full refund. No questions asked.'**
  String get refundPolicy;

  /// No description provided for @footerTagline.
  ///
  /// In en, this message translates to:
  /// **'Learn new bachata sensual moves from the comfort of your home.'**
  String get footerTagline;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2024 Only For Bachateros. All rights reserved.'**
  String get copyright;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ♥ for bachata lovers worldwide'**
  String get madeWithLove;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'+1 555 123 4567'**
  String get phoneNumberHint;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @backToPhoneInput.
  ///
  /// In en, this message translates to:
  /// **'Back to phone input'**
  String get backToPhoneInput;

  /// No description provided for @completeYourPurchase.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Purchase'**
  String get completeYourPurchase;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// No description provided for @paymentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your purchase. You will receive access to the course shortly.'**
  String get paymentSuccessMessage;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @loginRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please log in to complete your purchase.'**
  String get loginRequiredMessage;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to Continue'**
  String get loginToContinue;

  /// No description provided for @bachataCoursePrice.
  ///
  /// In en, this message translates to:
  /// **'Bachata Course - \${price} {currency}'**
  String bachataCoursePrice(int price, String currency);

  /// No description provided for @courseDescription.
  ///
  /// In en, this message translates to:
  /// **'Get lifetime access to our comprehensive bachata course with unlimited replays.'**
  String get courseDescription;

  /// No description provided for @securePaymentMessage.
  ///
  /// In en, this message translates to:
  /// **'Secure payment powered by Stripe'**
  String get securePaymentMessage;

  /// No description provided for @continueToPayment.
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment'**
  String get continueToPayment;

  /// No description provided for @payAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay \${price} {currency}'**
  String payAmount(int price, String currency);

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorOccurred;

  /// No description provided for @promoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Promotional code'**
  String get promoCodeHint;

  /// No description provided for @applyPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyPromoCode;

  /// No description provided for @promoCodeApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get promoCodeApplied;

  /// No description provided for @invalidPromoCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidPromoCode;

  /// No description provided for @discountApplied.
  ///
  /// In en, this message translates to:
  /// **'5% discount applied!'**
  String get discountApplied;
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
