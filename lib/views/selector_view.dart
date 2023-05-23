import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
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
  late final OverlayEntry _optionsOverlay =
      OverlayEntry(builder: _optionsBuilder);
  late final OverlayEntry _undoOverlay = OverlayEntry(builder: _undoBuilder);

  File? curImage;

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
      if (_optionsOverlay.mounted) {
        _optionsOverlay.remove();
      }
      Overlay.of(context).insert(_optionsOverlay);
      if (_undoOverlay.mounted) {
        _undoOverlay.remove();
      }
      Overlay.of(context).insert(_undoOverlay);
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

  SelectorPosition curPosition = SelectorController.selectorPosition.value;

  Widget get _viewer {
    return Focus(
      onKey: (n, e) {
        if (e is! RawKeyUpEvent) return KeyEventResult.handled;
        if (kDebugMode) {
          print(e.logicalKey);
        }
        if (e.logicalKey == LogicalKeyboardKey.arrowRight) {
          SelectorController.actionSelectKeep();
        } else if (e.logicalKey == LogicalKeyboardKey.arrowUp) {
          SelectorController.actionSelectFavorite();
        } else if (e.logicalKey == LogicalKeyboardKey.arrowLeft) {
          SelectorController.actionSelectDelete();
        } else {
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
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
      ),
    );
  }

  double get _optionsSize => min(
        max(MediaQuery.of(context).size.height / 8, 72.0),
        MediaQuery.of(context).size.width / 5,
      );

  Widget _undoBuilder(BuildContext context) {
    switch (curPosition) {
      case SelectorPosition.bottom:
        return Positioned(
          bottom: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.undo),
              iconSize: _optionsSize,
              onPressed: SelectorController.undo,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
            ),
          ),
        );
      case SelectorPosition.right:
        return Positioned(
          bottom: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.undo),
              iconSize: _optionsSize,
              onPressed: SelectorController.undo,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
            ),
          ),
        );
      case SelectorPosition.none:
        return Container();
    }
  }

  Widget _optionsBuilder(BuildContext context) {
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
                children: _buttons,
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
                verticalDirection: VerticalDirection.up,
                mainAxisSize: MainAxisSize.max,
                children: _buttons,
              ),
            ),
          ),
        );
      case SelectorPosition.none:
        return Container();
    }
  }

  late final List<Widget> _buttons = [
    IconButton(
      icon: const Icon(Icons.cancel_sharp),
      iconSize: _optionsSize,
      onPressed: SelectorController.actionSelectDelete,
      color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
      // color: const Color.fromARGB(198, 138, 0, 0),
    ),
    IconButton(
      icon: const Icon(Icons.stars_sharp),
      iconSize: _optionsSize,
      onPressed: SelectorController.actionSelectFavorite,
      color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
      // color: const Color.fromARGB(198, 238, 188, 29),
    ),
    IconButton(
      icon: const Icon(Icons.check_circle_sharp),
      iconSize: _optionsSize,
      onPressed: SelectorController.actionSelectKeep,
      color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
      // color: const Color.fromARGB(198, 0, 138, 0),
    ),
  ];

  // void actionSelectKeep() {
  //   SelectorController.selectSubjectImageDestination(
  //       SelectorController.keepDestination);
  // }

  // void actionSelectFavorite() {
  //   SelectorController.selectSubjectImageDestination(
  //       SelectorController.favoriteDestination);
  // }

  // void actionSelectDelete() {
  //   SelectorController.selectSubjectImageDestination(
  //       SelectorController.deleteDestination);
  // }
}
