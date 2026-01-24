import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'services/injection.dart';
import 'services/notification_service.dart';
import 'services/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (para Auth)
  await Firebase.initializeApp();

  // Initialize Supabase (para Base de Datos)
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Initialize notification service
  await NotificationService().initialize();

  // Initialize dependency injection and settings
  await configureDependencies();

  runApp(const TasklyApp());
}
