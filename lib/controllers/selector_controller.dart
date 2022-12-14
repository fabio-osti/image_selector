import 'dart:io';
import 'dart:math';
import 'package:image_selector/helper/listenable.dart';
import 'package:path/path.dart' as p;

class SelectorController {
  static final List<File> _alreadyProcessed = List.empty(growable: true);
  static String keepDestination = "Keep";
  static String favoriteDestination = "Favorite";
  static String deleteDestination = "Delete";
  static Directory? subjectsDir;
  
  static initDestiationDir(String dir) {
    final optionDir = Directory(p.join(SelectorController.subjectsDir!.path, dir));
    optionDir.createSync();
    _alreadyProcessed.addAll(optionDir.listSync().whereType<File>());
  }

  static setDirectory(String path) {
    if (path.isEmpty) return;
    subjectsDir = Directory(path);
    imageFileQueue.update(
      (q) {
        initDestiationDir(SelectorController.keepDestination);
        initDestiationDir(SelectorController.favoriteDestination);
        initDestiationDir(SelectorController.deleteDestination);

        q.clear();
        q.addAll(subjectsDir!.listSync(recursive: false).whereType<File>().where(
              (element) =>
                  imageExtensions.contains(
                    p.extension(element.path).toLowerCase(),
                  ) &&
                  !_alreadyProcessed.any(
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

  static File? get subjectImageFile =>
      imageFileQueue.value[_subjectImageFileIndex.value];

  static setSubject(File sbj) {
    var indexOf = imageFileQueue.value.indexOf(sbj);
    assert(indexOf != -1);
    _subjectImageFileIndex.value = indexOf;
  }

  static selectSubjectImageDestination(String destination) {
    if (subjectImageFile != null && subjectsDir != null) {
      var destinationDir = Directory(p.join(
        subjectsDir!.path,
        destination,
      ));
      subjectImageFile!.copySync(
        p.join(destinationDir.path, p.basename(subjectImageFile!.path)),
      );
      final nextIndex =
          min(_subjectImageFileIndex.value, imageFileQueue.value.length - 2);
      imageFileQueue.value.removeAt(_subjectImageFileIndex.value);
      _subjectImageFileIndex.value = nextIndex;
    }
  }

  static Unlisten listenSubjectChanged(Function() listener) {
    return _subjectImageFileIndex.listen(listener);
  }

  static Unlisten listenQueueChanged(Function() listener) {
    return imageFileQueue.listen(listener);
  }
}

const imageExtensions = [".jpg", ".jpeg", ".png"];
