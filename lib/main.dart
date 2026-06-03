import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'services/ad_service.dart';
import 'providers/character_provider.dart';
import 'providers/point_provider.dart';
import 'providers/game_2048_provider.dart';
import 'providers/minesweeper_provider.dart';
import 'providers/sudoku_provider.dart';
import 'repositories/auth_repository.dart';
import 'repositories/point_repository.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Uncomment when real AdMob App IDs are added to manifests
  // await AdService.instance.initialize();
  AdService.instance.initialize(); // preload placeholder ads
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
    ),
  );
  runApp(const PuzzleBoxApp());
}

class PuzzleBoxApp extends StatelessWidget {
  const PuzzleBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(SupabaseAuthRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => PointProvider(LocalPointRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => CharacterProvider()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => SudokuProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Game2048Provider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MinesweeperProvider(),
        ),
      ],
      child: MaterialApp(
        title: '퍼즐박스',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
