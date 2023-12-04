import 'package:flutter/material.dart';
import 'package:spicecompanion/views/views.dart';
import 'package:spicecompanion/util/util.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

// desktop platform workaround for flutter
void _setTargetPlatformForDesktop() {
  TargetPlatform targetPlatform;
  if (Platform.isMacOS) {
    targetPlatform = TargetPlatform.iOS;
  } else if (Platform.isLinux || Platform.isWindows) {
    targetPlatform = TargetPlatform.android;
  }
  if (targetPlatform != null) {
    debugDefaultTargetPlatformOverride = targetPlatform;
  }
}

void main() async {
  try {
    _setTargetPlatformForDesktop();
  } catch (e) {}
  WidgetsFlutterBinding.ensureInitialized();

  // load settings
  await Settings.load();

  // pre-load patches
  PatchManager.inst.importDefaults();

  // reset patch states on connection change
  ConnectionPool.inst.changes.stream.listen((pool) {
    PatchManager.inst.resetStates();
  });

  // start tag manager
  TagManager.inst.start();

  // run app
  runApp(MainView());
}
