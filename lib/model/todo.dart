class Todo {
  static String get tableName => 'todo';

  static String get columnId => 'id';
  static String get columnNote => 'note';
  static String get columnDone => 'done';
  static String get columnDate => 'date';

  int id;
  String note;
  String date;
  bool done;

  Todo({this.note, this.done = false, this.date});

  Map toMap() {
    Map map = {
      columnNote: note,
      columnDone: done == true ? 1 : 0,
      columnDate: date
    };
    return map;
  }

  Todo.fromMap(Map map) {
    id = map[columnId];
    note = map[columnNote];
    done = map[columnDone] == 1;
    date = map[columnDate];
  }
}
