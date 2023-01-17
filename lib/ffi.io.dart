import 'dart:io';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';

import 'bridge_generated.dart';

const base = 'rust';
final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
final dylib = loadDylib(path);
final api = RustImpl(dylib);
