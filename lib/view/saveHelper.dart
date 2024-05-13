import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project12/helpers/random_number.dart';

class SaveHelpers {
  Future<bool> checkPermission() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;

    if (Platform.isAndroid && androidInfo.version.sdkInt > 29) {
      PermissionStatus permissionStatus =
          await Permission.manageExternalStorage.request();
      if (permissionStatus.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      PermissionStatus permissionStatus = await Permission.storage.request();
      if (permissionStatus.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<String?> saveToLibrary(Uint8List data) async {
    try {
      if (!(await checkPermission())) {
        return null;
      }
      String originalPath = "/storage/emulated/0/Pictures";
      final outPath = "$originalPath/IMAGE_${randomInt()}.jpg";
      File file = await File(outPath).writeAsBytes(data);
      String? loadMediaString = await MediaScanner.loadMedia(path: outPath);
      print("result from onSaveToLibrary: ${file.path} - ${loadMediaString}");
      return outPath;
    } catch (e) {
      print("onSaveToLibrary error: ${e}");
    }
    return null;
  }
 
  
  // Future<bool> onSaveToFile(File? file, String fileName) async {
  // if (file != null) {
  //   final pickedDirectory = await FlutterFileDialog.pickDirectory();
  //   if (pickedDirectory != null) {
  //     await FlutterFileDialog.saveFileToDirectory(
  //       directory: pickedDirectory,
  //       data: file.readAsBytesSync(),
  //       mimeType: "video/*",
  //       fileName: fileName,
  //       replace: true,
  //     );
  //     return true;
  //   } else {
  //     return false;
  //   }
  // } else {
  //   return false;
  // }
  // }
}
