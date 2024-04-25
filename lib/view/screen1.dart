import 'dart:convert';
import 'package:project12/helpers/convert.dart';
import 'package:project12/helpers/random_number.dart';
import 'package:project12/model/sub_models/project.dart';
import 'package:project12/repositories/project_realm.dart';
import 'package:project12/view/screen2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProjectListWidget extends StatefulWidget {
  final ProjectRealm projectRealm;
  ProjectListWidget({Key? key, required this.projectRealm}) : super(key: key);
  @override
  _ProjectListWidgetState createState() => _ProjectListWidgetState();
}

class _ProjectListWidgetState extends State<ProjectListWidget> {
  List<ProjectModel> projects = [];

  Future<void> fetchProjects() async {
    final listProjectsOnRealm =
        widget.projectRealm.getProjects(widget.projectRealm.realm);
    if (widget.projectRealm.getProjects(widget.projectRealm.realm).isEmpty) {
      final response =
          await http.get(Uri.parse('https://tapuniverse.com/xproject'));
      if (response.statusCode == 200) {
        List abc = json.decode(response.body)['projects'];
        for (int i = 0; i < abc.length; i++) {
          ProjectModel item =
              FlutterConvert().convertJsonToProjectModel(abc[i]);
          projects.add(item);
          widget.projectRealm.addProject(widget.projectRealm.realm, item);
          ProjectRealm().addProject(widget.projectRealm.realm, item);
        }
        setState(() {});
      } else {
        throw Exception('Failed to load projects');
      }
    } else {
      projects = List.from(listProjectsOnRealm);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  void addProject(String projectName) {
    final newProject =
        ProjectModel(randomInt(), randomDouble(), projectName, true);
    setState(() {
      projects.add(newProject);
    });
    widget.projectRealm.addProject(widget.projectRealm.realm, newProject);
  }

  void removeProject(int index) {
    final projectModel = projects[index];
    setState(() {
      projects.removeAt(index);
    });
    widget.projectRealm.deleteProject(widget.projectRealm.realm, projectModel);
  }

  void editProject(int index, String newName) {
    setState(() {
      projects[index].name = newName;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("projects ${projects}");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project List'),
        actions: [
          IconButton(
              onPressed: () {
                widget.projectRealm.getProjects(widget.projectRealm.realm);
              },
              icon: const Icon(Icons.abc))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(projects[index].id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    removeProject(index);
                  },
                  background: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(
                      Icons.remove,
                      color: Colors.black,
                    ),
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(projects[index].name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDetailsScreen(
                              projectRealm: widget.projectRealm,
                              projectId: projects[index].id,
                              projects: projects,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Add Project'),
                      content: TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Project Name',
                        ),
                        onSubmitted: (String value) {
                          addProject(value);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Add Project',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
