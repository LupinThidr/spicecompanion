import 'package:flutter_web/material.dart';
import 'package:spicecompanion/views/views.dart';
import 'package:spicecompanion/util/util.dart';

void main() async {

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
