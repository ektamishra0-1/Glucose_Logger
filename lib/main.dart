import 'package:flutter/material.dart';

import 'core/themes/app_theme.dart';
import 'features/dashboard/dashboard_page.dart';
import 'core/database/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.instance.database;

  runApp(const GlucoseLoggerApp());
}

class GlucoseLoggerApp extends StatelessWidget {
  const GlucoseLoggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glucose Logger',
      theme: AppTheme.darkTheme,
      home: DashboardPage(),
    );
  }
}
