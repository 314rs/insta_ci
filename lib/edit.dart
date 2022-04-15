import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:insta_ci/export.dart';
import 'package:insta_ci/preset.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:video_player/video_player.dart';

class Edit extends StatefulWidget {
  const Edit({Key? key}) : super(key: key);

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  File? _image;
  final _presets = cmd;
  int? _preset;
  int _overlay = 1;
  String? _appDocPath;
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    getAppDir();
    copyAssets();
  }

  getAppDir() async {
    Directory? appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    setState(() {
      _appDocPath = appDocPath;
    });
  }

  Future pickImage() async {
    var perm = Permission.storage;
    if (await perm.isGranted ||
        await perm.request() == PermissionStatus.granted) {
      final _file = await FilePicker.platform.pickFiles(type: FileType.media);
      if (_file == null) return;
      for (var file in _file.files) {
        print(file.path);
        print(lookupMimeType(file.path!)!.split("/")[0]);
      }
      File? imageTemp;
      if (_file.files.single.path == "image") {
        imageTemp = await FlutterExifRotation.rotateImage(
            path: _file.files.single.path!);
      } else {
        imageTemp = File(_file.files.single.path!);
        _controller = VideoPlayerController.file(imageTemp)
          ..initialize().then((_) {
            setState(() {});
          });
      }
      setState(() => _image = imageTemp);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Insta CI"),
        centerTitle: true,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(
            child: PageView.builder(
              scrollDirection: Axis.horizontal,
              controller: PageController(viewportFraction: .2),
              onPageChanged: (index) => setState(() => _preset = index),
              itemCount: _presets.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      child: _presets[index].icon,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: _presets[index].color,
                      ),
                    ),
                  ),
                );
              },
            ),
            height: 100,
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                GestureDetector(
                  onLongPress: pickImage,
                  behavior: HitTestBehavior.translucent,
                  child: _image != null
                      ? (lookupMimeType(_image!.path)!.split("/")[0] == "image"
                          ? Image.file(
                              _image!,
                              fit: BoxFit.fitWidth,
                              height: double.infinity,
                              width: double.infinity,
                            )
                          : () {
                              false //_controller!.value.isInitialized
                                  ? VideoPlayer(_controller)
                                  : const CircularProgressIndicator(
                                      color: Colors.green,
                                    );
                            }())
                      : (Container(
                          color: Colors.lightGreen,
                          child: const Center(
                            child: Text("long tap to load image"),
                          ),
                        )),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ExpandablePageView.builder(
                    onPageChanged: (index) => setState(() => _overlay = index),
                    scrollDirection: Axis.horizontal,
                    controller: PageController(viewportFraction: 1),
                    itemCount: 11,
                    itemBuilder: (context, index) =>
                        Image.asset("assets/Linie$index.png"),
                  ),
                )
              ],
            ),
          ),
          ElevatedButton(
              child: const Text("Render"),
              onPressed: () => _image != null
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Export(
                          command: _presets[_preset!].command,
                          filepath: _image!.path,
                          overlay: _overlay,
                        ),
                      ),
                    )
                  : {}),
          Text(_appDocPath ?? "not loaded yet"),
        ],
      ),
    );
  }
}
