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
              File imgFile = SelectorController.imageFileQueue.get()[index];
              return _ConveyorBox(imgFile: imgFile);
            },
            addAutomaticKeepAlives: false,
            childCount: SelectorController.imageFileQueue.get().length,
          ),
        )
      ],
    );
  }
}

class _ConveyorBox extends StatefulWidget {
  const _ConveyorBox({
    Key? key,
    required this.imgFile,
  }) : super(key: key);

  final File imgFile;

  @override
  State<_ConveyorBox> createState() => _ConveyorBoxState();
}

class _ConveyorBoxState extends State<_ConveyorBox> {
  FocusNode? _focusNode;

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        focusNode: _focusNode,
        style: ElevatedButton.styleFrom(
          shape: const BeveledRectangleBorder(),
        ),
        onPressed: () {
          SelectorController.setSubject(widget.imgFile);
          _focusNode!.requestFocus();
        },
        child: Image.file(widget.imgFile),
      ),
    );
  }
}
