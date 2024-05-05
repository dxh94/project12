// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:project12/helpers/convert.dart';

// import 'package:project12/helpers/random_number.dart';
// import 'package:project12/model/sub_models/frame_model.dart';
// import 'package:project12/model/sub_models/frame_temp.dart';
// import 'package:project12/model/sub_models/photo_model.dart';
// import 'package:project12/model/sub_models/project.dart';
// import 'package:project12/repositories/project_realm.dart';
// import 'package:project12/view/screen3.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class TestScreen2 extends StatefulWidget {
//   final int projectId;
//   final List<ProjectModel> projects;
//   final ProjectRealm projectRealm;

//   const TestScreen2({
//     super.key,
//     required this.projectId,
//     required this.projects,
//     required this.projectRealm,
//   });

//   @override
//   _TestScreen2State createState() => _TestScreen2State();
// }

// class _TestScreen2State extends State<TestScreen2> {
//   ProjectModel? _projectDetails;
//   List<FrameTemp> _listFrameTemp = [];
//   double _scaleCanvas = 1.0, _previousScaleCanvas = 1.0;
//   double _previousRotation = 0.0;
//   // int? _indexSelected;
//   FrameTemp? _selectFrameTemp;
//   Frame? _currentFrame;
//   File? selectedImage;
//   bool _isExported = false, _isGestureInsideImageFrame = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
//       ProjectModel? a;
//       for (int i = 0; i < widget.projects.length; i++) {
//         if (widget.projects[i].id == widget.projectId &&
//             widget.projects[i].isCheckProject == true) {
//           a = ProjectModel(widget.projects[i].id, randomDouble(),
//               widget.projects[i].name, true,
//               photos: widget.projects[i].photos);
//         }
//       }
//       print(Random().nextInt(100));
//       if (a != null) {
//         _projectDetails = a;
//         for (var item in _projectDetails!.photos) {
//           _listFrameTemp
//               .add(FrameTemp.convertFrameModelToFrameTemp(item.frame!));
//         }
//       } else {
//         _projectDetails = await _fetchProjectDetails(widget.projectId);
//         for (var item in _projectDetails!.photos) {
//           _listFrameTemp
//               .add(FrameTemp.convertFrameModelToFrameTemp(item.frame!));
//         }
//       }
//       setState(() {});
//     });
//   }

//   Future<ProjectModel> _fetchProjectDetails(int projectId) async {
//     print({'id': projectId.toString()});
//     final response = await http.post(
//       Uri.parse('https://tapuniverse.com/xprojectdetail'),
//       body: {'id': projectId.toString()},
//     );
//     if (response.statusCode == 200) {
//       final photo = json.decode(response.body);
//       if (photo['photos'] != null) {
//         return FlutterConvert().convertJsonToProjectModel(photo);
//       } else {
//         throw Exception('Invalid data format');
//       }
//     } else {
//       throw Exception('Failed to load project details');
//     }
//   }

//   void _deleteSelectedImage() {
//     if (_selectFrameTemp != null) {
//       print("_deleteSelectedImage call");
//       // setState(() {
//       //   _projectDetails!.photos.removeAt(_indexSelected!).toString();
//       //   _listFrameTemp.removeAt(_indexSelected!).toString();
//       //   _indexSelected = null;
//       // });
//     }
//   }

//   void _onScaleStart(ScaleStartDetails details, int index) {
//     _currentFrame = Frame(
//       randomInt(),
//       _listFrameTemp[index].x,
//       _listFrameTemp[index].y,
//       _listFrameTemp[index].width,
//       _listFrameTemp[index].height,
//       _listFrameTemp[index].rotation,
//       _listFrameTemp[index].scale,
//     );
//     _previousRotation = _listFrameTemp[index].rotation.toDouble();
//     setState(() {});
//   }

//   void _onScaleUpdate(ScaleUpdateDetails details, int index) {
//     if (details.pointerCount == 1) {
//       _listFrameTemp[index].x =
//           _listFrameTemp[index].x + details.focalPointDelta.dx;
//       _listFrameTemp[index].y =
//           _listFrameTemp[index].y + details.focalPointDelta.dy;
//     } else if (details.pointerCount == 2) {
//       _listFrameTemp[index].width = _currentFrame!.width * details.scale;
//       _listFrameTemp[index].height = _currentFrame!.height * details.scale;
//       _listFrameTemp[index].x = _currentFrame!.x +
//           (_currentFrame!.width - _listFrameTemp[index].width) / 2;
//       _listFrameTemp[index].y = _currentFrame!.y +
//           (_currentFrame!.height - _listFrameTemp[index].height) / 2;
//       _listFrameTemp[index].rotation = _previousRotation + details.rotation;
//     }

//     setState(() {});
//   }

//   void _onBack() {
//     // ProjectModel newProjectModel;
//     // List<Photos> listPhoto = [];
//     // for (int i = 0; i < _listFrameTemp.length; i++) {
//     //   listPhoto.add(Photos(
//     //       _projectDetails!.photos[i].id, _projectDetails!.photos[i].media,
//     //       frame: _listFrameTemp[i].convertFrameTempToFrameModel()));
//     // }
//     // newProjectModel = ProjectModel(
//     //     _projectDetails!.id, randomDouble(), _projectDetails!.name, true,
//     //     photos: listPhoto);
//     // for (int i = 0; i < widget.projects.length; i++) {
//     //   if (newProjectModel.id == widget.projects[i].id) {
//     //     widget.projects[i] = newProjectModel;
//     //     widget.projects[i].isCheckProject = true;
//     //     ProjectRealm()
//     //         .updateProject(widget.projectRealm.realm, widget.projects[i]);
//     //   }
//     // }
//     Navigator.of(context).pop();
//   }

//   void _onOverlayTap(TapDownDetails details) {
//     int indexSelected = -1;
//     Offset localPos = details.localPosition;
//     print("_onOverlayTap local: ${localPos}");
//     for (var i = 0; i < _listFrameTemp.length; i++) {
//       var item = _listFrameTemp[i];
//       Offset startOffset = Offset(item.x.toDouble(), item.y.toDouble());
//       Offset endOffset =
//           startOffset.translate(item.width.toDouble(), item.height.toDouble());
//       print("_onOverlayTap i ${i}: ${startOffset} - ${endOffset}");

//       if (FlutterOffsetHelpers()
//           .containOffset(localPos, startOffset, endOffset)) {
//         indexSelected = i;
//       }
//     }
//     if (indexSelected != -1) {
//       if (_selectFrameTemp?.id != _listFrameTemp[indexSelected].id) {
//         setState(() {
//           _selectFrameTemp = _listFrameTemp[indexSelected];
//         });
//       }
//     } else {
//       if (_selectFrameTemp != null) {
//         setState(() {
//           _selectFrameTemp = null;
//         });
//       }
//     }
//   }

//   void _onGestureScaleStart(ScaleStartDetails details) {
//     if (_selectFrameTemp != null) {
//       // chỉ cho phép scale khi thao tác bên trong khung ảnh
//       Offset startOffset = Offset(_selectFrameTemp!.x, _selectFrameTemp!.y);
//       Offset endOffset = startOffset.translate(
//           _selectFrameTemp!.width, _selectFrameTemp!.height);
//       Offset checkOffset = details.focalPoint;
//       // print("111 : ${checkOffset}");

//       if (FlutterOffsetHelpers()
//           .containOffset(checkOffset, startOffset, endOffset)) {
//         _isGestureInsideImageFrame = true;
//         int index = _listFrameTemp
//             .map(
//               (e) => e.id,
//             )
//             .toList()
//             .indexOf(_selectFrameTemp!.id);
//         _onScaleStart(details, index);
//       }
//     } else {
//       _previousScaleCanvas = _scaleCanvas.toDouble();
//       setState(() {});
//     }
//   }

//   void _onGestureScaleUpdate(ScaleUpdateDetails details) {
//     if (_selectFrameTemp != null) {
//       if (_isGestureInsideImageFrame) {
//         int index = _listFrameTemp
//             .map(
//               (e) => e.id,
//             )
//             .toList()
//             .indexOf(_selectFrameTemp!.id);

//         _onScaleUpdate(details, index);
//       }
//     } else {
//       _scaleCanvas = _previousScaleCanvas * details.scale.toDouble();
//     }
//     setState(() {});
//   }

//   void _onGestureScaleEnd(ScaleEndDetails details) {
//     setState(() {
//       _isGestureInsideImageFrame = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         backgroundColor: const Color(0xffE9EBFF),
//         body: Container(
//           padding: EdgeInsets.only(
//               top: MediaQuery.of(context).padding.top,
//               bottom: MediaQuery.of(context).padding.bottom),
//           child: Column(
//             children: [
//               // tittle
//               _buildTitle(),
//               Expanded(
//                 child: Stack(
//                   children: [
//                     // images + canvas
//                     _buildImageCanvas(),
//                     // gesture layer
//                     _buildGestureLayer(),
//                     // overlay layer
//                     _buildOverlayLayer(),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildImageCanvas() {
//     List<FrameTemp> mainListFrameTemp = List.from(_listFrameTemp);
//     // if (_selectFrameTemp != null) {
//     //   mainListFrameTemp = mainListFrameTemp
//     //       .where((element) => element.id != _selectFrameTemp!.id)
//     //       .toList();
//     //   mainListFrameTemp.insert(0, _selectFrameTemp!);
//     // }
//     return Container(
//       child: (_projectDetails == null)
//           ? const Center(child: CircularProgressIndicator())
//           : Transform.scale(
//               //scale canvas
//               scale: _scaleCanvas,
//               child: Stack(
//                 children: mainListFrameTemp.map(
//                   (item) {
//                     final index = _listFrameTemp
//                         .map((e) => e.id)
//                         .toList()
//                         .indexOf(item.id);
//                     // final photo = item;
//                     final imageMedia = _projectDetails!.photos[index].media;
//                     final imageFrame = item;
//                     // final isSelected = index == _indexSelected;
//                     return Positioned(
//                       top: imageFrame.y.toDouble(),
//                       left: imageFrame.x.toDouble(),
//                       child: Transform.scale(
//                         scale: imageFrame.scale,
//                         child: Transform.rotate(
//                           angle: imageFrame.rotation,
//                           child: Stack(
//                             clipBehavior: Clip.none,
//                             alignment: Alignment.bottomCenter,
//                             children: [
//                               Container(
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                   child: Stack(
//                                     children: [
//                                       imageMedia.contains("http://") ||
//                                               imageMedia.contains("https://")
//                                           ? Image.network(
//                                               imageMedia,
//                                               width:
//                                                   imageFrame.width.toDouble(),
//                                               height:
//                                                   imageFrame.height.toDouble(),
//                                               opacity:
//                                                   const AlwaysStoppedAnimation(
//                                                       1),
//                                               fit: BoxFit.cover,
//                                             )
//                                           : Image.file(
//                                               File(imageMedia),
//                                               width:
//                                                   imageFrame.width.toDouble(),
//                                               height:
//                                                   imageFrame.height.toDouble(),
//                                               opacity:
//                                                   const AlwaysStoppedAnimation(
//                                                       1),
//                                               fit: BoxFit.cover,
//                                             )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ).toList(),
//               ),
//             ),
//     );
//   }

//   Widget _buildGestureLayer() {
//     return Positioned.fill(
//       child: GestureDetector(
//         onTapDown: (details) {
//           print("ao game a");
//           _onOverlayTap(details);
//         },
//         onScaleStart: (details) {
//           _onGestureScaleStart(details);
//         },
//         onScaleUpdate: (details) {
//           _onGestureScaleUpdate(details);
//         },
//         onScaleEnd: (details) {
//           _onGestureScaleEnd(details);
//         },
//       ),
//     );
//   }

//   Widget _buildOverlayLayer() {
//     return IgnorePointer(
//       child: Transform.scale(
//         scale: _scaleCanvas,
//         child: Stack(
//           children: [
//             if (_selectFrameTemp != null) // Show blue border when selected
//               Positioned(
//                 left: _selectFrameTemp!.x.toDouble(), // * ( _scaleCanvas),
//                 top: _selectFrameTemp!.y.toDouble(), // * ( _scaleCanvas),
//                 child: Transform.scale(
//                   scale: _selectFrameTemp!.scale.toDouble(),
//                   child: Transform.rotate(
//                     angle: _selectFrameTemp!.rotation.toDouble(),
//                     child: Stack(
//                       clipBehavior: Clip.none,
//                       alignment: Alignment.topCenter,
//                       children: [
//                         Positioned(
//                           // top: -30,
//                           child: GestureDetector(
//                             onTap: _deleteSelectedImage,
//                             child: Container(
//                               width: 30,
//                               height: 30,
//                               decoration: BoxDecoration(
//                                 color: Colors.red,
//                                 borderRadius: BorderRadius.circular(999),
//                               ),
//                               child: const Icon(
//                                 Icons.remove,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                         Container(
//                           width: (_selectFrameTemp?.width.toDouble() ?? 0),
//                           height: (_selectFrameTemp?.height.toDouble() ?? 0),
//                           decoration: BoxDecoration(
//                             border: Border.all(
//                               color: Colors.blue,
//                               width: 4.0,
//                             ),
//                             borderRadius: BorderRadius.circular(12.0),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTitle() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Align(
//           alignment: Alignment.centerLeft,
//           child: TextButton(
//             onPressed: _onBack,
//             child: const Text(
//               "Back",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         TextButton(
//           onPressed: () async {
//             XFile? xFile =
//                 await ImagePicker().pickImage(source: ImageSource.gallery);
//             if (xFile != null) {
//               _projectDetails!.photos.add(
//                 Photos(
//                   randomInt(),
//                   xFile.path,
//                   frame: Frame(randomInt(), 0, 0, 200, 200, 1, 0),
//                 ),
//               );
//               _listFrameTemp.add(
//                 FrameTemp(
//                   height: 200,
//                   id: randomInt(),
//                   rotation: 0,
//                   scale: 1,
//                   width: 200,
//                   x: 0,
//                   y: 0,
//                 ),
//               );
//               setState(() {});
//             }
//           },
//           child: const Text(
//             "",
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         Align(
//           alignment: Alignment.centerRight,
//           child: TextButton(
//             onPressed: () {
//               Navigator.of(context).push(MaterialPageRoute(
//                 builder: (context) {
//                   return Screen3(listPhoto: _projectDetails!.photos);
//                 },
//               ));
//             },
//             child: const Text(
//               "Export",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRedIcon() {
//     return Positioned(
//       // left: _selectFrameTemp?.x.toDouble() +
//       //     _selectFrameTemp?.width / 2 +
//       //     _selectFrameTemp?.height / 2 * sin(_selectFrameTemp?.rotation),
//       // top: _selectFrameTemp?.y.toDouble() -
//       //     30 +
//       //     _selectFrameTemp?.height / 2 * (1 - cos(_selectFrameTemp?.rotation),),
//       child: GestureDetector(
//         onTap: _deleteSelectedImage,
//         child: Transform.rotate(
//           angle: 0, // _selectFrameTemp?.rotation.toDouble(),
//           child: Container(
//             width: 30,
//             height: 30,
//             decoration: BoxDecoration(
//               color: Colors.red,
//               borderRadius: BorderRadius.circular(999),
//             ),
//             child: const Icon(
//               Icons.remove,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// class FlutterOffsetHelpers {
//   bool containOffset(Offset checkOffset, Offset startOffset, Offset endOffset) {
//     return (startOffset.dx <= checkOffset.dx &&
//             checkOffset.dx <= endOffset.dx) &&
//         (startOffset.dy <= checkOffset.dy && checkOffset.dy <= endOffset.dy);
//   }
// }