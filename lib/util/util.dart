library util;
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';
import 'package:hex/hex.dart';
import 'package:pool/pool.dart';
import 'package:spicecompanion/platform/platform.dart';
import 'package:spicecompanion/spiceapi/spiceapi.dart';
import 'package:spicecompanion/views/views.dart';
part 'pool.dart';
part 'patch.dart';
part 'tagman.dart';
part 'cipher.dart';

Future<String> downloadTextFromURL(String url) async {
  return new HttpClient()
      .getUrl(Uri.parse(url))
      .then((HttpClientRequest req) => req.close())
      .then((HttpClientResponse res) {
        return res.transform(Utf8Decoder()).toList().then((data) {
          return data.join("");
        });
  });
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
