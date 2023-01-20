import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:coba_lagi/app.dart';
import 'package:coba_lagi/bridge_generated.dart';
import 'package:coba_lagi/perangkat_tersimpan.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart' hide Size;
import 'ffi.io.dart' show api;

Future<void> main() async {
  await App.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool bluetoothAdapterState = false;
  List<BluetoothDevice> devices = [];
  bool isLoading = false;
  late StreamSubscription<BluetoothDevice> stream;
  @override
  void initState() {
    api.init();
    if (!mounted) {
      return;
    }

    super.initState();
  }

  @override
  void dispose() {
    api.dispose();
    stream.cancel();
    super.dispose();
  }

  Future<void> discoverServiceStream() async {
    try {
      setState(() {
        devices.clear();
      });
      stream = api.discoverDeviceStream().listen((event) {
        if (!devices.any((element) => element.address == event.address)) {
          setState(() {
            devices.add(BluetoothDevice(
              status: event.status,
              serviceUuid: event.serviceUuid,
              name: event.name,
              address: event.address,
            ));
          });
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        e.toString(),
      )));
    }
  }

  Future<List<int>> testTicket() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    bytes += generator.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    bytes += generator.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
        styles: const PosStyles(codeTable: 'CP1252'));
    bytes += generator.text('Special 2: blåbærgrød',
        styles: const PosStyles(codeTable: 'CP1252'));

    bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
    bytes +=
        generator.text('Reverse text', styles: const PosStyles(reverse: true));
    bytes += generator.text('Underlined text',
        styles: const PosStyles(underline: true), linesAfter: 1);
    bytes += generator.text('Align left',
        styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('Align center',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Align right',
        styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

    bytes += generator.row([
      PosColumn(
        text: 'col3',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col6',
        width: 6,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
      PosColumn(
        text: 'col3',
        width: 3,
        styles: const PosStyles(align: PosAlign.center, underline: true),
      ),
    ]);

    bytes += generator.text('Text size 200%',
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    // Print barcode
    final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
    bytes += generator.barcode(Barcode.upcA(barData));

    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }

  Future<void> saveIntoPreference(BluetoothDevice data) async {
    Map<String, dynamic> savedData = {
      'name': data.name,
      'address': data.address,
      'status': data.status,
      'service_uuid': data.serviceUuid,
    };
    await App.sharedPreferences.setString('device', jsonEncode(savedData));
    final result = App.sharedPreferences.getString('device');
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const PerangkatTersimpan();
              }));
            },
            child: const Text("Lihat Perangkat Tersimpan"),
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      final result = await api.connectToDevice(
                        serviceUuid: devices[index].serviceUuid.first,
                      );

                      if (result) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Connected to device ${devices[index].name ?? 'unknown'}")));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Error can't connect to device,")));
                      }
                    },
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                'Device Name : ${devices[index].name ?? 'Unknown'}'),
                            Text('Address : ${devices[index].address ?? '-'} '),
                            Text('Connectable : ${devices[index].status}'),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      final ticket = await testTicket();
                                      await api.startPrinter(
                                        serviceUuid:
                                            devices[index].serviceUuid.first,
                                        data: Uint8List.fromList(ticket),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                        e.toString(),
                                      )));
                                    }
                                  },
                                  child: const Text("Print"),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed: () async {
                                    await saveIntoPreference(devices[index]);
                                  },
                                  child: const Text("Save To Pref"),
                                ),
                                const SizedBox(width: 5),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await api.connectToDevice(
                                        serviceUuid:
                                            devices[index].serviceUuid.first,
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                        "Terhubung ke perangkat ${devices[index].name ?? 'unknown'}",
                                      )));
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                        e.toString(),
                                      )));
                                    }
                                  },
                                  child: const Text("Test Connection"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await discoverServiceStream();
        },
        tooltip: 'Discover',
        child: const Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
