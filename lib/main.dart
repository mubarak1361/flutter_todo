import 'package:flutter/material.dart';
import 'package:flutter_todo/ui/todo_list.dart';

void main() => runApp(new MyApp());

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
