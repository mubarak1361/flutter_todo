import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_todo/db/category_provider.dart';
import 'package:flutter_todo/db/todo_provider.dart';
import 'package:flutter_todo/model/category.dart';
import 'package:flutter_todo/model/header.dart';
import 'package:flutter_todo/model/item.dart';
import 'package:flutter_todo/model/todo.dart';
import 'package:flutter_todo/model/view_type.dart';
import 'package:flutter_todo/ui/new_todo.dart';
import 'package:intl/intl.dart';

class TodoList extends StatefulWidget {
  @override
  TodoListState createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  final DateFormat formatter = new DateFormat.yMMMMd("en_US");
  List<Item> _todoList = [];
  TodoProvider _todoProvider;
  CategoryProvider _categoryProvider;
  bool _isToClose = false;
  final GlobalKey<ScaffoldState> key = new GlobalKey<ScaffoldState>();
  bool _isSearchBarViewOpen = false;
  List<Category> _categoryList = [];
  Category _category;
  bool _initalState = true;

  @override
  void initState() {
    super.initState();
    _todoProvider = new TodoProvider();
    _categoryProvider = new CategoryProvider();
    _getCategoryList().whenComplete(() => _getCategoryTodo());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _getCategoryList() async {
    return _categoryProvider.getAllCategory().then((categories) {
      categories.insert(0, new Category(id: -1, name: Category.allLists));
      categories.insert(
          categories.length, new Category(id: -2, name: Category.finished));
      setState(() => _categoryList = categories);
    });
  }

  Widget _createAppBar() {
    return new AppBar(
      leading: const Icon(Icons.beenhere),
      title: _categoryList.isNotEmpty
          ? _createCategoryDropDownList(_categoryList)
          : new Container(), //const Text('To Do List'),
      actions: <Widget>[
        new IconButton(
            icon: new Icon(Icons.search),
            onPressed: () {
              setState(() => _isSearchBarViewOpen = true);
            })
      ],
    );
  }

  Widget _createListView() {
    return new Scrollbar(
      child: new ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return _createItemByViewType(_todoList[index]);
        },
        itemCount: _todoList.length,
        padding: const EdgeInsets.only(bottom: 8.0, right: 4.0, left: 4.0),
      ),
    );
  }

  Widget _createItemByViewType(Item item) {
    switch (item.getViewType()) {
      case ViewType.HEADER:
        return new Container(
          padding: new EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 16.0),
          child: new Text((item as Header).date),
        );
      case ViewType.TODO:
        return _createListItem(item);

      default:
        return null;
    }
  }

  Widget _createFloatingActionButton() {
    return new FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _openNewTodo();
        });
  }

  Future _openNewTodo() async {
    //await Navigator.of(context).pushNamed(NewTodo.ROUTE_NAME);
    Todo todo = new Todo();
    await Navigator
        .of(context)
        .push(new CupertinoPageRoute(builder: (buildContext) {
      return new NewTodo(todo: todo);
    }));
    _getCategoryTodo();
  }

  Widget _createListItem(Todo todo) {
    return new Dismissible(
        direction: DismissDirection.endToStart,
        key: new Key(todo.id.toString()),
        onDismissed: (dismissDirection) {
          _dismissListItem(todo);
        },
        child: new Card(
          child: new InkWell(
            onTap: () {
              _openEditTodo(todo);
            },
            child: new Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 14.0, 8.0),
                child: _createListItemContent(todo)),
          ),
        ));
  }

  _dismissListItem(Todo todo) async {
    await _todoProvider.delete(todo.id);
    _todoList.remove(todo);
    _getCategoryTodo();
    _showSnackbar(todo);
  }

  void _getCategoryTodo() {
    _filterByCategory(_category?.id ?? -1).then((list) {
      setState(() {
        this._todoList = _getSortedTodoList(list);
      });
    });
  }

  Widget _createListItemContent(Todo todo) {
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        setState(() => todo.done = change);
        _todoProvider.update(todo);
      },
    );
  }

  Widget _createListItemRightContent(Todo todo) {
    return new Expanded(
        child: new Text(
      todo.note,
      style: new TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          decoration:
              todo.done ? TextDecoration.lineThrough : TextDecoration.none),
    ));
  }

  _showSnackbar(Todo todo) {
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

  _openEditTodo(Todo todo) async {
    await Navigator
        .of(context)
        .push(new CupertinoPageRoute(builder: (buildContext) {
      return new NewTodo(todo: todo);
    }));
    _getCategoryTodo();
  }

  _undoTodo(Todo todo) async {
    await _todoProvider.insert(todo);
    _getCategoryTodo();
    key.currentState.hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: new Scaffold(
          key: key,
          //appBar: _createAppBar(),
          body: _createBody(),
          floatingActionButton: _createFloatingActionButton(),
        ),
        onWillPop: _showSnackbarOnClose);
  }

  Widget _createBody() {
    return new Column(
      children: <Widget>[
        _isSearchBarViewOpen ? _createStatusBar() : new Container(),
        _isSearchBarViewOpen ? _createSearchBar() : _createAppBar(),
        new Expanded(
            child:
                _todoList.isNotEmpty ? _createListView() : _buildNoTodoView())
      ],
    );
  }

  Center _buildNoTodoView() {
    return new Center(
      child: new Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _initalState ? _buildLoader() : _buildNoToDoViewItem()),
    );
  }

  List<Widget> _buildLoader() {
    _initalState = false;
    return <Widget>[new CircularProgressIndicator()];
  }

  List<Widget> _buildNoToDoViewItem() {
    return <Widget>[
      new Icon(Icons.list, size: 80.0, color: Colors.grey.withOpacity(0.4)),
      new Text('No To Do',
          style: new TextStyle(
              color: Colors.grey.withOpacity(0.7), fontSize: 16.0))
    ];
  }

  Widget _createStatusBar() {
    return new Container(
        color: Theme.of(context).primaryColor,
        width: MediaQuery.of(context).size.width,
        height: 24.0);
  }

  Widget _createSearchBar() {
    return new Material(
      color: Theme.of(context).primaryColor,
      elevation: 20.0,
      shadowColor: Colors.grey.shade900,
      child: new Container(
          padding: new EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
          width: MediaQuery.of(context).size.width,
          height: 56.0,
          child: _createSearchView()),
    );
  }

  Widget _createSearchView() {
    return new Card(
      elevation: 3.0,
      child: new Row(
        children: <Widget>[
          new Expanded(
              flex: 9,
              child: new TextField(
                  maxLines: 1,
                  onChanged: (value) {
                    _searchTodo(value).then((todoList) {
                      setState(() => this._todoList = todoList);
                    });
                  },
                  decoration: const InputDecoration(
                    fillColor: Colors.transparent,
                    contentPadding:
                        const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search',
                  ))),
          new Expanded(
            flex: 1,
            child: new IconButton(
              icon: new Icon(
                Icons.close,
                color: Colors.grey.withOpacity(0.8),
              ),
              onPressed: () {
                setState(() {
                  _isSearchBarViewOpen = false;
                  _searchTodo('').then((todoList) {
                    setState(() => this._todoList = todoList);
                  });
                });
              },
              padding: new EdgeInsets.only(left: 4.0, right: 8.0),
            ),
          )
        ],
      ),
    );
  }

  Widget _createCategoryDropDownList(List<Category> categories) {
    return new Theme(
        data: Theme.of(context).copyWith(
              canvasColor: Theme.of(context).primaryColor,
            ),
        child: new DropdownButtonHideUnderline(
            child: new DropdownButton(
                value:
                    _category ?? (categories.length > 0 ? categories[0] : null),
                items: _createCatergoryDropDownMenuItems(categories),
                isDense: true,
                onChanged: (value) {
                  _filterByCategory(value.id).then((list) {
                    setState(() {
                      _category = value;
                      _todoList = _getSortedTodoList(list);
                    });
                  });
                })));
  }

  List<DropdownMenuItem<Category>> _createCatergoryDropDownMenuItems(
      List<Category> categories) {
    List<DropdownMenuItem<Category>> menuItems = categories.map((category) {
      return new DropdownMenuItem(
          value: category,
          child: new Row(
            children: <Widget>[
              new Icon(category.getIcon(), color: Colors.white, size: 14.0),
              new Padding(
                  padding: new EdgeInsets.only(left: 6.0),
                  child: new Text(category.name,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 18.0)))
            ],
          ));
    }).toList();
    return menuItems;
  }

  Future<bool> _showSnackbarOnClose() async {
    key.currentState.hideCurrentSnackBar();
    if (_isToClose) {
      SystemNavigator.pop();
    }
    key.currentState.showSnackBar(
      new SnackBar(
        duration: new Duration(seconds: 2),
        content: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Icon(Icons.exit_to_app),
            new Text('Press back again to exit')
          ],
        ),
      ),
    );
    new Future.delayed(new Duration(seconds: 2), () {
      _isToClose = false;
    });
    _isToClose = true;
    return false;
  }

  Future<List<Item>> _searchTodo(String value) async {
    return _filterByCategory(_category?.id ?? -1).then((todoList) {
      if (value.isNotEmpty) {
        return _getSortedTodoList(todoList
            ?.where(
                (todo) => todo.note.toLowerCase().contains(value.toLowerCase()))
            ?.toList());
      } else {
        return _getSortedTodoList(todoList);
      }
    });
  }

  Future<List<Todo>> _filterByCategory(int categoryId) async {
    return _todoProvider.getAllTodo().then((todoList) {
      switch (categoryId) {
        case -1:
          return todoList;
        case -2:
          return todoList?.where((todo) => todo.done)?.toList();
        default:
          return todoList
              ?.where((todo) => todo.categoryId == categoryId)
              ?.toList();
      }
    });
  }

  List<String> _getDateList(List<Todo> todoList) {
    List<String> dates = todoList?.map((todo) => todo.date)?.toSet()?.toList();
    dates?.sort((date1, date2) {
      return formatter.parse(date1).isAfter(formatter.parse(date2)) ? 1 : 0;
    });
    return dates;
  }

  List<Item> _getSortedTodoList(List<Todo> todoList) {
    List<Item> items = [];
    List<String> dateList = _getDateList(todoList);
    dateList?.forEach((date) {
      items.add(new Header(date: date));
      items.addAll(todoList?.where((todo) => todo.date == date)?.toList());
    });
    return items;
  }
}
