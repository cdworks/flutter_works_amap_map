import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:works_amap_map/works_amap_map.dart';

void main() {
  const MethodChannel channel = MethodChannel('works_amap_map');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await WorksAmapMap.platformVersion, '42');
  });
}
