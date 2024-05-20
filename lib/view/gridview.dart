import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project12/helpers/image_helper.dart';
import 'package:project12/model/sub_models/image_project.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoSelectionScreen extends ConsumerStatefulWidget {
  final Function(List<ImageProject> values) onUpdateImageSelection;
  PhotoSelectionScreen({required this.onUpdateImageSelection});
  @override
  _PhotoSelectionScreenState createState() => _PhotoSelectionScreenState();
}

class _PhotoSelectionScreenState extends ConsumerState<PhotoSelectionScreen> {
  List<ImageProject> _listImage = [];
  List<AssetPathEntity> _albumList = [];
  AssetPathEntity? _selectedAlbum;
  List<ImageProject> _selectedPhotos = [];
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _fetchAlbums();
    _scrollController.addListener(() async {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent) {
        print("_listImage ${_listImage.length}");
        List<ImageProject> listImage = [];

        var listAssetsEntity = await VideoHelpers()
            .getVideosByAlbum(_selectedAlbum!, _albumList, _listImage.length);
        for (var i = 0; i < listAssetsEntity.length; i++) {
          var file = await listAssetsEntity[i].file;
          if (file != null) {
            listImage.add(ImageProject(file: file));
          }
        }
        _listImage.addAll(List.from(listImage));
        setState(() {});
      }
    });
    PhotoManager.addChangeCallback(changeNotify);
    PhotoManager.startChangeNotify();
  }

  @override
  void dispose() {
    super.dispose();
    PhotoManager.removeChangeCallback(changeNotify);
    PhotoManager.stopChangeNotify();
  }

  void changeNotify(MethodCall call) async {
    dynamic args = call.arguments;
    var type = args["type"];

    if (type != null && ["insert", "delete"].contains(type)) {
      print("type ${type}");
      // var listAssetsEntity =
      //     await VideoHelpers().getVideosByAlbum(_selectedAlbum!, _albumList, 0);
      // for (var i = 0; i < listAssetsEntity.length; i++) {
      //   var file = await listAssetsEntity[i].file;
      //   if (file != null &&
      //       !_listImage.map((e) => e.file).toList().contains(file)) {
      //     _listImage.add(ImageProject(file: file));
      //   }
      // }
      // setState(() {});

      //  updateImageProject();
    }
  }

  Future<void> _fetchAlbums() async {
    var isDenied;
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt <= 32) {
      isDenied = await Permission.storage.isDenied;
    } else {
      isDenied = await Permission.photos.isDenied;
    }
    if (isDenied) {
      PermissionStatus isGranted;
      if (androidInfo.version.sdkInt <= 32) {
        isGranted = (await Permission.storage.request());
      } else {
        isGranted = await Permission.photos.request();
      }

      if (isGranted.isGranted) {
        var abc = await VideoHelpers().getVideoAlbums();
        _albumList = abc;
        _selectedAlbum = abc.firstOrNull;
        updateImageProject();
      }
    } else {
      var abc = await VideoHelpers().getVideoAlbums();

      setState(() {
        _albumList = abc;
        _selectedAlbum = abc.firstOrNull;
      });
      updateImageProject();
    }
  }

  Future<void> updateImageProject() async {
    if (_selectedAlbum != null) {
      List<AssetEntity> listImage = [];
      _listImage = [];
      print("listAssetsEntity before");
      var listAssetsEntity = await VideoHelpers()
          .getVideosByAlbum(_selectedAlbum!, _albumList, _listImage.length);
      print("listAssetsEntity after");

      for (var i = 0; i < listAssetsEntity.length; i++) {
        listImage.add(listAssetsEntity[i]);
      }
      // handleUpdateListImage();
      for (var i = 0; i < listImage.length; i++) {
        var file = await listImage[i].file;
        if (file != null) {
          _listImage.add(ImageProject(file: file));
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: Container(
          color: Colors.white,
          width: 400,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Back',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _addImages,
            child: Container(
              color: Colors.transparent,
              width: 50,
              margin: EdgeInsets.only(right: 10),
              child: Text(
                "Add",
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildAlbumDropdown(),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              controller: _scrollController,
              itemCount: _listImage.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      var indexImage = _selectedPhotos
                          .map((e) => e.file.path)
                          .toList()
                          .indexOf(_listImage[index].file.path);
                      if (indexImage != -1) {
                        _selectedPhotos.removeAt(indexImage);
                      } else {
                        _selectedPhotos.add(_listImage[index]);
                      }
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.file(
                        _listImage[index].file,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      if (_selectedPhotos
                          .map((e) => e.file.path)
                          .toList()
                          .contains(_listImage[index].file.path))
                        Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.blue, width: 3.0)),
                        )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumDropdown() {
    return DropdownButton<AssetPathEntity>(
      value: _selectedAlbum,
      onChanged: (newValue) {
        setState(() {
          _selectedAlbum = newValue;
          if (_selectedAlbum != null) {
            updateImageProject();
            setState(() {});
          }
        });
      },
      items: _albumList.map((album) {
        return DropdownMenuItem<AssetPathEntity>(
          value: album,
          child: Text(album.name),
        );
      }).toList(),
    );
  }

  Future<void> _addImages() async {
    widget.onUpdateImageSelection(_selectedPhotos);
    Navigator.of(context).pop();
    
  }
}
