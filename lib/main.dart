
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project12/repositories/project_realm.dart';
import 'package:project12/view/screen1.dart';
import 'package:flutter/material.dart';

void main() {
  final projectRealm = ProjectRealm();
  runApp(ProviderScope(
    child: MaterialApp(
      home: ProjectListWidget(projectRealm: projectRealm),
    ),
  ));
}
