import 'dart:async';
import 'dart:io';
import 'package:project12/model/sub_models/photo_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter_image_filters/flutter_image_filters.dart';

class Screen3 extends StatefulWidget {
  final List<Photos> listPhoto;
  const Screen3({super.key, required this.listPhoto});
  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  bool isLoading = true;
  late List<ui.Image> listImageData;

  late ui.Image mainData;
  @override
  void initState() {
    super.initState();
    listImageData = [];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
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
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    print("listImageData ${listImageData}");
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen 3"),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.blue,
              )
            :
            // FutureBuilder(
            //     future: _generateImage(
            //         widget.listPhoto, MediaQuery.sizeOf(context)),
            //     builder: (context, data) {
            //       if (data.hasData) {
            //         return Container(
            //           color: Colors.red,
            //           child: CustomPaint(
            //             painter: GeneratePainter(image: data.data!),
            //           ),
            //         );
            //       } else {
            //         return const CircularProgressIndicator(
            //           color: Colors.red,
            //         );
            //       }
            //     })

            Container(
                color: Colors.black,
                width: 400,
                height: 400,
                child: CustomPaint(
                  painter: GraphicCanvas(
                    listPhotos: widget.listPhoto,
                    sizeGraphic: MediaQuery.sizeOf(context),
                    listImageData: listImageData,
                  ),
                ),
              ),
      ),
    );
  }

  Future<ui.Image> _generateImage(
      List<Photos> listPhotos, Size imageSize) async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    final paint = Paint();
    for (int i = 0; i < listPhotos.length; i++) {
      print("listPhotos[i].frame?.x ${listPhotos[i].frame?.width}");
      print("listPhotos[i].frame?.y ${listPhotos[i].frame?.height}");
      print("listPhotos[i].frame?.rotation ${listPhotos[i].frame?.rotation}");
      print("listPhotos[i].frame?.scale ${listPhotos[i].frame?.scale}");

      canvas.save();
      canvas.rotate((listPhotos[i].frame?.rotation) ?? 0.0);
      canvas.scale(1 / ((listPhotos[i].frame?.scale) ?? 1));
      // canvas.drawImage(
      //   listImageData[i],
      //   Offset((listPhotos[i].frame?.x) ?? 0, (listPhotos[i].frame?.y) ?? 0),
      //   paint,
      // );
      canvas.drawImageRect(
        listImageData[i],
        Rect.fromLTRB(0, 0, listImageData[i].width.toDouble(),
            listImageData[i].height.toDouble()),
        Rect.fromLTRB(0, 0, (listPhotos[i].frame?.width) ?? 0,
            (listPhotos[i].frame?.height) ?? 0),
        paint,
      );
      canvas.restore();
    }
    return await recorder
        .endRecording()
        .toImage(imageSize.width.toInt() * 2, imageSize.height.toInt() * 2);
  }
}

class GeneratePainter extends CustomPainter {
  final ui.Image image;
  GeneratePainter({required this.image});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
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
      print(
          "listPhotos[i].frame?.x ${listPhotos[i].frame?.width}"); //96.1132071199221, 192.2264142398442
      print("listPhotos[i].frame?.y ${listPhotos[i].frame?.height}");
      print("listPhotos[i].frame?.rotation ${listPhotos[i].frame?.rotation}");
      print("listPhotos[i].frame?.scale ${listPhotos[i].frame?.scale}");

      canvas.save();
      canvas.rotate((listPhotos[i].frame?.rotation) ?? 0.0);
      canvas.scale(1 / ((listPhotos[i].frame?.scale) ?? 1));
      // canvas.drawImage(
      //   listImageData[i],
      //   Offset((listPhotos[i].frame?.x) ?? 0, (listPhotos[i].frame?.y) ?? 0),
      //   paint,
      // );
      canvas.drawImageRect(
        listImageData[i],
        Rect.fromLTRB(0, 0, listImageData[i].width.toDouble(),
            listImageData[i].height.toDouble()),
        Rect.fromLTRB(0, 0, (listPhotos[i].frame?.width) ?? 0,
            (listPhotos[i].frame?.height) ?? 0),
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

Future<ui.Image> getFileImage(String path) async {
  // final ByteData data = await rootBundle.load(path);
  // final Completer<ui.Image> completer = Completer();
  // ui.decodeImageFromList(Uint8List.view(data.buffer), completer.complete);
  // return completer.future;
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
  //   TextureSource textureSource = await TextureSource.fromFile(File(path));
  // return textureSource.image;
}
