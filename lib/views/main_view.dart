import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_selector/controllers/selector_controller.dart';
import 'package:image_selector/views/conveyor_view.dart';
import 'package:image_selector/views/selector_view.dart';
import 'package:permission_handler/permission_handler.dart';

class MainView extends StatelessWidget {
  const MainView({Key? key,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var horizontal = isHorizontal(context);
    return Scaffold(
      extendBodyBehindAppBar: horizontal,
      appBar: AppBar(
        backgroundColor: horizontal ? Colors.transparent : null,
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

  bool isHorizontal(BuildContext context) => MediaQuery.of(context).size.aspectRatio > 1;

  void actionChooseFolder() async {
    if (await Permission.storage.request().isGranted) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null) {
        SelectorController.setDirectory(selectedDirectory);
      }
    }
  }
}
