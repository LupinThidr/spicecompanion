library platform;

import 'dart:io' show Platform, File, Directory;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:desktop_window/desktop_window.dart';

Future<String> _preferencesPathGet() async {
  String filename = "spicecompanion.json";
  if (Platform.isWindows)
    return Path.join(Platform.environment["APPDATA"], filename);
  if (Platform.isLinux || Platform.isMacOS) {
    var configPath = Path.join(Platform.environment["HOME"], ".config");
    Directory configDir = Directory(configPath);
    if (!(await configDir.exists()))
      configDir.create();
    return Path.join(configPath, filename);
  }
  throw UnsupportedError("Unsupported platform for preferences file.");
}

Future<String> _preferencesFileRead() async {
  return File(await _preferencesPathGet()).readAsString();
}

Future<void> _preferencesFileWrite(String content) async {
  return File(await _preferencesPathGet()).writeAsString(content);
}

Map _preferencesMapCache;

Future<Map> _preferencesMapGet() async {

  // check cache first
  if (_preferencesMapCache != null)
    return _preferencesMapCache;

  // load from file
  try {
    var json = await _preferencesFileRead();
    return jsonDecode(json);
  } on Exception {
    _preferencesFileWrite(jsonEncode({}));
    return {};
  }
}

Future<void> _preferencesMapSet(Map map) {
  _preferencesMapCache = map;
  return _preferencesFileWrite(jsonEncode(map));
}

Future<void> preferencesSetString(String key, String value) async {
  if (Platform.isAndroid || Platform.isIOS) {
    return SharedPreferences.getInstance().then((prefs) {
      prefs.setString(key, value);
    });
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    var map = await _preferencesMapGet();
    map[key] = value;
    await _preferencesMapSet(map);
  }
}

Future<void> preferencesSetStringList(String key, List<String> values) async {
  if (Platform.isAndroid || Platform.isIOS) {
    return SharedPreferences.getInstance().then((prefs) {
      prefs.setStringList(key, values);
    });
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    var map = await _preferencesMapGet();
    map[key] = values;
    await _preferencesMapSet(map);
  }
}

Future<String> preferencesGetString(String key) async {
  if (Platform.isAndroid || Platform.isIOS) {
    return SharedPreferences.getInstance().then((prefs) {
      return prefs.getString(key);
    });
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    var map = await _preferencesMapGet();
    var val = map[key];
    if (val is String)
      return val;
    return null;
  }
  return null;
}

Future<List> preferencesGetStringList(String key) async {
  if (Platform.isAndroid || Platform.isIOS) {
    return SharedPreferences.getInstance().then((prefs) {
      return prefs.getStringList(key);
    });
  }
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    var map = await _preferencesMapGet();
    var val = map[key];
    if (val is List)
      return val;
    return null;
  }
  return null;
}

bool isFullScreen = false;

void fullscreenToggle() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {

    // window fullscreen toggle
    isFullScreen = !isFullScreen;
    await DesktopWindow.setFullScreen(isFullScreen);

  } else {

    // navigation / title bar toggle
    if (!isFullScreen) {
      SystemChrome.setEnabledSystemUIOverlays([]);
      isFullScreen = true;
    } else {
      SystemChrome.setEnabledSystemUIOverlays([
        SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ]);
      isFullScreen = false;
    }
  }
}
