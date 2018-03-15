import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_todo/model/todo.dart';
import 'package:flutter_todo/util/todoProvider.dart';

class TodoList extends StatefulWidget {
  @override
  TodoListState createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  List<Todo> _todoList = [];
  TodoProvider _todoProvider;

  @override
  void initState() {
    super.initState();
    getTodoList();
  }

  @override
  void dispose() {
    _todoProvider.close();
    super.dispose();
  }

  Future getTodoList() async {
    _todoProvider = new TodoProvider();
    await _todoProvider.open();
    _todoProvider.getAllTodo().then((todoList) {
      setState(() {
        this._todoList = todoList;
      });
    });
  }

  Widget _createAppBar() {
    return new AppBar(
      leading: const Icon(Icons.beenhere),
      title: const Text('To Do List'),
    );
  }

  Widget _createListView() {
    return new ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _createListItem(_todoList[index]);
      },
      itemCount: _todoList.length,
      padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
    );
  }

  Widget _createFloatingActionButton() {
    return new FloatingActionButton(
        child: const Icon(Icons.add), onPressed: () {});
  }

  String _getTime(String dateTime) {
    TimeOfDay timeOfDay = new TimeOfDay.fromDateTime(DateTime.parse(dateTime));
    return '${timeOfDay.hour.toString()} : ${timeOfDay.minute.toString()} ${timeOfDay.period.toString().substring(timeOfDay.period.toString().indexOf('.')+1)}';
  }

  Widget _createListItem(Todo todo) {
    return new Card(
      child: new InkWell(
        onTap: () {},
        child: new Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 12.0, 4.0, 0.0),
            child: _createListItemContent(todo)),
      ),
    );
  }

  Widget _createListItemContent(Todo todo) {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _createListItemLeftContent(todo),
        _createListItemRightContent(todo)
      ],
    );
  }

  Widget _createListItemLeftContent(Todo todo) {
    return new Checkbox(
      value: todo.done,
      onChanged: (change) {
        setState(() {
          todo.done = change;
          _todoProvider.update(todo);
        });
      },
    );
  }

  Widget _createListItemRightContent(Todo todo) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Text(
          _getTime(todo.date),
          style: new TextStyle(color: Colors.black87, fontSize: 12.0),
        ),
        new Text(
          todo.note,
          style: new TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              decoration:
                  todo.done ? TextDecoration.lineThrough : TextDecoration.none),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _createAppBar(),
      body: _createListView(),
      floatingActionButton: _createFloatingActionButton(),
    );
  }
}
