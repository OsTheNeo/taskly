import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
  /// In es, this message translates to:
  /// **'Taskly'**
  String get appTitle;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get today;

  /// No description provided for @home.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// No description provided for @dailyGoals.
  ///
  /// In es, this message translates to:
  /// **'Metas diarias'**
  String get dailyGoals;

  /// No description provided for @todayTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas de hoy'**
  String get todayTasks;

  /// No description provided for @tasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get tasks;

  /// No description provided for @profile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @goodMorning.
  ///
  /// In es, this message translates to:
  /// **'Buenos dias'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In es, this message translates to:
  /// **'Buenas noches'**
  String get goodEvening;

  /// No description provided for @progressToday.
  ///
  /// In es, this message translates to:
  /// **'Progreso del dia'**
  String get progressToday;

  /// No description provided for @completed.
  ///
  /// In es, this message translates to:
  /// **'completadas'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In es, this message translates to:
  /// **'pendientes'**
  String get pending;

  /// No description provided for @myTasks.
  ///
  /// In es, this message translates to:
  /// **'Mis tareas'**
  String get myTasks;

  /// No description provided for @householdTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas del hogar'**
  String get householdTasks;

  /// No description provided for @completedToday.
  ///
  /// In es, this message translates to:
  /// **'{completed}/{total} completadas hoy'**
  String completedToday(int completed, int total);

  /// No description provided for @viewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todo'**
  String get viewAll;

  /// No description provided for @newTask.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea'**
  String get newTask;

  /// No description provided for @title.
  ///
  /// In es, this message translates to:
  /// **'Titulo'**
  String get title;

  /// No description provided for @titlePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Ej: Leer 30 minutos'**
  String get titlePlaceholder;

  /// No description provided for @taskType.
  ///
  /// In es, this message translates to:
  /// **'Tipo de tarea'**
  String get taskType;

  /// No description provided for @personal.
  ///
  /// In es, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @group.
  ///
  /// In es, this message translates to:
  /// **'Grupo'**
  String get group;

  /// No description provided for @goalWithProgress.
  ///
  /// In es, this message translates to:
  /// **'Es una meta con progreso'**
  String get goalWithProgress;

  /// No description provided for @trackDailyProgress.
  ///
  /// In es, this message translates to:
  /// **'Registra progreso diario'**
  String get trackDailyProgress;

  /// No description provided for @dailyGoal.
  ///
  /// In es, this message translates to:
  /// **'Meta diaria'**
  String get dailyGoal;

  /// No description provided for @unit.
  ///
  /// In es, this message translates to:
  /// **'Unidad'**
  String get unit;

  /// No description provided for @frequency.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia'**
  String get frequency;

  /// No description provided for @daily.
  ///
  /// In es, this message translates to:
  /// **'Diario'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In es, this message translates to:
  /// **'Semanal'**
  String get weekly;

  /// No description provided for @biweekly.
  ///
  /// In es, this message translates to:
  /// **'Cada 2 sem'**
  String get biweekly;

  /// No description provided for @monthly.
  ///
  /// In es, this message translates to:
  /// **'Mensual'**
  String get monthly;

  /// No description provided for @custom.
  ///
  /// In es, this message translates to:
  /// **'Personalizado'**
  String get custom;

  /// No description provided for @selectDays.
  ///
  /// In es, this message translates to:
  /// **'Selecciona los dias'**
  String get selectDays;

  /// No description provided for @reminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio'**
  String get reminder;

  /// No description provided for @atTime.
  ///
  /// In es, this message translates to:
  /// **'A las {time}'**
  String atTime(String time);

  /// No description provided for @noReminder.
  ///
  /// In es, this message translates to:
  /// **'Sin recordatorio'**
  String get noReminder;

  /// No description provided for @tapToSetTime.
  ///
  /// In es, this message translates to:
  /// **'Toca para configurar hora'**
  String get tapToSetTime;

  /// No description provided for @saveTask.
  ///
  /// In es, this message translates to:
  /// **'Guardar tarea'**
  String get saveTask;

  /// No description provided for @enterTitle.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa un titulo'**
  String get enterTitle;

  /// No description provided for @notificationDisabled.
  ///
  /// In es, this message translates to:
  /// **'Notificacion desactivada'**
  String get notificationDisabled;

  /// No description provided for @notificationEnabled.
  ///
  /// In es, this message translates to:
  /// **'Te notificaremos cuando se complete'**
  String get notificationEnabled;

  /// No description provided for @minutes.
  ///
  /// In es, this message translates to:
  /// **'minutos'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In es, this message translates to:
  /// **'horas'**
  String get hours;

  /// No description provided for @times.
  ///
  /// In es, this message translates to:
  /// **'veces'**
  String get times;

  /// No description provided for @pages.
  ///
  /// In es, this message translates to:
  /// **'paginas'**
  String get pages;

  /// No description provided for @km.
  ///
  /// In es, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @glasses.
  ///
  /// In es, this message translates to:
  /// **'vasos'**
  String get glasses;

  /// No description provided for @logProgress.
  ///
  /// In es, this message translates to:
  /// **'Registrar progreso'**
  String get logProgress;

  /// No description provided for @addTime.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get addTime;

  /// No description provided for @remaining.
  ///
  /// In es, this message translates to:
  /// **'Faltan {count} {unit} para completar'**
  String remaining(int count, String unit);

  /// No description provided for @goalCompleted.
  ///
  /// In es, this message translates to:
  /// **'Meta completada!'**
  String get goalCompleted;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesion'**
  String get login;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// No description provided for @loginToSync.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesion para sincronizar'**
  String get loginToSync;

  /// No description provided for @syncBenefits.
  ///
  /// In es, this message translates to:
  /// **'Guarda tu progreso, sincroniza entre dispositivos y comparte tareas con otros'**
  String get syncBenefits;

  /// No description provided for @cloudSync.
  ///
  /// In es, this message translates to:
  /// **'Sincronizacion en la nube'**
  String get cloudSync;

  /// No description provided for @cloudSyncDesc.
  ///
  /// In es, this message translates to:
  /// **'Accede a tus datos desde cualquier dispositivo'**
  String get cloudSyncDesc;

  /// No description provided for @autoBackup.
  ///
  /// In es, this message translates to:
  /// **'Backup automatico'**
  String get autoBackup;

  /// No description provided for @autoBackupDesc.
  ///
  /// In es, this message translates to:
  /// **'Nunca pierdas tu progreso'**
  String get autoBackupDesc;

  /// No description provided for @sharedTasks.
  ///
  /// In es, this message translates to:
  /// **'Tareas compartidas'**
  String get sharedTasks;

  /// No description provided for @sharedTasksDesc.
  ///
  /// In es, this message translates to:
  /// **'Crea grupos y comparte tareas'**
  String get sharedTasksDesc;

  /// No description provided for @advancedStats.
  ///
  /// In es, this message translates to:
  /// **'Estadisticas avanzadas'**
  String get advancedStats;

  /// No description provided for @advancedStatsDesc.
  ///
  /// In es, this message translates to:
  /// **'Mira tu progreso historico'**
  String get advancedStatsDesc;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'tu@email.com'**
  String get emailPlaceholder;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contrasena'**
  String get password;

  /// No description provided for @passwordPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'********'**
  String get passwordPlaceholder;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get name;

  /// No description provided for @namePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get namePlaceholder;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'Olvidaste tu contrasena?'**
  String get forgotPassword;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @darkTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema oscuro'**
  String get darkTheme;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @help.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get help;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesion'**
  String get logout;

  /// No description provided for @camera.
  ///
  /// In es, this message translates to:
  /// **'Camara'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In es, this message translates to:
  /// **'Galeria'**
  String get gallery;

  /// No description provided for @welcomeBack.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get welcomeBack;

  /// No description provided for @createYourAccount.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get createYourAccount;

  /// No description provided for @continueWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get continueWithGoogle;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Registrarse con Google'**
  String get signUpWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Apple'**
  String get continueWithApple;

  /// No description provided for @signUpWithApple.
  ///
  /// In es, this message translates to:
  /// **'Registrarse con Apple'**
  String get signUpWithApple;

  /// No description provided for @orContinueWithEmail.
  ///
  /// In es, this message translates to:
  /// **'o continua con email'**
  String get orContinueWithEmail;

  /// No description provided for @noAccount.
  ///
  /// In es, this message translates to:
  /// **'No tienes cuenta?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes cuenta?'**
  String get haveAccount;

  /// No description provided for @register.
  ///
  /// In es, this message translates to:
  /// **'Registrate'**
  String get register;

  /// No description provided for @continueWithoutAccount.
  ///
  /// In es, this message translates to:
  /// **'Continuar sin cuenta'**
  String get continueWithoutAccount;

  /// No description provided for @fillAllFields.
  ///
  /// In es, this message translates to:
  /// **'Por favor completa todos los campos'**
  String get fillAllFields;

  /// No description provided for @groups.
  ///
  /// In es, this message translates to:
  /// **'Grupos'**
  String get groups;

  /// No description provided for @personalTasks.
  ///
  /// In es, this message translates to:
  /// **'Personales'**
  String get personalTasks;

  /// No description provided for @noPersonalTasks.
  ///
  /// In es, this message translates to:
  /// **'No tienes tareas personales'**
  String get noPersonalTasks;

  /// No description provided for @createTask.
  ///
  /// In es, this message translates to:
  /// **'Crear tarea'**
  String get createTask;

  /// No description provided for @createOrJoinGroup.
  ///
  /// In es, this message translates to:
  /// **'Crea o unete a un grupo'**
  String get createOrJoinGroup;

  /// No description provided for @shareTasksWithOthers.
  ///
  /// In es, this message translates to:
  /// **'Comparte tareas con familia o companeros'**
  String get shareTasksWithOthers;

  /// No description provided for @createGroup.
  ///
  /// In es, this message translates to:
  /// **'Crear grupo'**
  String get createGroup;

  /// No description provided for @join.
  ///
  /// In es, this message translates to:
  /// **'Unirse'**
  String get join;

  /// No description provided for @members.
  ///
  /// In es, this message translates to:
  /// **'miembros'**
  String get members;

  /// No description provided for @newPersonalTask.
  ///
  /// In es, this message translates to:
  /// **'Nueva tarea personal'**
  String get newPersonalTask;

  /// No description provided for @groupName.
  ///
  /// In es, this message translates to:
  /// **'Nombre del grupo'**
  String get groupName;

  /// No description provided for @groupNamePlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Ej: Casa, Trabajo'**
  String get groupNamePlaceholder;

  /// No description provided for @invitationCode.
  ///
  /// In es, this message translates to:
  /// **'Codigo de invitacion'**
  String get invitationCode;

  /// No description provided for @enterCode.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el codigo'**
  String get enterCode;

  /// No description provided for @once.
  ///
  /// In es, this message translates to:
  /// **'Una vez'**
  String get once;

  /// No description provided for @joinGroup.
  ///
  /// In es, this message translates to:
  /// **'Unirse a un grupo'**
  String get joinGroup;

  /// No description provided for @nMembers.
  ///
  /// In es, this message translates to:
  /// **'{count} miembros'**
  String nMembers(int count);

  /// No description provided for @nTasks.
  ///
  /// In es, this message translates to:
  /// **'{count} tareas'**
  String nTasks(int count);

  /// No description provided for @shareQrCode.
  ///
  /// In es, this message translates to:
  /// **'Compartir codigo QR'**
  String get shareQrCode;

  /// No description provided for @scanQrCode.
  ///
  /// In es, this message translates to:
  /// **'Escanear codigo QR'**
  String get scanQrCode;

  /// No description provided for @inviteMembers.
  ///
  /// In es, this message translates to:
  /// **'Invitar miembros'**
  String get inviteMembers;

  /// No description provided for @scanToJoin.
  ///
  /// In es, this message translates to:
  /// **'Escanear para unirse'**
  String get scanToJoin;

  /// No description provided for @shareThisCode.
  ///
  /// In es, this message translates to:
  /// **'Comparte este codigo para que otros se unan a tu grupo'**
  String get shareThisCode;

  /// No description provided for @pointCameraAtQr.
  ///
  /// In es, this message translates to:
  /// **'Apunta tu camara al codigo QR para unirte a un grupo'**
  String get pointCameraAtQr;

  /// No description provided for @invalidQrCode.
  ///
  /// In es, this message translates to:
  /// **'Codigo QR invalido'**
  String get invalidQrCode;

  /// No description provided for @groupCode.
  ///
  /// In es, this message translates to:
  /// **'Codigo del grupo'**
  String get groupCode;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'es':
      return SEs();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
