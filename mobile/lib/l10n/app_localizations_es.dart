// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Baila en ';

  @override
  String get appSubtitle => 'No Pienses, Solo Baila';

  @override
  String buttonFindEvents(String zone) {
    return 'Encuentra tus eventos en $zone';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageEnglish => 'Inglés';

  @override
  String get settingsLanguageSpanish => 'Español';

  @override
  String get searchHint => 'Buscar';

  @override
  String get danceEvents => 'Eventos de Baile';

  @override
  String get noEventsFound => 'No se encontraron eventos';

  @override
  String get noMoreEvents => 'No hay más eventos';

  @override
  String get free => 'Gratis';

  @override
  String errorLoadingEvents(String error) {
    return 'Error al cargar eventos: $error';
  }

  @override
  String get dateFormat => 'EEEE, d \'de\' MMM';

  @override
  String get weekdayNames =>
      'lunes,martes,miércoles,jueves,viernes,sábado,domingo';

  @override
  String get weekdayAbbreviations => 'L,M,X,J,V,S,D';

  @override
  String get eventNotFound => 'Evento no encontrado.';

  @override
  String get linkCopied => '¡Enlace copiado al portapapeles!';

  @override
  String get linkToEvent => 'Enlace al Evento';

  @override
  String get oneTime => 'Una vez';

  @override
  String repeatWeekly(String day) {
    return 'Repetir Semanal, Cada $day';
  }

  @override
  String repeatMonthly(String week, String day) {
    return 'Mensual, Cada $week $day';
  }

  @override
  String get weekOfMonthFirst => 'primer';

  @override
  String get weekOfMonthSecond => 'segundo';

  @override
  String get weekOfMonthThird => 'tercer';

  @override
  String get weekOfMonthFourth => 'cuarto';

  @override
  String get weekOfMonthLast => 'último';

  @override
  String get areYouExcited => '¿Vas a ir a este evento?';

  @override
  String get maintainedByCommunity =>
      'Esta lista es mantenida por la Comunidad';

  @override
  String get suggestCorrection => 'Sugerir una corrección';

  @override
  String suggestedCorrections(int count) {
    return 'Correcciones Sugeridas ($count)';
  }

  @override
  String onlyThisEvent(String date) {
    return 'Solo este evento el $date';
  }

  @override
  String get allFutureEvents => 'Todas las versiones futuras de este evento';

  @override
  String get needToVerify =>
      'Necesitas verificar tu número de teléfono para votar en propuestas';

  @override
  String get verificationFailed =>
      'Error al verificar el número de teléfono. Por favor, inténtalo de nuevo.';

  @override
  String changeFromTo(String field, String oldValue, String newValue) {
    return 'Cambiar $field de $oldValue a $newValue';
  }

  @override
  String get none => 'Ninguno';

  @override
  String get forAllEvents => 'Para Todos los Eventos';

  @override
  String get onlyThisEventInstance => 'Solo Este Evento';

  @override
  String get date => 'Fecha';

  @override
  String get dayOfWeek => 'Día de la Semana';

  @override
  String get weeksOfMonth => 'Semanas del Mes';

  @override
  String get repeat => 'Repetir';

  @override
  String get once => 'Una vez';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get first => '1º';

  @override
  String get second => '2º';

  @override
  String get third => '3º';

  @override
  String get fourth => '4º';

  @override
  String get drawerMenu => 'Menú';

  @override
  String get drawerHelp => 'Ayuda y Preguntas Frecuentes';

  @override
  String get drawerContact => 'Contacto';

  @override
  String get drawerAdmin => 'Admin';

  @override
  String get drawerRevokeOTP => 'Revocar OTP';

  @override
  String get drawerLogin => 'Iniciar Sesión';

  @override
  String get verifyTitle => 'Verificar';

  @override
  String get verifyMessage => 'Verifica tu número de teléfono';

  @override
  String get verifyMessageRate =>
      'Verifica tu número de teléfono para calificar este evento';

  @override
  String get verifyMessageAdd =>
      'Verifica tu número de teléfono para agregar un evento';

  @override
  String get verifyMessageEdit =>
      'Verifica tu número de teléfono para editar este evento';

  @override
  String get verifyMessageVote =>
      'Verifica tu número de teléfono para votar en propuestas';

  @override
  String get enterOTPCode => 'Ingresa el código OTP';

  @override
  String get otpCode => 'Código OTP';

  @override
  String get send => 'Enviar';

  @override
  String get verify => 'Verificar';

  @override
  String get filters => 'Filtros';

  @override
  String get reset => 'Restablecer';

  @override
  String get apply => 'Aplicar';

  @override
  String get danceStyle => 'Estilo de Baile';

  @override
  String get eventType => 'Tipo de Evento';

  @override
  String get frequency => 'Frecuencia';

  @override
  String get city => 'Ciudad';

  @override
  String get social => 'Social';

  @override
  String get classType => 'Clase';

  @override
  String get salsa => 'Salsa';

  @override
  String get bachata => 'Bachata';

  @override
  String get downloadBanner => 'Para un mejor experiencia';

  @override
  String get downloadButton => 'Descarga App';

  @override
  String get downloadingSnackbar => 'Descargando app de';

  @override
  String get bankInfoTitle => 'Información Bancaria';

  @override
  String get bankInfoBank => 'Banco';

  @override
  String get bankInfoAccountHolder => 'Titular de la cuenta';

  @override
  String get bankInfoCardNumber => 'Número de tarjeta';

  @override
  String get bankInfoClabe => 'CLABE';

  @override
  String bankInfoCopied(String field) {
    return '$field copiado al portapapeles';
  }

  @override
  String get eventDescriptionTitle => 'Descripción';
}
