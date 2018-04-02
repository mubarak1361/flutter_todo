import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_todo/model/category.dart';
import 'package:flutter_todo/model/todo.dart';
import 'package:flutter_todo/util/category_provider.dart';
import 'package:flutter_todo/util/constants.dart';
import 'package:flutter_todo/util/todo_provider.dart';
import 'package:intl/intl.dart';

class NewTodo extends StatefulWidget {
  static final String routeName = '/new';
  final Todo todo;
  final DateFormat formatter = new DateFormat.yMMMMd("en_US");

  NewTodo({Key key, this.todo}) : super(key: key) {
    if (todo.date == null) {
      this.todo.date = formatter.format(new DateTime.now());
    }
  }

  @override
  NewTodoState createState() => new NewTodoState();
}

class NewTodoState extends State<NewTodo> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<Category> _categoryList = [];
  Category _category;

  Widget _createAppBar() {
    return new AppBar(
      title: new Text(_getTitle()),
      actions: <Widget>[_createSaveUpdateAction()],
    );
  }

  Widget _createSaveUpdateAction() {
    return new IconButton(
      onPressed: () {
        _saveTodo();
      },
      icon: const Icon(Icons.save),
    );
  }

  _saveTodo() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      TodoProvider provider = new TodoProvider();
      widget.todo.categoryId = _category.id;
      if (!_isExistRecord()) {
        await provider.insert(widget.todo);
      } else {
        await provider.update(widget.todo);
      }
      Navigator.of(context).pop();
    }
  }

  bool _isExistRecord() {
    return widget.todo.id == null ? false : true;
  }

  @override
  void initState() {
    super.initState();
    new CategoryProvider().getAllCategory().then((categories){
      setState(() {
        _category = categories.firstWhere((category)=> category.id == widget.todo.categoryId);
        _categoryList = categories;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _getTitle() {
    return _isExistRecord() ? Constants.titleEdit : Constants.titleNew;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _createAppBar(),
      body: new Padding(
          padding: new EdgeInsets.fromLTRB(12.0, 18.0, 12.0, 18.0),
          child: new Form(
            onWillPop: _warnUserWithoutSaving,
            key: _formKey,
            child: new Column(
              children: <Widget>[_createDatePicker(), _createNote(),_createCategoryDropDownList(_categoryList)],
            ),
          )),
    );
  }

  Widget _createDatePicker() {
    return new Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Icon(
          Icons.date_range,
          color: Theme.of(context).primaryColor,
        ),
        new InkWell(
          child: new Padding(
            padding: new EdgeInsets.only(
                left: 18.0, top: 8.0, bottom: 8.0, right: 18.0),
            child: new Text(
              widget.todo.date,
              style: new TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 14.0),
            ),
          ),
          onTap: _pickDateFromDatePicker,
        )
      ],
    );
  }

  Widget _createCategoryDropDownList(List<Category> categories) {
    return new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Icon(
            Icons.list,
            color: Theme
                .of(context)
                .primaryColor,
          ),
          new Padding(
              padding: new EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
              child: new DropdownButtonHideUnderline(child: new DropdownButton(
                  value: _category ??
                      (categories.length > 0 ? _category = categories[0] : null),
                  items: _createCategoryDropDownMenuItems(categories),
                  isDense: true,
                  onChanged: (value) {
                    setState(() => _category = value);
                  }),)
          )
        ]);
  }

  List<DropdownMenuItem<Category>> _createCategoryDropDownMenuItems(List<Category> categories) {
    List<DropdownMenuItem<Category>> menuItems = categories.map((category){
      return new DropdownMenuItem(value:category,
          child: new Text(category.name,
              style: new TextStyle(color: Theme.of(context).primaryColor,fontSize: 16.0)));
    }).toList();
    return menuItems;
  }

  _pickDateFromDatePicker() async {
    DateTime dateTime = widget.formatter.parse(widget.todo.date);
    DateTime dateTimePicked = await showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: isBeforeToday(dateTime) ? dateTime : new DateTime.now(),
        lastDate: dateTime.add(const Duration(days: 365)));

    if (dateTimePicked != null) {
      setState(() {
        widget.todo.date = widget.formatter.format(dateTimePicked);
      });
    }
  }

  bool isBeforeToday(DateTime date) {
    return date.isBefore(new DateTime.now());
  }

  Future<bool> _warnUserWithoutSaving() async {
    if (_isExistRecord()) {
      return true;
    } else {
      return await showDialog<bool>(
            context: context,
            child: new AlertDialog(
              title: const Text('Discard To do'),
              content:
                  const Text('Do you want close without saving to do note?'),
              actions: <Widget>[
                new FlatButton(
                  child: const Text('YES'),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                new FlatButton(
                  child: const Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            ),
          ) ??
          false;
    }
  }

  Widget _createNote() {
    return new TextFormField(
      textAlign: TextAlign.justify,
      maxLines: 3,
      decoration: const InputDecoration(
        contentPadding: const EdgeInsets.all(4.0),
        icon: const Icon(Icons.note),
        hintText: 'Note',
        labelText: 'What would you like to do ?',
      ),
      initialValue: widget.todo.note ?? '',
      keyboardType: TextInputType.text,
      validator: _validateNote,
      onSaved: _noteOnSave,
    );
  }

  String _validateNote(String value) {
    return value.isEmpty ? 'Note is required' : null;
  }

  void _noteOnSave(String value) {
    widget.todo.note = value;
  }
}
