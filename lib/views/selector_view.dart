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
  late final PhotoViewController _photoController = PhotoViewController();
  late final OverlayEntry _overlayEntry = OverlayEntry(builder: _optionsBuilder);
 
  @override
  void initState() {
    _unlistenSubjectChanged = SelectorController.listenSubjectChanged(() {
      setState(() {
        curImage = SelectorController.subjectImageFile;
      });
    });
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
      if (_overlayEntry.mounted) {
        _overlayEntry.remove();
      }
      Overlay.of(context)!.insert(_overlayEntry);
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
        : _viewer;
  }

  File? curImage;

  Widget get _viewer {
    return GestureDetector(
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent &&
              RawKeyboard.instance.keysPressed
                  .contains(LogicalKeyboardKey.controlLeft)) {
            _photoController.scale =
                (_photoController.scale ?? 1) - event.scrollDelta.dy / 200;
          }
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height -
                    optionsSize -
                    kToolbarHeight -
                    16,
          child: PhotoView(
            backgroundDecoration: const BoxDecoration(),
            imageProvider: FileImage(curImage!),
            controller: _photoController,
          ),
        ),
      ),
    );
  }

  get optionsSize => min(
    max(MediaQuery.of(context).size.height / 8, 72.0),
    MediaQuery.of(context).size.width / 5,
  );

  Widget _optionsBuilder(context) {
    return Positioned(
      bottom: 0,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            verticalDirection: VerticalDirection.down,
            mainAxisSize: MainAxisSize.max,
            children: [
              IconButton(
                icon: const Icon(Icons.cancel_sharp),
                iconSize: optionsSize,
                onPressed: actionSelectDelete,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
                // color: const Color.fromARGB(198, 138, x0, 0),
              ),
              IconButton(
                icon: const Icon(Icons.stars_sharp),
                iconSize: optionsSize,
                onPressed: actionSelectFavorite,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
                // color: const Color.fromARGB(198, 238, 188, 29),
              ),
              IconButton(
                icon: const Icon(Icons.check_circle_sharp),
                iconSize: optionsSize,
                onPressed: actionSelectKeep,
                color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
                // color: const Color.fromARGB(198, 0, 138, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void actionSelectKeep() {
    SelectorController.selectSubjectImageDestination(
        SelectorController.keepDestination);
  }

  void actionSelectFavorite() {
    SelectorController.selectSubjectImageDestination(
        SelectorController.favoriteDestination);
  }

  void actionSelectDelete() {
    SelectorController.selectSubjectImageDestination(
        SelectorController.deleteDestination);
  }
}
