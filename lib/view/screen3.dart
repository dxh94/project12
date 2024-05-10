import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter_image_filters/flutter_image_filters.dart';
import 'package:project12/model/sub_models/photo_model.dart';
import 'package:project12/view/saveHelper.dart';

class Screen3 extends StatefulWidget {
  final List<Photos> listPhoto;

  const Screen3({Key? key, required this.listPhoto}) : super(key: key);

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  bool isLoading = true;
  late List<ui.Image> listImageData;

  @override
  void initState() {
    super.initState();
    listImageData = [];
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      for (int i = 0; i < widget.listPhoto.length; i++) {
        String mediaUrl = widget.listPhoto[i].media;
        ui.Image imageData;
        if (mediaUrl.contains("http:") || mediaUrl.contains("https:")) {
          imageData = await getUrlImage(widget.listPhoto[i].media);
        } else {
          imageData = await getFileImage(widget.listPhoto[i].media);
        }
        listImageData.add(imageData);
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen 3"),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.blue,
              )
            : Container(
                color: Colors.black,
                width: 400,
                height: 400,
                child: CustomPaint(
                  painter: GraphicCanvas(
                    listPhotos: widget.listPhoto,
                    sizeGraphic: MediaQuery.of(context).size,
                    listImageData: listImageData,
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _downloadImage();
        },
        child: Icon(Icons.download),
      ),
    );
  }

  Future<ui.Image> getFileImage(String path) async {
    TextureSource textureSource = await TextureSource.fromFile(File(path));
    return textureSource.image;
  }

  Future<ui.Image> getUrlImage(String path) async {
    final completer = Completer<ImageInfo>();
    final img = NetworkImage(path);
    img.resolve(ImageConfiguration.empty).addListener(
      ImageStreamListener((info, _) {
        completer.complete(info);
      }),
    );
    final imageInfo = await completer.future;
    return imageInfo.image;
  }

  void _downloadImage() async {
    ui.Image? generatedImage =
        await _generateImage(widget.listPhoto, MediaQuery.of(context).size);
    ByteData? byteData =
        await generatedImage.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData != null) {
      Uint8List data = byteData.buffer.asUint8List();
      String? outPath = await SaveHelpers().saveToLibrary(data);
    }
  }

  Future<ui.Image> _generateImage(
      List<Photos> listPhotos, Size imageSize) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    final paint = Paint();
    for (int i = 0; i < listPhotos.length; i++) {
      canvas.save();
      canvas.rotate(listPhotos[i].frame?.rotation ?? 0.0 );
      canvas.scale(1 / (listPhotos[i].frame?.scale ?? 1));
      canvas.drawImageRect(
        listImageData[i],
        Rect.fromLTRB(0, 0, listImageData[i].width.toDouble(),
            listImageData[i].height.toDouble()),
        Rect.fromLTRB(0, 0, (listPhotos[i].frame?.width ?? 0),
            (listPhotos[i].frame?.height ?? 0)),
        paint,
      );
      canvas.restore();
    }
    return await recorder
        .endRecording()
        .toImage(imageSize.width.toInt() * 2, imageSize.height.toInt() * 2);
  }
}

class GraphicCanvas extends CustomPainter {
  final Size sizeGraphic;
  final List<Photos> listPhotos;
  final List<ui.Image> listImageData;

  GraphicCanvas({
    required this.listPhotos,
    required this.sizeGraphic,
    required this.listImageData,
  });

  @override
  void paint(Canvas canvas, Size size) async {
    final paint = Paint();
    for (int i = 0; i < listPhotos.length; i++) {
      canvas.save();
      canvas.rotate(listPhotos[i].frame?.rotation ?? 0.0);
      canvas.scale(1 / (listPhotos[i].frame?.scale ?? 1));
      canvas.drawImageRect(
        listImageData[i],
        Rect.fromLTRB(0, 0, listImageData[i].width.toDouble(),
            listImageData[i].height.toDouble()),
        Rect.fromLTRB(0, 0, (listPhotos[i].frame?.width ?? 0),
            (listPhotos[i].frame?.height ?? 0)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
