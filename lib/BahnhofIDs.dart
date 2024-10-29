import 'dart:io';

Map<String, int> bahnhoefe = {
  "Berlin Hbf": 8011160,
  "München Hbf": 8000261,
  "Frankfurt (Main) Hbf": 8000105,
  "Hamburg Hbf": 8002549,
  "Köln Hbf": 8000207,
};

// Funktion, die die ID des Bahnhofs anhand des Namens sucht
String findeBahnhofId(String bahnhofName) {
  String name = bahnhofName.trim();

  if (bahnhoefe.containsKey(name)) {
    return "Die ID für $name ist: ${bahnhoefe[name]}";
  } else {
    return "Bahnhof '$name' nicht gefunden.";
  }
}

