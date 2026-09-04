import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager/window_manager.dart';

class _RecordingListener with WindowListener {
  final List<String> events = <String>[];

  @override
  void onWindowEvent(String eventName) => events.add('event:$eventName');

  @override
  void onWindowShouldTerminate() => events.add('shouldTerminate');

  @override
  void onWindowActivate() => events.add('activate');
}

void main() {
  const MethodChannel channel = MethodChannel('window_manager');
  const StandardMethodCodec codec = StandardMethodCodec();

  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> calls;

  Future<void> emitEvent(String eventName) {
    return TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
      channel.name,
      codec.encodeMethodCall(
        MethodCall('onEvent', <String, dynamic>{'eventName': eventName}),
      ),
      (_) {},
    );
  }

  setUp(() {
    calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        calls.add(methodCall);
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      null,
    );
  });

  test('setWindowCornerPreference passes the requested rounding', () async {
    await windowManager.setWindowCornerPreference(round: true);
    await windowManager.setWindowCornerPreference(round: false);

    expect(
      calls.map((call) => call.method),
      everyElement('setWindowCornerPreference'),
    );
    expect(
      calls.map((call) => (call.arguments as Map)['round']),
      <bool>[true, false],
    );
  });

  test('the terminate event reaches a listener', () async {
    final listener = _RecordingListener();
    windowManager.addListener(listener);
    addTearDown(() => windowManager.removeListener(listener));

    await emitEvent(kWindowEventShouldTerminate);

    expect(listener.events, <String>[
      'event:$kWindowEventShouldTerminate',
      'shouldTerminate',
    ]);
  });

  test('the activate event reaches a listener', () async {
    final listener = _RecordingListener();
    windowManager.addListener(listener);
    addTearDown(() => windowManager.removeListener(listener));

    await emitEvent(kWindowEventActivate);

    expect(listener.events, <String>[
      'event:$kWindowEventActivate',
      'activate',
    ]);
  });

  test('isPositionSupported queries the platform capability', () async {
    expect(await windowManager.isPositionSupported(), isFalse);

    expect(calls.map((call) => call.method), <String>['isPositionSupported']);
  });
}
