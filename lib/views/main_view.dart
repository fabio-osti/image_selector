import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_selector/views/control_panel_view.dart';
import 'package:image_selector/views/conveyor_view.dart';
import 'package:image_selector/views/selector_view.dart';

class MainView extends StatelessWidget {
  const MainView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showControlPanel(context);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: const SelectorView(),
      drawer: const Drawer(
        child: ConveyorView(),
      ),
    );
  }
}
