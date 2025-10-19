// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Bachata Moves';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get watchFreePreview => 'Watch Free Preview';

  @override
  String get introLesson => '3 minute intro lesson';

  @override
  String get whyChooseCourse => 'Why Choose Our Bachata Course?';

  @override
  String get onlyForSocials => 'Only For Socials';

  @override
  String get onlyForSocialsDescription =>
      'All our content is focused on social dancing not choreographies. That means you will be taught all the subtle details so you can perform these moves with anybody.';

  @override
  String get bodyLanguage => 'Body Language';

  @override
  String get bodyLanguageDescription =>
      'Dancing Bachata is a conversation between two bodies. We focus on body language and teach you how to communicate with your partner, how to send signals and how to respond to them.';

  @override
  String get noPrizesOnlyFun => 'No Prizes, Only Fun';

  @override
  String get noPrizesOnlyFunDescription =>
      'This is not for people who want to win dance competitions, this is for people who just want to dance and enjoy the moment. We will make it easy for you to have fun.';

  @override
  String get noBasics => 'No Basics';

  @override
  String get noBasicsDescription =>
      'This course is for intermediate and advanced dancers. We teach you new moves that you can use to express yourself and connect with your partner even better.';

  @override
  String get unlimitedReplays => 'Unlimited Replays';

  @override
  String get unlimitedReplaysDescription =>
      'In workshops it is hard to remember everything you learned, but with pre-recorded videos you can watch them over and over again till it becomes second nature.';

  @override
  String get easyReview => 'Easy Review';

  @override
  String get easyReviewDescription =>
      'We have a dedicated section for reviewing the moves you have learned. So when your memory gets fuzzy, you can quickly refresh it.';

  @override
  String buyForPrice(int price, String currency) {
    return 'Buy for \$$price $currency';
  }

  @override
  String get refundPolicy =>
      'If you are not satisfied with the course, you can cancel within 48 hours and get a full refund. No questions asked.';

  @override
  String get footerTagline =>
      'Learn new bachata sensual moves from the comfort of your home.';

  @override
  String get copyright => '© 2024 Only For Bachateros. All rights reserved.';

  @override
  String get madeWithLove => 'Made with ♥ for bachata lovers worldwide';

  @override
  String get signIn => 'Sign in';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneNumberHint => '+1 555 123 4567';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get backToPhoneInput => 'Back to phone input';

  @override
  String get completeYourPurchase => 'Complete Your Purchase';

  @override
  String get paymentSuccessful => 'Payment Successful!';

  @override
  String get paymentSuccessMessage =>
      'Thank you for your purchase. You will receive access to the course shortly.';

  @override
  String get loginRequired => 'Login Required';

  @override
  String get loginRequiredMessage => 'Please log in to complete your purchase.';

  @override
  String get loginToContinue => 'Login to Continue';

  @override
  String bachataCoursePrice(int price, String currency) {
    return 'Bachata Course - \$$price $currency';
  }

  @override
  String get courseDescription =>
      'Get lifetime access to our comprehensive bachata course with unlimited replays.';

  @override
  String get securePaymentMessage => 'Secure payment powered by Stripe';

  @override
  String get continueToPayment => 'Continue to Payment';

  @override
  String payAmount(int price, String currency) {
    return 'Pay \$$price $currency';
  }

  @override
  String get errorOccurred => 'An error occurred. Please try again.';

  @override
  String get promoCodeHint => 'Promotional code';

  @override
  String get applyPromoCode => 'Apply';

  @override
  String get promoCodeApplied => 'Applied';

  @override
  String get invalidPromoCode => 'Invalid code';

  @override
  String get discountApplied => '5% discount applied!';
}
