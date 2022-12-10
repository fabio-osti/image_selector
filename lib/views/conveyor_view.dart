import 'package:flutter/material.dart';
import 'package:image_selector/controllers/selector_controller.dart';
import 'package:image_selector/helper/listenable.dart';

class ConveyorView extends StatefulWidget {
  const ConveyorView({super.key});

  @override
  State<ConveyorView> createState() => _ConveyorViewState();
}

class _ConveyorViewState extends State<ConveyorView> {
  List<Widget>? generateList() {
    return SelectorController.imageFileQueue.get().map((e) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style:
              ElevatedButton.styleFrom(shape: const BeveledRectangleBorder()),
          onPressed: () {
            SelectorController.setSubject(e);
          },
          child: Image.file(e),
        ),
      );
    }).toList();
  }

  update() {
    setState(
      () {},
    );
  }

  Unlisten? unlisten;

  @override
  void initState() {
    unlisten = SelectorController.listenQueueChanged(update);
    super.initState();
  }

  @override
  void dispose() {
    unlisten!();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: generateList() ?? []),
    );
  }
}
