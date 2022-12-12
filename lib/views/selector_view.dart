import 'dart:io';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_selector/controllers/selector_controller.dart';
import 'package:image_selector/helper/listenable.dart';
import 'package:photo_view/photo_view.dart';

class SelectorView extends StatefulWidget {
  const SelectorView({super.key});

  @override
  State<SelectorView> createState() => _SelectorViewState();
}

class _SelectorViewState extends State<SelectorView> {
  late final Unlisten _unlistenSubjectChanged;
  late final PhotoViewController _photoController;
  late final OverlayEntry? _overlayEntry;

  @override
  void initState() {
    _photoController =  PhotoViewController();
    _unlistenSubjectChanged = SelectorController.listenSubjectChanged(() {
      setState(() {
        curImage = SelectorController.subjectImageFile;
      });
    });
    _overlayEntry = _getOptionsOverlay();
    super.initState();
  }

  @override
  void dispose() {
    _unlistenSubjectChanged();
    _photoController.dispose();
    super.dispose();
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
  
  File? curImage;

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
                iconSize: min(screenSize.width / 5, screenSize.height / 10),
                onPressed: actionSelectDelete,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
                // color: const Color.fromARGB(198, 138, 0, 0),
              ),
              IconButton(
                icon: const Icon(Icons.stars_sharp),
                iconSize: min(screenSize.width / 4, screenSize.height / 8),
                onPressed: actionSelectFavorite,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
                // color: const Color.fromARGB(198, 238, 188, 29),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_sharp),
                iconSize: min(screenSize.width / 5, screenSize.height / 10),
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
    SelectorController.selectSubjectImageDestination(SelectorController.keepDestination);
  }

  void actionSelectFavorite() {
    SelectorController.selectSubjectImageDestination(SelectorController.favoriteDestination);
  }

  void actionSelectDelete() {
    SelectorController.selectSubjectImageDestination(SelectorController.deleteDestination);
  }
}
