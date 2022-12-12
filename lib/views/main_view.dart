import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_selector/controllers/selector_controller.dart';
import 'package:image_selector/views/conveyor_view.dart';
import 'package:image_selector/views/selector_view.dart';
import 'package:permission_handler/permission_handler.dart';

class MainView extends StatelessWidget {
  const MainView({Key? key, required this.title}) : super(key: key);

  final String title;

  void actionChooseFolder() async {
    if (await Permission.storage.request().isGranted) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        SelectorController.setDirectory(selectedDirectory);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(onPressed: actionChooseFolder, icon: const Icon(Icons.folder)),
        ],
      ),
      body: const SelectorView(),
      drawer: const Drawer(
        child: ConveyorView(),
      ),
    );
  }
}
