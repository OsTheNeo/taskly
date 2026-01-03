import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize notification service
  await NotificationService().initialize();

  // Initialize dependency injection
  await configureDependencies();

  // TODO: Initialize Supabase when ready
  // await Supabase.initialize(
  //   url: 'YOUR_SUPABASE_URL',
  //   anonKey: 'YOUR_SUPABASE_ANON_KEY',
  // );

  runApp(const TasklyApp());
}
