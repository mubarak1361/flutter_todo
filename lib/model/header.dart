import 'package:flutter_todo/model/item.dart';
import 'package:flutter_todo/model/view_type.dart';

class Header implements Item {
  final String date;
  Header({this.date});

  @override
  ViewType getViewType() {
    return ViewType.HEADER;
  }
}
