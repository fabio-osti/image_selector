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

  @override
  void initState() {
    _unlistenSubjectChanged = SelectorController.listenSubjectChanged(() {
      setState(() {});
    });
    _unlistenPositionChanged = SelectorController.listenPositionChanged(() {
      setState(() {});
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
    return SelectorController.subjectImageFile == null
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

  Widget get _viewer {
    return Focus(
      autofocus: true,
      onKey: (n, e) {
        if (e is! RawKeyUpEvent || e.repeat) return KeyEventResult.handled;
        if (kDebugMode) {
          print(e.logicalKey);
        }
        if (e.logicalKey == LogicalKeyboardKey.arrowRight ||
            e.logicalKey == LogicalKeyboardKey.keyD) {
          actionSelectKeep();
        } else if (e.logicalKey == LogicalKeyboardKey.arrowUp ||
            e.logicalKey == LogicalKeyboardKey.keyS) {
          actionSelectFavorite();
        } else if (e.logicalKey == LogicalKeyboardKey.arrowLeft ||
            e.logicalKey == LogicalKeyboardKey.keyA) {
          actionSelectDelete();
        } else if (e.logicalKey == LogicalKeyboardKey.numpad0 ||
            e.logicalKey == LogicalKeyboardKey.space) {
          SelectorController.undo();
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
            child: _viewerStack),
      ),
    );
  }

  Widget get _viewerStack {
    switch (SelectorController.buttonsPosition.value) {
      case ButtonsPosition.bottom:
        return Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height -
                  _buttonsSize(context) -
                  kToolbarHeight -
                  32,
              child: PhotoView(
                backgroundDecoration: const BoxDecoration(),
                imageProvider: FileImage(SelectorController.subjectImageFile!),
                controller: _photoController,
              ),
            ),
            _getButtons(context)
          ],
        );
      case ButtonsPosition.right:
        return Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width -
                  _buttonsSize(context) -
                  32,
              height: MediaQuery.of(context).size.height - kToolbarHeight - 32,
              child: PhotoView(
                backgroundDecoration: const BoxDecoration(),
                imageProvider: FileImage(SelectorController.subjectImageFile!),
                controller: _photoController,
              ),
            ),
            _getButtons(context)
          ],
        );
      case ButtonsPosition.none:
        return SizedBox(
          width: MediaQuery.of(context).size.width - _buttonsSize(context) - 32,
          height: MediaQuery.of(context).size.height - kToolbarHeight - 32,
          child: PhotoView(
            backgroundDecoration: const BoxDecoration(),
            imageProvider: FileImage(SelectorController.subjectImageFile!),
            controller: _photoController,
          ),
        );
    }
  }

  double _buttonsSize(BuildContext context) => min(
        128,
        SelectorController.buttonsPosition.value == ButtonsPosition.bottom
            ? min(
                max(MediaQuery.of(context).size.height / 8, 72.0),
                MediaQuery.of(context).size.width / 6,
              )
            : min(
                max(MediaQuery.of(context).size.width / 8, 72.0),
                MediaQuery.of(context).size.height / 6,
              ),
      );

  Widget _getButtons(BuildContext context) {
    final List<Widget> buttons = [
      IconButton(
        icon: const Icon(Icons.undo),
        iconSize: _buttonsSize(context),
        onPressed: SelectorController.undo,
        color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
      ),
      IconButton(
        icon: const Icon(Icons.cancel_sharp),
        iconSize: _buttonsSize(context),
        onPressed: actionSelectDelete,
        color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
        // color: const Color.fromARGB(198, 138, 0, 0),
      ),
      IconButton(
        icon: const Icon(Icons.stars_sharp),
        iconSize: _buttonsSize(context),
        onPressed: actionSelectFavorite,
        color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
        // color: const Color.fromARGB(198, 238, 188, 29),
      ),
      IconButton(
        icon: const Icon(Icons.check_circle_sharp),
        iconSize: _buttonsSize(context),
        onPressed: actionSelectKeep,
        color: Theme.of(context).iconTheme.color?.withOpacity(0.75),
        // color: const Color.fromARGB(198, 0, 138, 0),
      ),
    ];

    switch (SelectorController.buttonsPosition.value) {
      case ButtonsPosition.bottom:
        return Center(
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
        );
      case ButtonsPosition.right:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              verticalDirection: VerticalDirection.up,
              mainAxisSize: MainAxisSize.max,
              children: buttons,
            ),
          ),
        );
      case ButtonsPosition.none:
        return Container();
    }
  }

  static void actionSelectKeep() {
    SelectorController.selectSubjectImageDestination(
        SelectorController.keepDestination);
  }

  static void actionSelectFavorite() {
    SelectorController.selectSubjectImageDestination(
        SelectorController.favoriteDestination);
  }

  static void actionSelectDelete() {
    SelectorController.selectSubjectImageDestination(
        SelectorController.deleteDestination);
  }
}
