import 'dart:convert';
import 'dart:io';
import 'package:project12/helpers/convert.dart';
import 'package:project12/helpers/random_number.dart';
import 'package:project12/model/sub_models/image_project.dart';
import 'package:project12/model/sub_models/frame_model.dart';
import 'package:project12/model/sub_models/frame_temp.dart';
import 'package:project12/model/sub_models/photo_model.dart';
import 'package:project12/model/sub_models/project.dart';
import 'package:project12/repositories/project_realm.dart';
import 'package:project12/view/gridview.dart';
import 'package:project12/view/screen3.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final int projectId;
  final List<ProjectModel> projects;
  final ProjectRealm projectRealm;

  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
    required this.projects,
    required this.projectRealm,
  });

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  ProjectModel? _projectDetails;
  List<FrameTemp> _listFrameTemp = [];
  List<GlobalKey> keys = [];
  GlobalKey canvasKey = GlobalKey();
  double _scaleCanvas = 1.0, _previousScaleCanvas = 1.0;
  double _previousRotation = 0.0;
  // int? _indexSelected;
  FrameTemp? _selectFrameTemp;
  Frame? _currentFrame;
  List<Frame> _currentListFrame = [];
  File? selectedImage;
  bool _isExported = false, _isGestureInsideImageFrame = false;
  int indexSelected = -1;
  double _blurValue = 0.0;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      ProjectModel? a;
      for (int i = 0; i < widget.projects.length; i++) {
        if (widget.projects[i].id == widget.projectId &&
            widget.projects[i].isCheckProject == true) {
          a = ProjectModel(widget.projects[i].id, randomDouble(),
              widget.projects[i].name, true,
              photos: widget.projects[i].photos);
        }
      }
      if (a != null) {
        _projectDetails = a;
        for (var item in _projectDetails!.photos) {
          _listFrameTemp
              .add(FrameTemp.convertFrameModelToFrameTemp(item.frame!));
        }
      } else {
        _projectDetails = await _fetchProjectDetails(widget.projectId);
        for (var item in _projectDetails!.photos) {
          _listFrameTemp
              .add(FrameTemp.convertFrameModelToFrameTemp(item.frame!));
        }
      }
      keys = _projectDetails!.photos.map((e) {
        return GlobalKey();
      }).toList();
      setState(() {});
    });
  }

  Future<ProjectModel> _fetchProjectDetails(int projectId) async {
    print({'id': projectId.toString()});
    final response = await http.post(
      Uri.parse('https://tapuniverse.com/xprojectdetail'),
      body: {'id': projectId.toString()},
    );
    if (response.statusCode == 200) {
      final photo = json.decode(response.body);
      if (photo['photos'] != null) {
        return FlutterConvert().convertJsonToProjectModel(photo);
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception('Failed to load project details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xffE9EBFF),
        body: Container(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: MediaQuery.of(context).padding.bottom),
          child: Column(
            children: [
              // tittle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _onBack,
                      child: const Text(
                        "Back",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      XFile? xFile = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (xFile != null) {
                        _projectDetails!.photos.add(
                          Photos(
                            randomInt(),
                            xFile.path,
                            frame: Frame(randomInt(), 0, 0, 200, 200, 1, 0),
                          ),
                        );
                        _listFrameTemp.add(
                          FrameTemp(
                            height: 200,
                            id: randomInt(),
                            rotation: 0,
                            scale: 1,
                            width: 300,
                            x: 0,
                            y: 0,
                          ),
                        );
                        setState(() {});
                      }
                    },
                    child: const Text(
                      "",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return Screen3(listPhoto: _projectDetails!.photos);
                          },
                        ));
                      },
                      child: const Text(
                        "Export",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      child: (_projectDetails == null)
                          ? const Center(child: CircularProgressIndicator())
                          : Transform.scale(
                              //scale canvas
                              scale: _scaleCanvas,
                              child: InteractiveViewer(
                                panEnabled: !_isGestureInsideImageFrame,
                                scaleEnabled: !_isGestureInsideImageFrame,
                                boundaryMargin: const EdgeInsets.symmetric(
                                  vertical: double.infinity,
                                  horizontal: double.infinity,
                                ),
                                maxScale: 4,
                                minScale: 0.4,
                                trackpadScrollCausesScale: true,
                                onInteractionStart: _onInteractionStart,
                                onInteractionUpdate: _onInteractionUpdate,
                                onInteractionEnd: _onInteractionEnd,
                                child: Stack(
                                  children: [
                                    _buildCustomSlider(),
                                    _buildImageCanvas(),
                                    _buildOverlayLayer(),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        floatingActionButton: _isExported
            ? FloatingActionButton.extended(
                onPressed: _downloadImage,
                label: const Text(
                  'Download',
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.blue,
              )
            : Container(
                margin: const EdgeInsets.only(bottom: 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildCustomSlider(),
                    const SizedBox(height: 16),
                    FloatingActionButton.extended(
                      onPressed: _navigateToPhotoSelectionScreen,
                      label: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 100.0),
                        child: Text(
                          'Add Photo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                  ],
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  void _downloadImage() {}

  Widget _buildCustomSlider() {
    const gradient = LinearGradient(
      colors: [Color(0xff3575FE), Color(0xffEC4CD2)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 4.0,
        thumbColor: Colors.blue,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 12.0,
        ),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 24.0),
      ),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return gradient.createShader(bounds);
        },
        child: Slider(
          value: _blurValue,
          min: 0.0,
          max: 1.0,
          onChanged: (newValue) {
            setState(() {
              _blurValue = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildOverlayLayer() {
    return IgnorePointer(
      child: Transform.scale(
        scale: 1,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (_selectFrameTemp != null)
              Positioned(
                left: _selectFrameTemp!.x.toDouble(),
                top: _selectFrameTemp!.y.toDouble(),
                child: Transform.scale(
                  scale: _selectFrameTemp!.scale.toDouble(),
                  child: Transform.rotate(
                    angle: _selectFrameTemp!.rotation.toDouble(),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Positioned(
                          top: -40,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Rectangle outline
                        Container(
                          width: (_selectFrameTemp?.width.toDouble() ?? 0),
                          height: (_selectFrameTemp?.height.toDouble() ?? 0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue,
                              width: 4.0 / _scaleCanvas,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        Positioned(
                          left: -7,
                          top: -7,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -7,
                          top: -7,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: -7,
                          bottom: -7,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -7,
                          bottom: -7,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCanvas() {
    List<FrameTemp> mainListFrameTemp = List.from(_listFrameTemp);
    return Container(
      color: const Color.fromARGB(255, 190, 206, 247),
      width: 400,
      height: 550,
      child: (_projectDetails == null)
          ? const Center(child: CircularProgressIndicator())
          : Transform.scale(
              //scale canvas
              key: canvasKey,
              scale: 1,
              child: Stack(
                clipBehavior: Clip.none,
                children: mainListFrameTemp.map(
                  (item) {
                    final index = _listFrameTemp                                                
                        .map((e) => e.id)                                                
                        .toList()                                                
                        .indexOf(item.id);                                                
                                                
                    final imageMedia = _projectDetails!.photos[index].media;                                                
                    final imageFrame = item;                                                
                                                
                    return Positioned(                                                
                      key: keys[index],                                                
                      top: imageFrame.y.toDouble(),                                                
                      left: imageFrame.x.toDouble(),                                                
                      child: Transform.scale(                                                
                        scale: imageFrame.scale,                                                
                        child: Transform.rotate(                                                
                          angle: imageFrame.rotation,                                                
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Stack(
                                    children: [
                                      imageMedia.contains("http://") ||
                                              imageMedia.contains("https://")
                                          ? Image.network(
                                              imageMedia,
                                              width: imageFrame.width,
                                              height: imageFrame.height,
                                              opacity: indexSelected == index
                                                  ? AlwaysStoppedAnimation(
                                                      _blurValue)
                                                  : null,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(imageMedia),
                                              width:
                                                  imageFrame.width.toDouble(),
                                              height:
                                                  imageFrame.height.toDouble(),
                                              opacity: indexSelected == index
                                                  ? AlwaysStoppedAnimation(
                                                      _blurValue)
                                                  : null,
                                              fit: BoxFit.cover,
                                            )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
    );
  }

  void _deleteSelectedImage() {
    if (_selectFrameTemp != null) {
      int index = _listFrameTemp.indexOf(_selectFrameTemp!);
      setState(() {
        _projectDetails!.photos.removeAt(index);
        _listFrameTemp.removeAt(index);
        keys.removeAt(index);
        _selectFrameTemp = null;
        indexSelected = -1;
      });
    }
  }

  void _onScaleStart(ScaleStartDetails details, int index) {
    _currentFrame = Frame(
      randomInt(),
      _listFrameTemp[index].x,
      _listFrameTemp[index].y,
      _listFrameTemp[index].width,
      _listFrameTemp[index].height,
      _listFrameTemp[index].rotation,
      _listFrameTemp[index].scale,
    );
    _previousRotation = _listFrameTemp[index].rotation.toDouble();
    setState(() {});
  }

  void _onScaleUpdate(ScaleUpdateDetails details, int index) {
    if (details.pointerCount == 1) {
      _listFrameTemp[index].x =
          _listFrameTemp[index].x + details.focalPointDelta.dx;
      _listFrameTemp[index].y =
          _listFrameTemp[index].y + details.focalPointDelta.dy;
    } else if (details.pointerCount == 2) {
      _listFrameTemp[index].width = _currentFrame!.width * details.scale;
      _listFrameTemp[index].height = _currentFrame!.height * details.scale;
      _listFrameTemp[index].x = _currentFrame!.x +
          (_currentFrame!.width - _listFrameTemp[index].width) / 2;
      _listFrameTemp[index].y = _currentFrame!.y +
          (_currentFrame!.height - _listFrameTemp[index].height) / 2;
      _listFrameTemp[index].rotation = _previousRotation + details.rotation;
    }
    setState(() {});
  }

  void _onBack() {
    ProjectModel newProjectModel;
    List<Photos> listPhoto = [];
    for (int i = 0; i < _listFrameTemp.length; i++) {
      listPhoto.add(Photos(
          _projectDetails!.photos[i].id, _projectDetails!.photos[i].media,
          frame: _listFrameTemp[i].convertFrameTempToFrameModel()));
    }
    newProjectModel = ProjectModel(
        _projectDetails!.id, randomDouble(), _projectDetails!.name, true,
        photos: listPhoto);
    for (int i = 0; i < widget.projects.length; i++) {
      if (newProjectModel.id == widget.projects[i].id) {
        widget.projects[i] = newProjectModel;
        widget.projects[i].isCheckProject = true;
        ProjectRealm()
            .updateProject(widget.projectRealm.realm, widget.projects[i]);
      }
    }
    Navigator.of(context).pop();
  }

  void _navigateToPhotoSelectionScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PhotoSelectionScreen(
                  onUpdateImageSelection: (List<ImageProject> values) {
                _addSelectedImage(values);
              })),
    );
  }

  void _addSelectedImage(List<ImageProject> selectedImages) {
    setState(() {
      for (var selectedImage in selectedImages) {
        _projectDetails!.photos.add(Photos(randomInt(), selectedImage.file.path,
            frame: Frame(randomInt(), 0, 0, 200, 200, 1, 0)));
        _listFrameTemp.add(FrameTemp(
            height: 200,
            id: randomInt(),
            rotation: 0,
            scale: 1,
            width: 200,
            x: 0,
            y: 0));
      }
      keys.add(GlobalKey());
    });
  }

  void _onInteractionStart(ScaleStartDetails details) {
    RenderBox canvasBox =
        canvasKey.currentContext?.findRenderObject() as RenderBox;
    Offset localPos = canvasBox.globalToLocal(details.localFocalPoint);
    keys.indexed.forEach((element) {
      RenderBox imageBox =
          element.$2.currentContext?.findRenderObject() as RenderBox;
      Offset touch = imageBox.globalToLocal(details.focalPoint);
      Offset start = const Offset(0, 0);
      Offset end = start.translate(
          _listFrameTemp[element.$1].width, _listFrameTemp[element.$1].height);
      if (FlutterOffsetHelpers().containOffset(touch, start, end)) {
        print("Yolo at ${element.$1}");
        indexSelected = element.$1;
      }
    });
    if (indexSelected != -1) {
      if (_selectFrameTemp?.id != _listFrameTemp[indexSelected].id) {
        setState(() {
          _selectFrameTemp = _listFrameTemp[indexSelected];
        });
      }
    } else {
      if (_selectFrameTemp != null) {
        setState(() {
          _selectFrameTemp = null;
          indexSelected = -1;
        });
      }
    }
    if (_selectFrameTemp != null) {
      RenderBox imageBox =
          keys[indexSelected].currentContext?.findRenderObject() as RenderBox;
      Offset touch = imageBox.globalToLocal(details.focalPoint);
      Offset start = const Offset(0, 0);
      Offset end = start.translate(_listFrameTemp[indexSelected].width,
          _listFrameTemp[indexSelected].height);

      print("object ${indexSelected} ${start} ${end} ${touch}");

      if (FlutterOffsetHelpers().containOffset(touch, start, end)) {
        _isGestureInsideImageFrame = true;
        int index = _listFrameTemp
            .map(
              (e) => e.id,
            )
            .toList()
            .indexOf(_selectFrameTemp!.id);
        _onScaleStart(details, index);
      } else {
        //delete image
        var checkStart = start.translate(
            _listFrameTemp[indexSelected].width / 2 - 30 / 2, -40);
        var checkEnd = checkStart.translate(30, 30);
        bool isCanDelete =
            FlutterOffsetHelpers().containOffset(touch, checkStart, checkEnd);
        if (isCanDelete) {
          _deleteSelectedImage();
        }
      }
    } else {
      _previousScaleCanvas = _scaleCanvas.toDouble();
      setState(() {});
    }
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (_selectFrameTemp != null) {
      if (_isGestureInsideImageFrame) {
        int index = _listFrameTemp
            .map(
              (e) => e.id,
            )
            .toList()
            .indexOf(_selectFrameTemp!.id);
        _onScaleUpdate(details, index);
      }
    } else {
      _scaleCanvas = _previousScaleCanvas * details.scale.toDouble();
      setState(() {});
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    setState(() {
      _isGestureInsideImageFrame = false;
    });
  }
}

class FlutterOffsetHelpers {
  bool containOffset(Offset checkOffset, Offset startOffset, Offset endOffset) {
    return (startOffset.dx <= checkOffset.dx &&
            checkOffset.dx <= endOffset.dx) &&
        (startOffset.dy <= checkOffset.dy && checkOffset.dy <= endOffset.dy);
  }
}
