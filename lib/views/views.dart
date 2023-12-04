library views;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:html';
import 'package:flutter_web/material.dart';
import 'package:flutter_web/services.dart';
import 'package:intl/intl.dart';
import 'package:spicecompanion/spiceapi/spiceapi.dart';
import 'package:spicecompanion/util/util.dart';

part 'servers.dart';
part 'cardmanager.dart';
part 'keypad.dart';
part 'buttons.dart';
part 'analogs.dart';
part 'lights.dart';
part 'patches.dart';
part 'info.dart';
part 'controller.dart';
part 'resources.dart';
part 'mainview.dart';
part 'settings.dart';

enum SpiceView {
  Servers,
  CardManager,
  Keypad,
  Patches,
  Controller,
  Buttons,
  Analogs,
  Lights,
  Info,
  Settings,
}

SpiceView defaultSpiceView = SpiceView.Servers;

Widget getView(SpiceView view) {
  switch (view) {
    case SpiceView.Servers:
      return ServerView();
    case SpiceView.CardManager:
      return CardManagerView();
    case SpiceView.Keypad:
      return KeypadView();
    case SpiceView.Patches:
      return PatchesView();
    case SpiceView.Controller:
      return ControllerView();
    case SpiceView.Buttons:
      return ButtonsView();
    case SpiceView.Analogs:
      return AnalogsView();
    case SpiceView.Lights:
      return LightsView();
    case SpiceView.Info:
      return InfoView();
    case SpiceView.Settings:
      return SettingsView();
    default:
      return Material(
        color: Colors.red,
        child: Center(
          child: Text(
            'Unknown View \'$view\'',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            )
          ),
        )
      );
  }
}

String getViewName(SpiceView view) {
  switch (view) {
    case SpiceView.Servers:
      return 'Servers';
    case SpiceView.CardManager:
      return 'Card Manager';
    case SpiceView.Keypad:
      return 'Keypad/Scanner';
    case SpiceView.Patches:
      return 'Patches';
    case SpiceView.Controller:
      return 'Controller (soon)';
    case SpiceView.Buttons:
      return 'Buttons';
    case SpiceView.Analogs:
      return 'Analogs';
    case SpiceView.Lights:
      return 'Lights';
    case SpiceView.Info:
      return 'Server Information';
    case SpiceView.Settings:
      return 'Settings';
    default:
      return 'Unknown View';
  }
}
