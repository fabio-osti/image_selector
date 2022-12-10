import 'dart:io';
import 'dart:math';
import 'package:image_selector/helper/listenable.dart';
import 'package:path/path.dart' as p;

class SelectorController {
  static String keepDestination = "Keep";
  static String favoriteDestination = "Favorite";
  static String deleteDestination = "Delete";
  static List<String> otherDestinations = List.empty(growable: true);
  static Directory? selectionDir;
  static final List<File> _alreadyProcessed = List.empty(growable: true);
  
  static initDestiationDir(String dir) {
    final optionDir = Directory(p.join(SelectorController.selectionDir!.path, dir));
    optionDir.createSync();
    _alreadyProcessed.addAll(optionDir.listSync().whereType<File>());
  }

  static setDirectory(String path) {
    selectionDir = Directory(path);
    imageFileQueue.update(
      (q) {
        initDestiationDir(SelectorController.keepDestination);
        initDestiationDir(SelectorController.favoriteDestination);
        initDestiationDir(SelectorController.deleteDestination);

        for (var opt in otherDestinations) {
          initDestiationDir(opt);
        }

        q.clear();
        q.addAll(selectionDir!.listSync(recursive: false).whereType<File>().where(
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
    _subjectImageFileIndex.set(0);
  }

  static final ImutableListenable<List<File>> imageFileQueue =
      ImutableListenable<List<File>>(List<File>.empty(growable: true));

  static final MutableListenable<int> _subjectImageFileIndex =
      MutableListenable<int>(0);

  static File? get subjectImageFile =>
      imageFileQueue.get()[_subjectImageFileIndex.get()];

  static setSubject(File sbj) {
    _subjectImageFileIndex.set(imageFileQueue.get().indexOf(sbj));
  }

  static selectSubjectImageDestination(String destination) {
    if (subjectImageFile != null && selectionDir != null) {
      var destinationDir = Directory(p.join(
        selectionDir!.path,
        destination,
      ));
      subjectImageFile!.copySync(
        p.join(destinationDir.path, p.basename(subjectImageFile!.path)),
      );
      final nextIndex =
          min(_subjectImageFileIndex.get(), imageFileQueue.get().length - 2);
      imageFileQueue.get().removeAt(_subjectImageFileIndex.get());
      _subjectImageFileIndex.set(nextIndex);
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
