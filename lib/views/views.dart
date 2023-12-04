library views;

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:intl/intl.dart';
import 'package:spicecompanion/spiceapi/spiceapi.dart';
import 'package:spicecompanion/util/util.dart';
import 'package:spicecompanion/platform/platform.dart';
import 'package:vibration/vibration.dart';
import 'package:mutex/mutex.dart';

part 'servers.dart';
part 'cardmanager.dart';
part 'keypad.dart';
part 'buttons.dart';
part 'analogs.dart';
part 'lights.dart';
part 'coins.dart';
part 'patches.dart';
part 'info.dart';
part 'resources.dart';
part 'mainview.dart';
part 'settings.dart';
part 'screen.dart';
part 'controllers/controller.dart';
part 'controllers/buttoncontrol.dart';
part 'controllers/touchcontrol.dart';
part 'controllers/jb.dart';
part 'controllers/iidx.dart';
part 'controllers/popn.dart';
part 'controllers/nost.dart';
part 'controllers/sdvx.dart';
part 'controllers/ddr.dart';
part 'controllers/bbc.dart';
part 'controllers/hpm.dart';
part 'controllers/rf3d.dart';
part 'controllers/ftt.dart';
part 'controllers/lp.dart';
part 'controllers/drs.dart';
part 'controllers/we.dart';

enum SpiceView {
  Servers,
  CardManager,
  Keypad,
  Patches,
  Screen,
  Controller,
  Buttons,
  Analogs,
  Lights,
  Coins,
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
    case SpiceView.Screen:
      return ScreenView();
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
    case SpiceView.Coins:
      return CoinsView();
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
    case SpiceView.Screen:
      return 'Screen (Beta)';
    case SpiceView.Controller:
      return 'Controller';
    case SpiceView.Buttons:
      return 'Buttons';
    case SpiceView.Analogs:
      return 'Analogs';
    case SpiceView.Lights:
      return 'Lights';
    case SpiceView.Coins:
      return 'Coins';
    case SpiceView.Info:
      return 'Server Information';
    case SpiceView.Settings:
      return 'Settings';
    default:
      return 'Unknown View';
  }
}
