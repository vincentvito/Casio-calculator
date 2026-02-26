import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/datasources/local/hive_boxes.dart';
import 'presentation/providers/feedback_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/calculator_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/history_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive
  await HiveBoxes.initialize();

  // Pre-initialize feedback services so sounds are preloaded
  final feedbackProvider = FeedbackProvider();
  await feedbackProvider.initialize();

  runApp(SkeuoCalcApp(feedbackProvider: feedbackProvider));
}

class SkeuoCalcApp extends StatelessWidget {
  final FeedbackProvider feedbackProvider;

  const SkeuoCalcApp({super.key, required this.feedbackProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<SettingsProvider, ThemeProvider>(
          create: (_) => ThemeProvider(),
          update: (_, settings, theme) => theme!..updateFromSettings(settings),
        ),
        ChangeNotifierProxyProvider<SettingsProvider, FeedbackProvider>(
          create: (_) => feedbackProvider,
          update: (_, settings, feedback) =>
              feedback!..updateFromSettings(settings),
        ),
        ChangeNotifierProvider(create: (_) => CalculatorProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Skeuo Calc',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.materialTheme,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
