import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/settings/theme_provider.dart';
import 'routes/app_router.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await LocalStorageService.init();
  
  runApp(
    const ProviderScope(
      child: PickleDeskApp(),
    ),
  );
}

class PickleDeskApp extends ConsumerWidget {
  const PickleDeskApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeId = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'PickleDesk',
      theme: AppTheme.themeFor(themeId),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

