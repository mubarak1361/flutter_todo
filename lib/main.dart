import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo/ui/todo_list.dart';
import 'package:sentry/sentry.dart';

Future<void> main() async {
  await Sentry.init(
      (options) => options.dsn = '',
      appRunner: () {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do List',
      theme: new ThemeData(
        primarySwatch: Colors.blueGrey,
        appBarTheme: AppBarTheme(brightness: Brightness.dark),
      ),
      home: new TodoList(),
    );
  }
}
