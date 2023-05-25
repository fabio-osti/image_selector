import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    builder: (buildContext) {
      const sizedBox = SizedBox(
        height: 8,
      );
      return AlertDialog(
        title: const Text("Control Panel"),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
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
                sizedBox,
                TextField(
                  decoration: const InputDecoration(
                    label: Text("Keep folder name"),
                  ),
                  controller: keepFolderTxtCtrl,
                ),
                sizedBox,
                TextField(
                  decoration: const InputDecoration(
                    label: Text("Favorite folder name"),
                  ),
                  controller: favoriteFolderTxtCtrl,
                ),
                sizedBox,
                TextField(
                  decoration: const InputDecoration(
                    label: Text("Delete folder name"),
                  ),
                  controller: deleteFolderTxtCtrl,
                ),
                sizedBox,
                const PositionDropdown(),
                //altDropdown(),
                sizedBox,
                (Platform.isAndroid || Platform.isIOS)
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: (() {
                                SystemChrome.setEnabledSystemUIMode(
                                    SystemUiMode.immersive);
                              }),
                              child: const Text("Toggle fullscreen"),
                            ),
                          ),
                          sizedBox
                        ],
                      )
                    : Container()
              ],
            ),
          ),
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
              SelectorController.favoriteDestination =
                  favoriteFolderTxtCtrl.text;
              SelectorController.deleteDestination = deleteFolderTxtCtrl.text;
              SelectorController.setDirectory(selectionDirectoryTxtCtrl.text);
              Navigator.of(context).pop();
            },
            child: const Text("Ok"),
          ),
        ],
      );
    },
  );
}

DropdownMenu<ButtonsPosition> altDropdown() {
  return DropdownMenu(
                inputDecorationTheme: const InputDecorationTheme(),
                textStyle: const TextStyle(),
                menuStyle: const MenuStyle(),
                width: 400,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(
                    value: ButtonsPosition.bottom,
                    label:"Bottom",
                  ),
                  DropdownMenuEntry(
                    value: ButtonsPosition.right,
                    label:"Right",
                  ),
                  DropdownMenuEntry(
                    value: ButtonsPosition.none,
                    label:"None",
                  )
                ],
                label: const Text("Options postion"),
                initialSelection: SelectorController.buttonsPosition.value,
                onSelected: (ButtonsPosition? pos) {
                  SelectorController.buttonsPosition.value =
                      pos ?? ButtonsPosition.bottom;
                },
              );
}

class PositionDropdown extends StatefulWidget {
  const PositionDropdown({
    super.key,
  });

  @override
  State<PositionDropdown> createState() => _PositionDropdownState();
}

class _PositionDropdownState extends State<PositionDropdown> {
  ButtonsPosition _value = SelectorController.buttonsPosition.value;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      decoration: const InputDecoration(label: Text("Options position")),
      isExpanded: true,
      items: const [
        DropdownMenuItem(
          value: ButtonsPosition.bottom,
          child: Text("Bottom"),
        ),
        DropdownMenuItem(
          value: ButtonsPosition.right,
          child: Text("Right"),
        ),
        DropdownMenuItem(
          value: ButtonsPosition.none,
          child: Text("None"),
        )
      ],
      value: _value,
      onChanged: (ButtonsPosition? pos) {
        SelectorController.buttonsPosition.value =
            pos ?? ButtonsPosition.bottom;
        setState(() {
          _value = SelectorController.buttonsPosition.value;
        });
      },
    );
  }
}

void _chooseFolder(TextEditingController controller) async {
  if (await Permission.storage.request().isGranted) {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      controller.text = selectedDirectory;
    }
  }
}
