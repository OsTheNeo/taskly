// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Taskly';

  @override
  String get today => 'Today';

  @override
  String get tasks => 'Tasks';

  @override
  String get profile => 'Profile';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get progressToday => 'Today\'s progress';

  @override
  String get completed => 'completed';

  @override
  String get pending => 'pending';

  @override
  String get myTasks => 'My tasks';

  @override
  String get householdTasks => 'Household tasks';

  @override
  String completedToday(int completed, int total) {
    return '$completed/$total completed today';
  }

  @override
  String get viewAll => 'View all';

  @override
  String get newTask => 'New task';

  @override
  String get title => 'Title';

  @override
  String get titlePlaceholder => 'Ex: Read 30 minutes';

  @override
  String get taskType => 'Task type';

  @override
  String get personal => 'Personal';

  @override
  String get group => 'Group';

  @override
  String get goalWithProgress => 'Goal with progress';

  @override
  String get trackDailyProgress => 'Track daily progress';

  @override
  String get dailyGoal => 'Daily goal';

  @override
  String get unit => 'Unit';

  @override
  String get frequency => 'Frequency';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get biweekly => 'Biweekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get custom => 'Custom';

  @override
  String get selectDays => 'Select days';

  @override
  String get reminder => 'Reminder';

  @override
  String atTime(String time) {
    return 'At $time';
  }

  @override
  String get noReminder => 'No reminder';

  @override
  String get saveTask => 'Save task';

  @override
  String get enterTitle => 'Please enter a title';

  @override
  String get notificationDisabled => 'Notification disabled';

  @override
  String get notificationEnabled => 'We\'ll notify you when completed';

  @override
  String get minutes => 'minutes';

  @override
  String get hours => 'hours';

  @override
  String get times => 'times';

  @override
  String get pages => 'pages';

  @override
  String get km => 'km';

  @override
  String get glasses => 'glasses';

  @override
  String get logProgress => 'Log progress';

  @override
  String get addTime => 'Add';

  @override
  String remaining(int count, String unit) {
    return '$count $unit remaining';
  }

  @override
  String get goalCompleted => 'Goal completed!';

  @override
  String get save => 'Save';

  @override
  String get login => 'Login';

  @override
  String get createAccount => 'Create account';

  @override
  String get loginToSync => 'Login to sync';

  @override
  String get syncBenefits =>
      'Save your progress, sync across devices and share tasks with others';

  @override
  String get cloudSync => 'Cloud sync';

  @override
  String get cloudSyncDesc => 'Access your data from any device';

  @override
  String get autoBackup => 'Auto backup';

  @override
  String get autoBackupDesc => 'Never lose your progress';

  @override
  String get sharedTasks => 'Shared tasks';

  @override
  String get sharedTasksDesc => 'Create groups and share tasks';

  @override
  String get advancedStats => 'Advanced stats';

  @override
  String get advancedStatsDesc => 'View your historical progress';

  @override
  String get email => 'Email';

  @override
  String get emailPlaceholder => 'your@email.com';

  @override
  String get password => 'Password';

  @override
  String get passwordPlaceholder => '********';

  @override
  String get name => 'Name';

  @override
  String get namePlaceholder => 'Your name';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get logout => 'Logout';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get signUpWithGoogle => 'Sign up with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get signUpWithApple => 'Sign up with Apple';

  @override
  String get orContinueWithEmail => 'or continue with email';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get register => 'Register';

  @override
  String get continueWithoutAccount => 'Continue without account';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get groups => 'Groups';

  @override
  String get personalTasks => 'Personal tasks';

  @override
  String get noPersonalTasks => 'No personal tasks';

  @override
  String get createTask => 'Create task';

  @override
  String get createOrJoinGroup => 'Create or join a group';

  @override
  String get shareTasksWithOthers => 'Share tasks with family or roommates';

  @override
  String get createGroup => 'Create group';

  @override
  String get join => 'Join';

  @override
  String get members => 'members';

  @override
  String get newPersonalTask => 'New personal task';

  @override
  String get groupName => 'Group name';

  @override
  String get groupNamePlaceholder => 'Ex: Home, Work';

  @override
  String get invitationCode => 'Invitation code';

  @override
  String get enterCode => 'Enter the code';

  @override
  String get once => 'Once';

  @override
  String get joinGroup => 'Join a group';

  @override
  String nMembers(int count) {
    return '$count members';
  }

  @override
  String nTasks(int count) {
    return '$count tasks';
  }

  @override
  String get shareQrCode => 'Share QR Code';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get inviteMembers => 'Invite members';

  @override
  String get scanToJoin => 'Scan to join';

  @override
  String get shareThisCode => 'Share this code so others can join your group';

  @override
  String get pointCameraAtQr =>
      'Point your camera at a QR code to join a group';

  @override
  String get invalidQrCode => 'Invalid QR code';

  @override
  String get groupCode => 'Group code';
}
