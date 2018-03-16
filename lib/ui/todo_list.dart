import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_todo/model/todo.dart';
import 'package:flutter_todo/ui/new_todo.dart';
import 'package:flutter_todo/util/date_util.dart';
import 'package:flutter_todo/util/todoProvider.dart';

class TodoList extends StatefulWidget {

  @override
  TodoListState createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  List<Todo> _todoList = [];
  TodoProvider _todoProvider;
  final GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();

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
    await _todoProvider.getAllTodo().then((todoList) {
      setState(() {
        if(todoList!=null)
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
        child: const Icon(Icons.add), onPressed: () {
          openNewTodo();
    });
  }

  openNewTodo() async {
     await Navigator.of(context).pushNamed(NewTodo.ROUTE_NAME);
      getTodoList();
  }

  Widget _createListItem(Todo todo) {
    return new Dismissible(key: new Key(todo.id.toString()),
    onDismissed: (dismissDirection){
       _dismissListItem(todo);
    },
    child: new Card(
      child: new InkWell(
        onTap: () {_openEditTodo(todo);},
        child: new Padding(
            padding: const EdgeInsets.fromLTRB(4.0, 12.0, 4.0, 12.0),
            child: _createListItemContent(todo)),
      ),
    ));
  }

  _dismissListItem(Todo todo) async {
    await _todoProvider.delete(todo.id);
    _showSnackbar(todo);
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
        });
        _todoProvider.update(todo);
      },
    );
  }

  Widget _createListItemRightContent(Todo todo) {
    return new Expanded(child: new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Text(
          DateUtil.getFormattedDate(todo.date),
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
    ));
  }

  _showSnackbar(Todo todo){
    key.currentState.hideCurrentSnackBar();
    key.currentState.showSnackBar(
      new SnackBar(
        duration: new Duration(seconds: 20),
        content: new Text('${todo.note} is deleted'),
        action: new SnackBarAction(
          label: 'UNDO',
          onPressed: () {
              _undoTodo(todo);
            },
        ),
      ),
    );
  }

  _openEditTodo(Todo todo){
    Navigator.of(context).push(new MaterialPageRoute(builder: (buildContext){
      return new NewTodo(todo: todo);
    }));
  }

  _undoTodo(Todo todo) async {
    await _todoProvider.insert(todo);
    getTodoList();
    key.currentState.hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: key,
      appBar: _createAppBar(),
      body: _createListView(),
      floatingActionButton: _createFloatingActionButton(),
    );
  }
}
