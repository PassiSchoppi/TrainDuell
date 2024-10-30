class User {
  static final User _singleton = User._internal();

  factory User() {
    return _singleton;
  }

  User._internal();

  String name = "";
  String zug_id = "";
  String zug_display_name = "";
  String einstieg = "";
  List<dynamic> halte = [];
}