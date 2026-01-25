// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class SEs extends S {
  SEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Taskly';

  @override
  String get today => 'Hoy';

  @override
  String get home => 'Inicio';

  @override
  String get dailyGoals => 'Metas diarias';

  @override
  String get todayTasks => 'Tareas de hoy';

  @override
  String get tasks => 'Tareas';

  @override
  String get profile => 'Perfil';

  @override
  String get goodMorning => 'Buenos dias';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get progressToday => 'Progreso del dia';

  @override
  String get completed => 'completadas';

  @override
  String get pending => 'pendientes';

  @override
  String get myTasks => 'Mis tareas';

  @override
  String get householdTasks => 'Tareas del hogar';

  @override
  String completedToday(int completed, int total) {
    return '$completed/$total completadas hoy';
  }

  @override
  String get viewAll => 'Ver todo';

  @override
  String get newTask => 'Nueva tarea';

  @override
  String get title => 'Titulo';

  @override
  String get titlePlaceholder => 'Ej: Leer 30 minutos';

  @override
  String get taskType => 'Tipo de tarea';

  @override
  String get personal => 'Personal';

  @override
  String get group => 'Grupo';

  @override
  String get goalWithProgress => 'Es una meta con progreso';

  @override
  String get trackDailyProgress => 'Registra progreso diario';

  @override
  String get dailyGoal => 'Meta diaria';

  @override
  String get unit => 'Unidad';

  @override
  String get frequency => 'Frecuencia';

  @override
  String get daily => 'Diario';

  @override
  String get weekly => 'Semanal';

  @override
  String get biweekly => 'Cada 2 sem';

  @override
  String get monthly => 'Mensual';

  @override
  String get custom => 'Personalizado';

  @override
  String get selectDays => 'Selecciona los dias';

  @override
  String get reminder => 'Recordatorio';

  @override
  String atTime(String time) {
    return 'A las $time';
  }

  @override
  String get noReminder => 'Sin recordatorio';

  @override
  String get tapToSetTime => 'Toca para configurar hora';

  @override
  String get saveTask => 'Guardar tarea';

  @override
  String get enterTitle => 'Por favor ingresa un titulo';

  @override
  String get notificationDisabled => 'Notificacion desactivada';

  @override
  String get notificationEnabled => 'Te notificaremos cuando se complete';

  @override
  String get minutes => 'minutos';

  @override
  String get hours => 'horas';

  @override
  String get times => 'veces';

  @override
  String get pages => 'paginas';

  @override
  String get km => 'km';

  @override
  String get glasses => 'vasos';

  @override
  String get logProgress => 'Registrar progreso';

  @override
  String get addTime => 'Agregar';

  @override
  String remaining(int count, String unit) {
    return 'Faltan $count $unit para completar';
  }

  @override
  String get goalCompleted => 'Meta completada!';

  @override
  String get save => 'Guardar';

  @override
  String get login => 'Iniciar sesion';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get loginToSync => 'Inicia sesion para sincronizar';

  @override
  String get syncBenefits =>
      'Guarda tu progreso, sincroniza entre dispositivos y comparte tareas con otros';

  @override
  String get cloudSync => 'Sincronizacion en la nube';

  @override
  String get cloudSyncDesc => 'Accede a tus datos desde cualquier dispositivo';

  @override
  String get autoBackup => 'Backup automatico';

  @override
  String get autoBackupDesc => 'Nunca pierdas tu progreso';

  @override
  String get sharedTasks => 'Tareas compartidas';

  @override
  String get sharedTasksDesc => 'Crea grupos y comparte tareas';

  @override
  String get advancedStats => 'Estadisticas avanzadas';

  @override
  String get advancedStatsDesc => 'Mira tu progreso historico';

  @override
  String get email => 'Email';

  @override
  String get emailPlaceholder => 'tu@email.com';

  @override
  String get password => 'Contrasena';

  @override
  String get passwordPlaceholder => '********';

  @override
  String get name => 'Nombre';

  @override
  String get namePlaceholder => 'Tu nombre';

  @override
  String get forgotPassword => 'Olvidaste tu contrasena?';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get darkTheme => 'Tema oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get help => 'Ayuda';

  @override
  String get about => 'Acerca de';

  @override
  String get logout => 'Cerrar sesion';

  @override
  String get camera => 'Camara';

  @override
  String get gallery => 'Galeria';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get createYourAccount => 'Crea tu cuenta';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get signUpWithGoogle => 'Registrarse con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get signUpWithApple => 'Registrarse con Apple';

  @override
  String get orContinueWithEmail => 'o continua con email';

  @override
  String get noAccount => 'No tienes cuenta?';

  @override
  String get haveAccount => 'Ya tienes cuenta?';

  @override
  String get register => 'Registrate';

  @override
  String get continueWithoutAccount => 'Continuar sin cuenta';

  @override
  String get fillAllFields => 'Por favor completa todos los campos';

  @override
  String get groups => 'Grupos';

  @override
  String get personalTasks => 'Personales';

  @override
  String get noPersonalTasks => 'No tienes tareas personales';

  @override
  String get createTask => 'Crear tarea';

  @override
  String get createOrJoinGroup => 'Crea o unete a un grupo';

  @override
  String get shareTasksWithOthers => 'Comparte tareas con familia o companeros';

  @override
  String get createGroup => 'Crear grupo';

  @override
  String get join => 'Unirse';

  @override
  String get members => 'miembros';

  @override
  String get newPersonalTask => 'Nueva tarea personal';

  @override
  String get groupName => 'Nombre del grupo';

  @override
  String get groupNamePlaceholder => 'Ej: Casa, Trabajo';

  @override
  String get invitationCode => 'Codigo de invitacion';

  @override
  String get enterCode => 'Ingresa el codigo';

  @override
  String get once => 'Una vez';

  @override
  String get joinGroup => 'Unirse a un grupo';

  @override
  String nMembers(int count) {
    return '$count miembros';
  }

  @override
  String nTasks(int count) {
    return '$count tareas';
  }

  @override
  String get shareQrCode => 'Compartir codigo QR';

  @override
  String get scanQrCode => 'Escanear codigo QR';

  @override
  String get inviteMembers => 'Invitar miembros';

  @override
  String get scanToJoin => 'Escanear para unirse';

  @override
  String get shareThisCode =>
      'Comparte este codigo para que otros se unan a tu grupo';

  @override
  String get pointCameraAtQr =>
      'Apunta tu camara al codigo QR para unirte a un grupo';

  @override
  String get invalidQrCode => 'Codigo QR invalido';

  @override
  String get groupCode => 'Codigo del grupo';
}
