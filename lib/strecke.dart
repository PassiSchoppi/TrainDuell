import 'dart:ffi' as ffi; // Alias for the FFI library
import 'dart:ui'; // Import UI without alias
import 'package:flutter/material.dart';
import 'chat.dart';
import 'global.dart';

class Strecke extends StatefulWidget {
  const Strecke();

  @override
  _StreckeState createState() => _StreckeState();
}

class _StreckeState extends State<Strecke> {
  User user = User();

  void selectExit() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Chat()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stations = [
      {"id": 1, "time": "08:00", "station": "Station A"},
      {"id": 2, "time": "08:15", "station": "Station B"},
      {"id": 3, "time": "08:30", "station": "Station C mit einem langen Namen"},
      {"id": 4, "time": "08:45", "station": "München Hbf"},
      {"id": 1, "time": "08:00", "station": "Station A"},
      {"id": 2, "time": "08:15", "station": "Station B"},
      {"id": 3, "time": "08:30", "station": "Station C mit einem langen Namen"},
      {"id": 4, "time": "08:45", "station": "München Hbf"},
      {"id": 1, "time": "08:00", "station": "Station A"},
      {"id": 2, "time": "08:15", "station": "Station B"},
      {"id": 3, "time": "08:30", "station": "Station C mit einem langen Namen"},
      {"id": 4, "time": "08:45", "station": "München Hbf"},
      {"id": 1, "time": "08:00", "station": "Station A"},
      {"id": 2, "time": "08:15", "station": "Station B"},
      {"id": 3, "time": "08:30", "station": "Station C mit einem langen Namen"},
      {"id": 4, "time": "08:45", "station": "München Hbf"},
      {"id": 1, "time": "08:00", "station": "Station A"},
      {"id": 2, "time": "08:15", "station": "Station B"},
      {"id": 3, "time": "08:30", "station": "Station C mit einem langen Namen"},
      {"id": 4, "time": "08:45", "station": "München Hbf"},
      {"id": 1, "time": "08:00", "station": "Station A"},
      {"id": 2, "time": "08:15", "station": "Station B"},
      {"id": 3, "time": "08:30", "station": "Station C mit einem langen Namen"},
      {"id": 4, "time": "08:45", "station": "München Hbf"},
    ];
    final int entryStationId = 2; // Example: the user enters at Station B

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Wähle einen Ausstieg'),
      ),
      body: SingleChildScrollView( child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                  'Wähle die Station bei der du austeigen willt. Wir erinnern dich kurz vor der Ankunft die App zu verlassen.',
                  style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),Column(
                children: stations.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> station = entry.value;
                  bool isAt = station['id'] == entryStationId;
                  bool isLastStation = index == stations.length - 1;
                  bool availableForExit = false;
                  for (var i = 0; i < stations.length; i++) {
                    if (i < index && stations[i]['id'] == entryStationId) {
                      availableForExit = true;
                    }
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Arrival time
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0, left: 10.0),
                        child: Text(
                          station['time']!,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),

                      // Path line with dot
                      Column(
                        children: [
                          // Draw a line above the dot for all but the first station
                          if (index > 0)
                            Container(
                              width: 5,
                              height: 20,
                              color: Colors.primaries.last,
                            ),
                          // Dot for the station
                          isLastStation
                              ? HexagonStopSign() // Custom hexagon stop sign
                              : isAt
                                  ? Transform.scale(
                                      scale:
                                          1.22, // Increase size without affecting layout
                                      child: const Icon(
                                        Icons.arrow_drop_down_circle_outlined,
                                        color: Colors.teal,
                                        size: 30,
                                      ),
                                    )
                                  : const CircleAvatar(
                                      radius: 15,
                                    ),
                          // Draw a line below the dot for all but the last station
                          if (index < stations.length - 1)
                            Container(
                              width: 5,
                              height: 20,
                              color: Colors.primaries.last,
                            ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      // Station name
                      Expanded(
                        child: Text(
                          station['station']!,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      availableForExit
                          ? ElevatedButton(
                              onPressed: () {
                                selectExit();
                              },
                              child: const Text('Mein Ausstieg'))
                          : const Text(' ')
                    ],
                  );
                }).toList(),
              )

          ]),
    )));
    }
}

// Custom hexagon stop sign widget
class HexagonStopSign extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HexagonClipper(),
      child: Container(
        width: 30,
        height: 38,
        color: Colors.red,
      ),
    );
  }
}

// Hexagon Clipper for the stop sign shape
class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final side = width / 2;

    path.moveTo(width * 0.5, 0);
    path.lineTo(width, height * 0.25);
    path.lineTo(width, height * 0.75);
    path.lineTo(width * 0.5, height);
    path.lineTo(0, height * 0.75);
    path.lineTo(0, height * 0.25);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}