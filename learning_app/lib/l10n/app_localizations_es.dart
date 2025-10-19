// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'My Bachata Moves';

  @override
  String get login => 'Iniciar';

  @override
  String get logout => 'Cerrar';

  @override
  String get watchFreePreview => 'Ver Vista Previa';

  @override
  String get introLesson => 'Lección introductoria de 3 minutos';

  @override
  String get whyChooseCourse => '¿Por Qué Elegir Nuestro Curso de Bachata?';

  @override
  String get onlyForSocials => 'Solo Para Sociales';

  @override
  String get onlyForSocialsDescription =>
      'Todo nuestro contenido se enfoca en el baile social, no en coreografías. Esto significa que te enseñaremos todos los detalles sutiles para que puedas realizar estos movimientos con cualquiera.';

  @override
  String get bodyLanguage => 'Lenguaje Corporal';

  @override
  String get bodyLanguageDescription =>
      'Bailar Bachata es una conversación entre dos cuerpos. Nos enfocamos en el lenguaje corporal y te enseñamos cómo comunicarte con tu pareja, cómo enviar señales y cómo responder a ellas.';

  @override
  String get noPrizesOnlyFun => 'Sin Premios, Solo Diversión';

  @override
  String get noPrizesOnlyFunDescription =>
      'Esto no es para personas que quieren ganar competencias de baile, es para personas que solo quieren bailar y disfrutar el momento. Te facilitaremos la diversión.';

  @override
  String get noBasics => 'Sin Básicos';

  @override
  String get noBasicsDescription =>
      'Este curso es para bailarines intermedios y avanzados. Te enseñamos nuevos movimientos que puedes usar para expresarte y conectar mejor con tu pareja.';

  @override
  String get unlimitedReplays => 'Reproducciones Ilimitadas';

  @override
  String get unlimitedReplaysDescription =>
      'En talleres es difícil recordar todo lo que aprendiste, pero con videos pregrabados puedes verlos una y otra vez hasta que se conviertan en algo natural.';

  @override
  String get easyReview => 'Revisión Fácil';

  @override
  String get easyReviewDescription =>
      'Tenemos una sección dedicada para revisar los movimientos que has aprendido. Así que cuando tu memoria se nuble, puedes refrescarla rápidamente.';

  @override
  String buyForPrice(int price, String currency) {
    return 'Comprar por \$$price $currency';
  }

  @override
  String get refundPolicy =>
      'Si no estás satisfecho con el curso, puedes cancelar dentro de las 48 horas y obtener un reembolso completo. Sin preguntas.';

  @override
  String get footerTagline =>
      'Aprende nuevos movimientos de bachata sensual desde la comodidad de tu hogar.';

  @override
  String get copyright =>
      '© 2024 Solo Para Bachateros. Todos los derechos reservados.';

  @override
  String get madeWithLove =>
      'Hecho con ♥ para amantes de la bachata en todo el mundo';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get phoneNumber => 'Número de teléfono';

  @override
  String get phoneNumberHint => '+1 555 123 4567';

  @override
  String get sendOtp => 'Enviar OTP';

  @override
  String get signInWithApple => 'Iniciar sesión con Apple';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get enterOtp => 'Ingresar OTP';

  @override
  String get verifyOtp => 'Verificar OTP';

  @override
  String get backToPhoneInput => 'Volver al ingreso de teléfono';

  @override
  String get completeYourPurchase => 'Completa tu Compra';

  @override
  String get paymentSuccessful => '¡Pago Exitoso!';

  @override
  String get paymentSuccessMessage =>
      'Gracias por tu compra. Recibirás acceso al curso en breve.';

  @override
  String get loginRequired => 'Inicio de Sesión Requerido';

  @override
  String get loginRequiredMessage =>
      'Por favor inicia sesión para completar tu compra.';

  @override
  String get loginToContinue => 'Iniciar Sesión para Continuar';

  @override
  String bachataCoursePrice(int price, String currency) {
    return 'Curso de Bachata - \$$price $currency';
  }

  @override
  String get courseDescription =>
      'Obtén acceso de por vida a nuestro curso completo de bachata con reproducciones ilimitadas.';

  @override
  String get securePaymentMessage => 'Pago seguro impulsado por Stripe';

  @override
  String get continueToPayment => 'Continuar al Pago';

  @override
  String payAmount(int price, String currency) {
    return 'Pagar \$$price $currency';
  }

  @override
  String get errorOccurred => 'Ocurrió un error. Por favor inténtalo de nuevo.';

  @override
  String get promoCodeHint => 'Código promocional';

  @override
  String get applyPromoCode => 'Aplicar';

  @override
  String get promoCodeApplied => 'Código aplicado';

  @override
  String get invalidPromoCode => 'Código inválido';

  @override
  String get discountApplied => '¡5% de descuento aplicado!';
}
