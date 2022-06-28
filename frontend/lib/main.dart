import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/constant/app_theme.dart';
import 'package:storystains/common/url_strategy/url_strategy.dart';
import 'package:storystains/common/utils/services.dart';
import 'package:storystains/features/emotions/emotion_service.dart';
import 'package:storystains/features/emotions/emotion_state.dart';
import 'package:storystains/routes/routes.dart';

import 'common/constant/app_config.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/auth_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Services.setup();
  usePathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthState(AuthService()),
        ),
        ChangeNotifierProvider(
          create: (_) => EmotionsState(EmotionsService()),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appTitle,
      theme: ThemeData(
        colorScheme: lightColorScheme,
        textTheme: GoogleFonts.libreBaskervilleTextTheme(),
      ),
      onGenerateRoute: RouteConfiguration.onGenerateRoute,
    );
  }
}
