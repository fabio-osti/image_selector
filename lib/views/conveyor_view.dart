import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_selector/controllers/selector_controller.dart';

class ConveyorView extends StatelessWidget {
  const ConveyorView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              File imgFile = SelectorController.imageFileQueue.value[index];
              return _ConveyorBox(imgFile: imgFile);
            },
            addAutomaticKeepAlives: false,
            childCount: SelectorController.imageFileQueue.value.length,
          ),
        )
      ],
    );
  }
}

class _ConveyorBox extends StatelessWidget {
  const _ConveyorBox({
    Key? key,
    required this.imgFile,
  }) : super(key: key);

  final File imgFile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const BeveledRectangleBorder(),
        ),
        onPressed: () {
          SelectorController.setSubject(imgFile);
        },
        child: Image.file(imgFile),
      ),
    );
  }
}
