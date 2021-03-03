import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:ultimate_task_by_studio/landing_page.dart';
import 'package:ultimate_task_by_studio/mobx/amount.dart';
import 'package:ultimate_task_by_studio/screens/tasks/color_bloc.dart';
import 'package:ultimate_task_by_studio/service/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthBase>.value(value: Auth()),
        Provider<ColorCircleBloc>.value(value: ColorCircleBloc()),
        Provider<Amount>.value(value: Amount()),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate
        ],
        supportedLocales: [
          const Locale('ru'),
        ],
        debugShowCheckedModeBanner: false,
        title: 'Ultimate Task',
        home: LandingPage(),
      ),
    );
  }
}
