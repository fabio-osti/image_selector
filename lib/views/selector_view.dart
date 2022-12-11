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

  OverlayEntry? _overlayEntry;

  updateImage() {
    setState(() {
      curImage = SelectorController.subjectImageFile;
    });
  }

  @override
  void initState() {
    SelectorController.listenSubjectChanged(updateImage);
    _overlayEntry = _getOptionsOverlay();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry!.mounted) {
        _overlayEntry!.remove();
      }
      Overlay.of(context)!.insert(_overlayEntry!);
    });
    return curImage == null
        ? Center(
            child: Text(
              "Please set a folder to start selecting.",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          )
        : PhotoView(imageProvider: FileImage(curImage!));
  }

  Widget _getOptionsWidget() {
    return Flexible(
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
                    SelectorController.selectSubjectImageDestination("Delete"),
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
                    SelectorController.selectSubjectImageDestination("Keep"),
                color: const Color.fromARGB(255, 0, 138, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  OverlayEntry _getOptionsOverlay() {
    return OverlayEntry(builder: (context) {
      final screenSize = MediaQuery.of(context).size;
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            verticalDirection: VerticalDirection.down,
            mainAxisSize: MainAxisSize.max,
            children: [
              IconButton(
                icon: const Icon(Icons.cancel_sharp),
                iconSize: min(screenSize.width / 5, screenSize.height / 7),
                onPressed: () =>
                    SelectorController.selectSubjectImageDestination("Delete"),
                color: const Color.fromARGB(255, 138, 0, 0),
              ),
              IconButton(
                icon: const Icon(Icons.stars_sharp),
                iconSize: min(screenSize.width / 4, screenSize.height / 6),
                onPressed: () =>
                    SelectorController.selectSubjectImageDestination(
                        "Favorite"),
                color: const Color.fromARGB(255, 238, 188, 29),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_sharp),
                iconSize: min(screenSize.width / 5, screenSize.height / 7),
                onPressed: () =>
                    SelectorController.selectSubjectImageDestination("Keep"),
                color: const Color.fromARGB(255, 0, 138, 0),
              ),
            ],
          ),
        ),
      );
    });
  }
}
