import 'package:doc_app/api/reminder_service.dart';
import 'package:doc_app/pages/reminder.dart';
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
        floatingActionButton: 
        // SizedBox(
        //   height: 100.0,
        //   width: 100.0,
        //   child: FittedBox(
        //     child: 
        Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: FloatingActionButton.extended(
            // backgroundColor: const Color(0xff03dac6),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            onPressed: (() {
              Navigator.push(
                  context,
                  // MaterialPageRoute(builder: (context) => const ChatPage(),
                  MaterialPageRoute(
                    builder: (context) => const ReminderPage(),
                  ));
                  // Reminder().writeJson();
                  // Reminder().deleteFromJson(0);
              }
            ),
            icon: const Icon(Icons.add, size: 20,),
            label: const Text('Напоминания', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),),
        ),
          //   FloatingActionButton(
          //     child: const Text('Напоминания', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          //     onPressed: (() => Navigator.push(
          //         context,
          //         // MaterialPageRoute(builder: (context) => const ChatPage(),
          //         MaterialPageRoute(
          //           builder: (context) => const ReminderPage(),
          //         ))),
          //       shape: const CircularNotchedRectangle(),
          // ),
        // ),
      // ),
    );
  }
}
