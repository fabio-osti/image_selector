import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_selector/controllers/selector_controller.dart';

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
          child: Container(
            margin: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Color.fromARGB(78, 158, 158, 158),
            ),
            child: curImage == null
                ? Center(
                    child: Text(
                      "Please set a folder to start selecting.",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  )
                : Image.file(curImage!),
          ),
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
                    iconSize: constraints.maxHeight*0.8,
                    onPressed: () =>
                        SelectorController.selectSubjectImageDestination(
                            "Delete"),
                    color: const Color.fromARGB(255, 138, 0, 0),
                  ),
                  IconButton(
                    icon: const Icon(Icons.stars_sharp),
                    iconSize: constraints.maxHeight*0.9,
                    onPressed: () =>
                        SelectorController.selectSubjectImageDestination(
                            "Favorite"),
                    color: const Color.fromARGB(255, 238, 188, 29),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_sharp),
                    iconSize: constraints.maxHeight*0.8,
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
