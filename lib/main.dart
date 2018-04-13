import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_todo/ui/todo_list.dart';
import 'package:sentry/sentry.dart';

final SentryClient sentry = new SentryClient(dsn: 'https://1180c9dd4e564620882fd3c926dc9a54:a229087c7ddf49aea473ac6d9d4573da@sentry.io/1188005');

void main() {

  FlutterError.onError = (errorDetails) async {
    // errors caught by framework
    await sentry.captureException(
      exception: errorDetails.exception,
      stackTrace: errorDetails.stack,
    );
  };

  runApp(runZoned((){
    return new MyApp();
  },onError: (error,stackTrace) async {
    // errors caught outside the framework
    await sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  }));
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
      ),
      home: new TodoList(),
      /*routes: <String, WidgetBuilder>{
        NewTodo.ROUTE_NAME: (context) => new NewTodo(todo: new Todo())
      },*/
    );
  }
}
