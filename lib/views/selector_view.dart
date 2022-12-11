import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_selector/controllers/selector_controller.dart';
import 'package:photo_view/photo_view.dart';

class SelectorView extends StatefulWidget {
  const SelectorView({super.key});

  @override
  State<SelectorView> createState() => _SelectorViewState();
}

class _SelectorViewState extends State<SelectorView> {
  File? curImage;

  updateImage() {
    setState(() {
      curImage = SelectorController.subjectImageFile;
    });
  }

  @override
  void initState() {
    SelectorController.listenSubjectChanged(updateImage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 5,
          child: curImage == null
              ? Center(
                  child: Text(
                    "Please set a folder to start selecting.",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                )
              : PhotoView(imageProvider: FileImage(curImage!)),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LayoutBuilder(
              builder: (context, constraints) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                verticalDirection: VerticalDirection.down,
                mainAxisSize: MainAxisSize.max,
                children: [
                  IconButton(
                    icon: const Icon(Icons.cancel_sharp),
                    iconSize: min(
                      constraints.maxHeight * 0.8,
                      constraints.maxWidth / 5,
                    ),
                    onPressed: () =>
                        SelectorController.selectSubjectImageDestination(
                            "Delete"),
                    color: const Color.fromARGB(255, 138, 0, 0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.stars_sharp),
                    iconSize: min(
                      constraints.maxHeight * 0.9,
                      constraints.maxWidth / 4,
                    ),
                    onPressed: () =>
                        SelectorController.selectSubjectImageDestination(
                            "Favorite"),
                    color: const Color.fromARGB(255, 238, 188, 29),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_sharp),
                    iconSize: min(
                      constraints.maxHeight * 0.8,
                      constraints.maxWidth / 5,
                    ),
                    onPressed: () =>
                        SelectorController.selectSubjectImageDestination(
                            "Keep"),
                    color: const Color.fromARGB(255, 0, 138, 0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
