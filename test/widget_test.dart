// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester utility that Flutter
// provides. For example, you can send tap and scroll gestures. You can also use WidgetTester to
// find child widgets in the widget tree, read text, and verify that the values of widget properties
// are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/db/todo_provider.dart';
import 'package:flutter_todo/model/todo.dart';

void main() {
  testWidgets('Todo insert smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    TodoProvider provider = new TodoProvider();
    Todo todo = new Todo(note: 'buy fruits',date: new DateTime.now().toIso8601String());
    todo = await provider.insert(todo);
    print(todo.id);
  });
}
