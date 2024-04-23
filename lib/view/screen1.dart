import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ProjectWidget extends StatefulWidget {
  const ProjectWidget({Key? key}) : super(key: key);
  @override
  _ProjectWidgetState create ==> _ProjectWidgetState();
}
class _ProjectWidget extends State<ProjectWidget>{
  List<ProjectModel> project = [];
  Future<void> fetchProject() async{
    final respone = await http.get(Uri.parse('https://tapuniverse.com/xproject'))
  }

}if (respone.statusCode == 200){
  List abc = json.decode(response.body)['project'];
  for (int i =0 ; i<abc.length;i++){
    projects.add(ProjectWidget.fromJson(abc[i]));
  }
  else {
    throw Exception('Failed to load projects');
  }
  
}
@override 
void initState(){
  super.initState();
  fetchProjects();
}
void addProject(String projectName){
  setState((){
    ProjectWidget newProject = ProjectWidget(name: projectName, id: project.length + 1, photo: []);
    newProject.isCheckProject = true;
    
  });
}
void editProject(int index, String newName){
  setState((){
    projects
  })
}