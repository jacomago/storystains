import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storystains/common/constant/app_theme.dart';
import 'package:storystains/common/utils/services.dart';
import 'package:storystains/routes/routes.dart';

import 'common/constant/app_config.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/auth_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Services.setup();
  runApp(ChangeNotifierProvider(
    create: (_) => AuthState(AuthService()),
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConfig.appTitle,
      theme: ThemeData(colorScheme: lightColorScheme),
      onGenerateRoute: routes,
    );
  }
}
