import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

class VideoHelpers {
  Future<List<AssetPathEntity>> getVideoAlbums() async {
    print("getVideoAlbums begin");
    List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      // hasAll: true,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(ignoreSize: true),
        ),
      ),
    );
    print("getVideoAlbums end ${albums}");
    return albums;
  }

  Future<List<AssetEntity>> getVideosByAlbum(
      AssetPathEntity album, List<AssetPathEntity> listAlbums) async {
    List<AssetEntity> listImage = [];
    print("getVideosByAlbum album ${album}");
    AssetPathEntity? checkEntity =
        listAlbums.where((element) => element.id == album.id).firstOrNull;
    print("getVideosByAlbum checkEntity ${checkEntity}");

    if (checkEntity != null) {
      int end = await album.assetCountAsync;
      if (end == 0) {
        return listImage;
      }
      List<AssetEntity> assets = await checkEntity.getAssetListRange(
          start: 0, end: await checkEntity.assetCountAsync);
      // assets  = assets.where((element) => element.mimeType==)
      for (int i = 0; i < assets.length; i++) {
        String mimeType = assets[i].mimeType ?? "";
        if (mimeType.startsWith("image")) {
          Uint8List? thumb = await assets[i].thumbnailData;
          listImage.add(assets[i]);
        }
      }
      print("getVideosByAlbum ${listImage.length}");
      return listImage;
    } else {
      return [];
    }
  }
}