import 'package:doc_app/widgets/home_tabs.dart';
import 'package:doc_app/widgets/top_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final bool fromDocPage;
  final String route;
  const HomePage(this.fromDocPage, this.route, {Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            const TopBar(),
            widget.fromDocPage == true && widget.route.isNotEmpty
              ? HomeTabs(widget.fromDocPage, widget.route)
              : const HomeTabs(false, ''),
          ],
        ),
      ),
    );
  }
}
