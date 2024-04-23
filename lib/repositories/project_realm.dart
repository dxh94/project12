import 'dart:developer';
import 'package:project12/model/sub_models/frame_model.dart';
import 'package:project12/model/sub_models/photo_model.dart';
import 'package:project12/model/sub_models/project.dart';
import 'package:realm/realm.dart';

class ProjectRealm {
  late Realm realm;

  ProjectRealm() {
    var config = Configuration.local([
      ProjectModel.schema,
      Photos.schema,
      Frame.schema,
    ], schemaVersion: 2);
    realm = Realm(config);
  }

  // CREATE
  ProjectModel? addProject(Realm realm, ProjectModel projectModel) {
    final extieditem = getProjectById(realm, projectModel.id);
    if (extieditem != null) {
      return null;
    }
    return realm.write<ProjectModel>(() {
      return realm.add<ProjectModel>(projectModel);
    });
  }

  // READ
  List<ProjectModel> getProjects(Realm realm) {
    final items = realm.all<ProjectModel>();
    List<ProjectModel> results = [];
    for (var item in items) {
      results.add(item);
      print(item.id.toString());
    }
    return results;
  }

  ProjectModel? getProjectById(Realm realm, int id) {
    return realm.find<ProjectModel>(id);
  }

  //UPDATE
  ProjectModel updateProject(Realm realm, ProjectModel projectModel) {
    bool isHasItem = false;
    List<ProjectModel> allProject = getProjects(realm);
    for (int i = 0; i < allProject.length; i++) {
      if (allProject[i].id == projectModel.id) {
        isHasItem = true;
      }
    }
    return realm.write<ProjectModel>(() {
      print("updateProject has Item");
      return realm.add<ProjectModel>(projectModel, update: isHasItem);
    });
  }

  // DELETE
  ProjectModel deleteProject(Realm realm, ProjectModel projectModel) {
    log("delte project: $realm");
    bool isHasItem = false;
    int index = -1;
    List<ProjectModel> allProject = getProjects(realm);
    for (int i = 0; i < allProject.length; i++) {
      if (allProject[i].id == projectModel.id) {
        isHasItem = true;
        index = i;
        break;
      }
    }
    if (isHasItem && index != -1) {
      realm.write(() {
        realm.delete<ProjectModel>(allProject[index]);
      });
    }
    return projectModel;
  }
}