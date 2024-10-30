import 'package:flutter/material.dart';
import 'Zugsuchen.dart';
import 'chat.dart';
import 'global.dart';
import 'BahnhofIDs.dart';
import 'strecke.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrainDuel',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromRGBO(236, 0, 22, 2)),
        useMaterial3: true,
      ),
      home: const MyHomePage(
          title: 'TrainDuell'), // MyHomePage(title: 'TrainDuell'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  List<List<dynamic>> _searchResults = [];
  String? _selectedId;
  TimeOfDay _selectedTime = TimeOfDay.now(); // Uhrzeit Placeholder
  dynamic Infos_Station;
  User user = User();

  // Funktion zur Auswahl der Uhrzeit
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
    print(_selectedTime.hour.toString());
  }

  void _onSearchChanged() {
    print("searching...");
    if (_controller.text.length > 2) {
      getIds(_controller.text).then((results) {
        setState(() {
          _searchResults = results;
        });
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _onSelectItem(List<dynamic> selectedItem) {
    // Extracting the ID from the selected item string
    final id = selectedItem[1].toString();
    final name = selectedItem[0].toString();
    setState(() {
      _selectedId = id; // Save the ID to a variable
      _searchResults = []; // Clear search results after selection
      // _controller.clear(); // Optionally clear the input field
      _controller.text = name;
      user.zug_id = id; // TODO Nur zum Testen
    });
    print("Selected ID: $_selectedId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Text('Dein Name:', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Name',
                        ),
                        onChanged: (value) {
                          setState(() {
                            user.name = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Eingestiegen in: Gera
                Row(
                  children: [
                    const Text('Eingestiegen in:',
                        style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Bahnhof',
                        ),
                        onChanged: (value) {
                          _onSearchChanged();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_searchResults.isNotEmpty)
                  const Text('Wähle einen Bahnhof aus:'),
                if (_searchResults.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(
                      // Dynamically set the height to fit content or max out at 200.0
                      maxHeight: _searchResults.length *
                          56.0, // Each ListTile typically has a height of ~56.0
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(), // Prevent scrolling to allow dropdown to adjust its height
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_searchResults[index][
                              0]), // Display the first element (name) of the tuple
                          onTap: () => _onSelectItem(
                              _searchResults[index]), // Handle selection
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                // Uhrzeit Auswahl Button
                Row(
                  children: [
                    const Text('Uhrzeit:', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _selectTime(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text(
                          '${_selectedTime.format(context)}',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // "Zug Suchen" Button
                ElevatedButton(
                  onPressed: () {
                    ApiService()
                        .callLambdaFunction(
                            _selectedId.toString(), _selectedTime.hour)
                        .then((result) {
                      setState(() {
                        print('result:');
                        Infos_Station = result;
                        print(Infos_Station);
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  child: const Text('Zug Suchen'),
                ),
                const SizedBox(height: 20),
                // Platzhalter für weitere Informationen
                if (Infos_Station != null)
                  Column(
                    children:
                        Infos_Station.asMap().entries.map<Widget>((entry) {
                      print('Infos_Station:');
                      print(Infos_Station);
                      var endHalt = '';
                      if (entry.value['kommende_halte'] ==
                          'Der Zug endet hier.') {
                        return const SizedBox(height: 0);
                      } else {
                        endHalt = entry.value['kommende_halte'].last;
                      }
                      var alleHalte = [];
                      if(entry.value['vergangene_halte'] != 'Der Zug startet hier.') {
                        alleHalte =
                            new List.from(entry.value['vergangene_halte'])
                              ..addAll([entry.value['abfahrt_von']])
                              ..addAll(entry.value['kommende_halte']);
                      }else{
                        alleHalte = new List.from([entry.value['abfahrt_von']])
                          ..addAll(entry.value['kommende_halte']);
                      }
                      return Container(
                          padding: EdgeInsets.all(16.0), // Optional: adds padding inside the container
                        margin: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[800] // Darker gray for dark mode
                                : Colors.grey[300], // Lighter gray for light mode
                            borderRadius: BorderRadius.circular(12.0), // Rounds the corners
                          ),
                          child: Row(children: [
                            Expanded(
                              child: Text('${entry.value['zug'].toString()} nach $endHalt', style: TextStyle(fontSize: 25),
                            ),
                            ),
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                user.zug_id = entry.value['zug_id'].toString();
                                user.halte = alleHalte;
                                user.zug_display_name = '${entry.value['zug'].toString()} nach $endHalt';
                                user.einstieg = entry.value['abfahrt_von'];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Strecke()),
                                );
                              });
                            },
                            child: const Icon(Icons.send))
                      ]),);
                    }).toList(),

                  ),
              ],
            ),
          ),
        ));
  }
}
