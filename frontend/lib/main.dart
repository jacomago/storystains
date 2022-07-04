import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'common/constant/app_config.dart';
import 'common/constant/app_theme.dart';
import 'common/url_strategy/url_strategy.dart';
import 'common/utils/service_locator.dart';
import 'features/auth/auth_state.dart';
import 'features/emotions/emotion_service.dart';
import 'features/emotions/emotion_state.dart';
import 'features/mediums/medium.dart';
import 'routes/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator.setup();
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => sl.get<AuthState>(),
        ),
        ChangeNotifierProvider(
          create: (_) => EmotionsState(EmotionsService()),
        ),
        ChangeNotifierProvider(
          create: (_) => MediumsState(MediumsService()),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppConfig.appTitle,
        theme: ThemeData(
          colorScheme: lightColorScheme,
          textTheme: GoogleFonts.libreBaskervilleTextTheme(),
        ),
        onGenerateRoute: RouteConfiguration.onGenerateRoute,
      );
}
