import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_selector/controllers/selector_controller.dart';
import 'package:permission_handler/permission_handler.dart';

showControlPanel(BuildContext context) {
  final selectionDirectoryTxtCtrl =
      TextEditingController(text: SelectorController.subjectsDir?.path);
  final keepFolderTxtCtrl =
      TextEditingController(text: SelectorController.keepDestination);
  final favoriteFolderTxtCtrl =
      TextEditingController(text: SelectorController.favoriteDestination);
  final deleteFolderTxtCtrl =
      TextEditingController(text: SelectorController.deleteDestination);
  showDialog(
    context: context,
    builder: (buildContext) => AlertDialog(
      title: const Text("Control Panel"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(
              label: const Text("Selection directory"),
              suffixIcon: IconButton(
                onPressed: () {
                  _chooseFolder(selectionDirectoryTxtCtrl);
                },
                icon: const Icon(Icons.folder),
              ),
            ),
            controller: selectionDirectoryTxtCtrl,
            readOnly: true,
          ),
          TextField(
            decoration: const InputDecoration(label: Text("Keep folder name")),
            controller: keepFolderTxtCtrl,
          ),
          TextField(
            decoration: const InputDecoration(label: Text("Favorite folder name")),
            controller: favoriteFolderTxtCtrl,
          ),
          TextField(
            decoration: const InputDecoration(label: Text("Delete folder name")),
            controller: deleteFolderTxtCtrl,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            SelectorController.keepDestination = keepFolderTxtCtrl.text;
            SelectorController.favoriteDestination = favoriteFolderTxtCtrl.text;
            SelectorController.deleteDestination = deleteFolderTxtCtrl.text;
            SelectorController.setDirectory(selectionDirectoryTxtCtrl.text);
            Navigator.of(context).pop();
          },
          child: const Text("Ok"),
        ),
      ],
    ),
  );
}

void _chooseFolder(TextEditingController controller) async {
  if (await Permission.storage.request().isGranted) {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      controller.text = selectedDirectory;
    }
  }
}
