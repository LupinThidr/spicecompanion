library util;
import 'package:spicecompanion/spiceapi/spiceapi.dart';
import 'package:pool/pool.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:html';
import 'package:flutter_web/services.dart';
import 'package:hex/hex.dart';
part 'pool.dart';
part 'patch.dart';
part 'tagman.dart';
part 'cipher.dart';

Future<String> downloadTextFromURL(String url) async {
  return await HttpRequest.getString(url);
}

String trimWhitespace(String s) {
  return s.replaceAll(RegExp(r"\s\b|\b\s"), "");
}

/// remove unneeded things from hex string
/// tries to provide hex string in a consistent format (e.g. "DEADBEEF")
/// ignores invalid characters like "?" (needed for signatures)
/// accepts formats like:
/// "0xDEADBEEF"
/// "{0xDE, 0xAD, 0xBE, 0xEF}"
String trimHex(String hex) {
  hex = hex.replaceAll("{", "");
  hex = hex.replaceAll("}", "");
  hex = hex.replaceAll("0x", "");
  hex = hex.replaceAll(",", "");
  return trimWhitespace(hex).toUpperCase();
}
