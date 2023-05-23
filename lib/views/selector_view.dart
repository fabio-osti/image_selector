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
  late final Unlisten _unlistenPositionChanged;
  late final PhotoViewController _photoController = PhotoViewController();
  late final OverlayEntry _overlayEntry =
      OverlayEntry(builder: _optionsBuilder);

  @override
  void initState() {
    _unlistenSubjectChanged = SelectorController.listenSubjectChanged(() {
      setState(() {
        curImage = SelectorController.subjectImageFile;
      });
    });
    _unlistenPositionChanged = SelectorController.listenPositionChanged(() {
      setState(() {
        curPosition = SelectorController.selectorPosition.value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _unlistenSubjectChanged();
    _unlistenPositionChanged();
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_overlayEntry.mounted) {
        _overlayEntry.remove();
      }
      Overlay.of(context).insert(_overlayEntry);
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
  SelectorPosition curPosition = SelectorController.selectorPosition.value;

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
              _optionsSize -
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

  double get _optionsSize => min(
        max(MediaQuery.of(context).size.height / 8, 72.0),
        MediaQuery.of(context).size.width / 5,
      );

  Widget _optionsBuilder(context) {
    switch (curPosition) {
      case SelectorPosition.bottom:
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
                children: buttons,
              ),
            ),
          ),
        );
      case SelectorPosition.right:
        return Positioned(
          right: 0,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                verticalDirection: VerticalDirection.down,
                mainAxisSize: MainAxisSize.max,
                children: buttons,
              ),
            ),
          ),
        );
      case SelectorPosition.none:
        return Container();
    }
  }

  List<Widget> get buttons {
    return [
      IconButton(
        icon: const Icon(Icons.cancel_sharp),
        iconSize: _optionsSize,
        onPressed: actionSelectDelete,
        color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
        // color: const Color.fromARGB(198, 138, 0, 0),
      ),
      IconButton(
        icon: const Icon(Icons.stars_sharp),
        iconSize: _optionsSize,
        onPressed: actionSelectFavorite,
        color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
        // color: const Color.fromARGB(198, 238, 188, 29),
      ),
      IconButton(
        icon: const Icon(Icons.check_circle_sharp),
        iconSize: _optionsSize,
        onPressed: actionSelectKeep,
        color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
        // color: const Color.fromARGB(198, 0, 138, 0),
      ),
    ];
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
