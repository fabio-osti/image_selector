import 'dart:io';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_selector/controllers/selector_controller.dart';
import 'package:photo_view/photo_view.dart';

class SelectorView extends StatefulWidget {
  const SelectorView({super.key});

  @override
  State<SelectorView> createState() => _SelectorViewState();
}

class _SelectorViewState extends State<SelectorView> {
  @override
  void initState() {
    SelectorController.listenSubjectChanged(() {
      setState(() {
        curImage = SelectorController.subjectImageFile;
      });
    });
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Please set a folder to start selecting.",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          )
        : _getViewer();
  }
  final PhotoViewController _photoController = PhotoViewController();
  Widget _getViewer() {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent &&
            RawKeyboard.instance.keysPressed
                .contains(LogicalKeyboardKey.controlLeft)) {
          _photoController.scale = (_photoController.scale ?? 1) - event.scrollDelta.dy / 200; 
        }
      },
      child: PhotoView(
        imageProvider: FileImage(curImage!),
        controller: _photoController,
      ),
    );
  }

  File? curImage;
  OverlayEntry? _overlayEntry;

  Widget _getOptionsWidget() {
    // TODO: Add seetings menu to toggle between overlay and widget buttons
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
                onPressed: actionSelectDelete,
                color: const Color.fromARGB(255, 138, 0, 0),
              ),
              IconButton(
                icon: const Icon(Icons.stars_sharp),
                iconSize: min(
                  constraints.maxHeight * 0.9,
                  constraints.maxWidth / 4,
                ),
                onPressed: actionSelectFavorite,
                color: const Color.fromARGB(255, 238, 188, 29),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_sharp),
                iconSize: min(
                  constraints.maxHeight * 0.8,
                  constraints.maxWidth / 5,
                ),
                onPressed: actionSelectKeep,
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
                onPressed: actionSelectDelete,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
                // color: const Color.fromARGB(198, 138, 0, 0),
              ),
              IconButton(
                icon: const Icon(Icons.stars_sharp),
                iconSize: min(screenSize.width / 4, screenSize.height / 6),
                onPressed: actionSelectFavorite,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
                // color: const Color.fromARGB(198, 238, 188, 29),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_sharp),
                iconSize: min(screenSize.width / 5, screenSize.height / 7),
                onPressed: actionSelectKeep,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
                // color: const Color.fromARGB(198, 0, 138, 0),
              ),
            ],
          ),
        ),
      );
    });
  }

  void actionSelectKeep() {
    SelectorController.selectSubjectImageDestination("Keep");
  }

  void actionSelectFavorite() {
    SelectorController.selectSubjectImageDestination("Favorite");
  }

  void actionSelectDelete() {
    SelectorController.selectSubjectImageDestination("Delete");
  }
}
