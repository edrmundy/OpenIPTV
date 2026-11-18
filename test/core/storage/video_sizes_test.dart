import 'package:flutter_test/flutter_test.dart';
import 'package:open_iptv/core/storage/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = AppPreferences(await SharedPreferences.getInstance());
  });

  test('nothing is stored at first', () {
    expect(prefs.videoSizes, isEmpty);
  });

  test('a size is stored by item id and a newer one replaces it', () async {
    await prefs.setVideoSize('m1', 1920, 1080);
    expect(prefs.videoSizes['m1'], '1920x1080');
    await prefs.setVideoSize('m1', 3840, 2160);
    expect(prefs.videoSizes['m1'], '3840x2160');
  });

  test('a missing size or id is ignored', () async {
    await prefs.setVideoSize('m1', 0, 1080);
    await prefs.setVideoSize('m1', 1920, 0);
    await prefs.setVideoSize('', 1920, 1080);
    expect(prefs.videoSizes, isEmpty);
  });

  test('only the newest 200 items are kept', () async {
    for (var i = 0; i < 205; i++) {
      await prefs.setVideoSize('m$i', 1280, 720);
    }
    expect(prefs.videoSizes.length, 200);
    expect(prefs.videoSizes.containsKey('m0'), isFalse);
    expect(prefs.videoSizes.containsKey('m204'), isTrue);
  });

  test('damaged stored data reads as nothing', () async {
    SharedPreferences.setMockInitialValues({'edtv_video_sizes': 'not json'});
    final damaged = AppPreferences(await SharedPreferences.getInstance());
    expect(damaged.videoSizes, isEmpty);
  });
}
