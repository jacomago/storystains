import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:storystains/app.dart';
import 'package:storystains/modules/auth/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(ChangeNotifierProvider(
    create: (_) => AuthState(AuthService()),
    child: const App(),
  ));
}