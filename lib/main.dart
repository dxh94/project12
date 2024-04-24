import 'package:project12/repositories/project_realm.dart';
import 'package:project12/view/screen1.dart';
import 'package:flutter/material.dart';

void main() {
  final projectRealm = ProjectRealm();
  runApp(MaterialApp(
    home: ProjectImage(projectRealm: projectRealm),
  ));
}
