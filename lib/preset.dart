import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class Preset {
  Preset(
      {this.icon = const Icon(Icons.texture),
      this.color = Colors.lightBlue,
      required this.command});
  Icon icon;
  Color color;
  String command;
}

Future<String> getAppDir() async {
  Directory? appDocDir = await getApplicationDocumentsDirectory();
  String appDocPath = appDocDir.path;
  return appDocPath;
}

List<Preset> cmd = [
  Preset(
      command:
          "-filter_complex [0]scale=1920:1920:force_original_aspect_ratio=increase,crop=1920:1920[vid];[1][vid]scale2ref=iw:ow/mdar[line][vid];[vid][line]overlay=0:H-h",
      color: Colors.redAccent,
      icon: const Icon(Icons.open_in_full)),
  Preset(
      command:
          "-filter_complex [0:v]split=2[blur][vid];[blur]scale=1920:1920:force_original_aspect_ratio=increase,crop=1920:1920,boxblur=luma_radius=20:luma_power=1:chroma_radius=min(cw\\,ch)/20:chroma_power=1[bg];[vid]scale=1920:1920:force_original_aspect_ratio=decrease[ov];[bg][ov]overlay=(W-w)/2:(H-h)/2[vid];[1][vid]scale2ref=iw:ow/mdar[line][vid];[vid][line]overlay=0:H-h",
      color: Colors.amber,
      icon: const Icon(Icons.close_fullscreen)),
  Preset(
      command:
          "[1][0]scale2ref=iw:ow/mdar[line][vid];[vid][line]overlay=0:H-h"),
];

Future<void> copyAssets() async {
  var assets = Directory("assets");
  for (File file in assets.listSync().whereType<File>()) {
    await file.copy("${getApplicationDocumentsDirectory()}/lines/${basename(file.path)}");
    print((await getApplicationDocumentsDirectory()).list().toString());
  }

}
