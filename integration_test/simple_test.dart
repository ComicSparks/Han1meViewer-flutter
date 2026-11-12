import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hvf/src/rust/api/app.dart' as rapi;
import 'package:hvf/src/rust/api/hanime.dart' as hanime;
import 'package:hvf/src/rust/frb_generated.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await RustLib.init();
    final dir = await Directory.systemTemp.createTemp('hvf_test');
    await rapi.init(root: dir.path);
  });

  test('parse video code', () {
    expect(hanime.parseVideoCode(text: 'https://hanime1.me/watch?v=12345'), '12345');
  });
}
