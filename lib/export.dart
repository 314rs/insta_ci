import 'dart:io';

import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:insta_ci/preset.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class Export extends StatefulWidget {
  final String command;
  late final String filename;
  late final String filetype;
  final String filepath;
  final int overlay;

  Export({Key? key, required this.command, required this.filepath, required this.overlay})
      : super(key: key) {
    filename = basenameWithoutExtension(filepath);
    filetype = extension(filepath);
    print("command: $command \nfilename: $filename \nfiletype: $filetype");
  }

  @override
  State<Export> createState() => _ExportState();

  
}

class _ExportState extends State<Export> {
  String filepath = "/storage/emulated/0/Pictures/InstaCI/";
  String? _output;
  performAction() async {
    print("performing Action");
    if (!await Directory(filepath).exists()) {
      await Directory(filepath).create(recursive: true);
    }
    String ffmpegCommand =
        "-i ${widget.filepath} -i /storage/emulated/0/Pictures/InstaCI/Linie6+logo.png  ${widget.command} ${filepath}insta${DateFormat("yyyy_MM_dd_HH_mm_ss").format(DateTime.now())}${widget.filetype}";
    //String ffmpegCommand = "-i /storage/emulated/0/Pictures/FFmpeg/Test.mp4 -c copy /storage/emulated/0/Pictures/FFmpeg/Test_insta.mp4";
    print("ffmpegcommand : $ffmpegCommand");
    FFmpegKit.execute(ffmpegCommand).then((session) async {
      final returnCode = await session.getReturnCode();
      final output = await session.getOutput();
      setState(() {
        _output = output!;
      });
      print(returnCode);

      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        print("ffmpeg success");
      } else if (ReturnCode.isCancel(returnCode)) {
        // CANCEL
        print("ffmpeg cancel");
      } else {
        // ERROR
        print("ffmpeg else");
      }
    });
  }
  @override
  void initState() {
    super.initState();
    performAction();
  }
 

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Speichern"),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Text(widget.command),
          Text(_output ?? ""),
        ],
      ),
    );
  }
}