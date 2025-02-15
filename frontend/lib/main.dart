import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'common/constant/app_theme.dart';
import 'common/url_strategy/url_strategy.dart';
import 'common/utils/service_locator.dart';
import 'common/utils/utils.dart';
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
          create: (_) => ServiceLocator.sl.get<AuthState>(),
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

/// The main app
class App extends StatelessWidget {
  /// The main app
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => context.locale.appName,
        theme: ThemeData(
          colorScheme: lightColorScheme,
          textTheme: GoogleFonts.libreBaskervilleTextTheme(),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: RouteConfiguration.onGenerateRoute,
      );
}
