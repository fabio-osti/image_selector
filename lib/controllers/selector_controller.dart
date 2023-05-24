import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image_selector/helper/listenable.dart';
import 'package:image_selector/helper/string_extension.dart';
import 'package:path/path.dart' as p;

class SelectorController {
  static String keepDestination = "Keep";
  static String favoriteDestination = "Favorite";
  static String deleteDestination = "Delete";
  static Directory? subjectsDir;

  static setDirectory([String? path]) {
    if (path.isNullOrEmpty() && subjectsDir == null) return;
    if (!path.isNullOrEmpty()) {
      subjectsDir = Directory(path!);
      if (kDebugMode) {
        print(subjectsDir!.listSync());
      }
    }

    final List<File> alreadyProcessed = List.empty(growable: true);
    initDestiationDir(String dir) {
      final optionDir =
          Directory(p.join(SelectorController.subjectsDir!.path, dir));
      optionDir.createSync();
      alreadyProcessed.addAll(optionDir.listSync().whereType<File>());
    }

    imageFileQueue.update(
      (q) {
        initDestiationDir(SelectorController.keepDestination);
        initDestiationDir(SelectorController.favoriteDestination);
        initDestiationDir(SelectorController.deleteDestination);

        q.clear();
        q.addAll(
            subjectsDir!.listSync(recursive: false).whereType<File>().where(
                  (element) =>
                      // Is image
                      imageExtensions.contains(
                        p.extension(element.path).toLowerCase(),
                      ) &&
                      // Has not been processed
                      !alreadyProcessed.any(
                        (selectedElement) =>
                            p.basename(selectedElement.path) ==
                            p.basename(element.path),
                      ),
                ));
      },
    );
    _subjectImageFileIndex.value = 0;
  }

  static final ImutableListenable<List<File>> imageFileQueue =
      ImutableListenable<List<File>>(List<File>.empty(growable: true));

  static final MutableListenable<int> _subjectImageFileIndex =
      MutableListenable<int>(0);

  static MutableListenable<SelectorPosition> selectorPosition =
      MutableListenable<SelectorPosition>(SelectorPosition.bottom);

  static File? get subjectImageFile => imageFileQueue.value.isEmpty
      ? null
      : imageFileQueue.value[_subjectImageFileIndex.value];

  static setSubject(File sbj) {
    var indexOf = imageFileQueue.value.indexOf(sbj);
    assert(indexOf != -1);
    _subjectImageFileIndex.value = indexOf;
  }

  static final List<File> _historyStack = List<File>.empty(growable: true);

  static selectSubjectImageDestination(String destination) {
    if (subjectImageFile != null && subjectsDir != null) {
      var destinationDir = Directory(p.join(
        subjectsDir!.path,
        destination,
      ));
      var newPath =
          p.join(destinationDir.path, p.basename(subjectImageFile!.path));

      var copySync = subjectImageFile!.copySync(newPath);
      _historyStack.add(copySync);

      imageFileQueue.value.removeAt(_subjectImageFileIndex.value);

      _subjectImageFileIndex.value = max(
        min(_subjectImageFileIndex.value, imageFileQueue.value.length - 2),
        0,
      );
    }
  }

  static undo() {
    if (_historyStack.isNotEmpty) {
      final lastAction = _historyStack.removeLast();
      lastAction.deleteSync();
      setDirectory();
    }
  }

  static Unlisten listenSubjectChanged(Function() listener) {
    return _subjectImageFileIndex.listen(listener);
  }

  static Unlisten listenQueueChanged(Function() listener) {
    return imageFileQueue.listen(listener);
  }

  static Unlisten listenPositionChanged(Function() listener) {
    return selectorPosition.listen(listener);
  }
}

const imageExtensions = [".jpg", ".jpeg", ".png"];

enum SelectorPosition { bottom, right, none }
