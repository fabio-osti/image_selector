import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_selector/controllers/selector_controller.dart';
import 'package:image_selector/views/conveyor_view.dart';
import 'package:image_selector/views/selector_view.dart';

class MainView extends StatelessWidget {
  const MainView({Key? key, required this.title}) : super(key: key);

  final String title;

  chooseFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      return;
    }

    SelectorController.setDirectory(selectedDirectory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(onPressed: chooseFolder, icon: const Icon(Icons.folder)),
        ],
      ),
      body: const SelectorView(),
      drawer: const Drawer(
        child: ConveyorView(),
      ),
    );
  }
}
