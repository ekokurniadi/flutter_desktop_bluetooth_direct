// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:coba_lagi/app.dart';
import 'package:coba_lagi/bridge_generated.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:image/image.dart' as i;
import 'ffi.io.dart';

class PerangkatTersimpan extends StatefulWidget {
  const PerangkatTersimpan({Key? key}) : super(key: key);

  @override
  State<PerangkatTersimpan> createState() => _PerangkatTersimpanState();
}

class _PerangkatTersimpanState extends State<PerangkatTersimpan> {
  BluetoothDevice? bluetoothDevice;
  bool isEmptyDevice = false;

  @override
  void initState() {
    getDataPerangkat();
    super.initState();
  }

  Future<void> getDataPerangkat() async {
    final result = App.sharedPreferences.getString('device');
    if (result == null) {
      setState(() {
        isEmptyDevice = true;
      });
      return;
    } else {
      setState(() {
        isEmptyDevice = false;
      });
      final decodeResult = jsonDecode(result!);
      bluetoothDevice = BluetoothDevice(
        name: decodeResult['name'],
        address: decodeResult['address'],
        serviceUuid: List<String>.from(decodeResult['service_uuid']),
        status: decodeResult['status'],
      );
    }
  }

  Future<List<int>> testTicket() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];
    final imgPath = await rootBundle.load('assets/logo.png');
    final img = imgPath.buffer.asUint8List();
    i.Image im = i.decodeImage(img)!;
    bytes += generator.imageRaster(im);
    bytes += generator.feed(1);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Perangkat Tersimpan"),
      ),
      body: isEmptyDevice ? Center(
        child:Text("Perangkat masih Kosong")
      ): Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Device Name : ${bluetoothDevice?.name ?? 'Unknown'}'),
                Text('Address : ${bluetoothDevice!.address ?? '-'} '),
                Text('Connectable : ${bluetoothDevice!.status}'),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final isConnect = await api.connectToDevice(
                          serviceUuid: bluetoothDevice!.serviceUuid.first,
                        );
                        if (isConnect) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Terhubung ke Perangkat ${bluetoothDevice!.name}")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Tidak dapat Terhubung ke Perangkat ${bluetoothDevice!.name}")));
                        }
                      },
                      child: const Text("Connect"),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: () async {
                        final ticket = await testTicket();
                        final printed = await api.startPrinter(
                          serviceUuid: bluetoothDevice!.serviceUuid.first,
                          data: Uint8List.fromList(ticket),
                        );

                        if (printed) {
                          print("$printed berhasil print");
                        }
                      },
                      child: const Text("Print"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
