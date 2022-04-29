import 'package:doc_app/pages/calendar_page.dart';
import 'package:doc_app/pages/chats_page.dart';
import 'package:doc_app/pages/doc_page.dart';
import 'package:doc_app/api/get_data.dart';
import 'package:doc_app/pages/documents.dart';
import 'package:doc_app/pages/reminder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class HomeTabs extends StatefulWidget {
  final bool fromDocPage;
  final String route;
  const HomeTabs(this.fromDocPage, this.route, {Key? key}) : super(key: key);

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> with TickerProviderStateMixin {
  var _category = getCategoryData('categories');
  final Future<dynamic>? _plannedVisits = getPlannedVisits(FirebaseAuth.instance.currentUser!.uid);
  final List<String> _stack = ['categories'];
  bool _displayBack = false;

  @override
  void initState(){
    super.initState();
    if(widget.fromDocPage == true && widget.route.isNotEmpty){
      setState(() {
        _stack.addAll(<String>['categories/1/doctors', widget.route]);
        _category = getCategoryData(_stack.last);
        _displayBack = true;
      });
    }
  }

  void _initCategories(String _newCategory) {
    _displayBack = true;
    setState(() {
      _category = getCategoryData(_newCategory);
      _stack.add(_newCategory);
    });
  }
  
  void _returnOneStep() {
    if (_stack.length > 1) {
      _stack.removeLast();
    } else if (_stack.last == 'categories') {
      return;
    }
    setState(() {
      if (_stack.length > 1) {
        _category = getCategoryData(_stack.last);
      } else {
        _category = getCategoryData('categories');
        _displayBack = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 3, vsync: this);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.1,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const <Widget>[
              Tab(
                icon: Icon(Icons.medical_services),
                text: 'Категории',
              ),
              Tab(
                icon: Icon(Icons.event_note),
                text: 'История',
              ),
              Tab(
                icon: Icon(Icons.calendar_today),
                text: 'Календарь',
              ),
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          // height: 150.0,
          height: MediaQuery.of(context).size.height * 0.575,
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              /////
              Scaffold(
              body: FutureBuilder(
                future: _category,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            "Ошибка загрузки данных.\nПожалуйста, повторите попытку позже: ${snapshot.error.toString()}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Flexible(
                          child: Text(
                            "Загрузка данных, пожалуйста, подождите..",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }
                  if (snapshot.hasData) {
                      return Column(
                        mainAxisAlignment: snapshot.data.docs.isNotEmpty ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: <Widget>[
                          _displayBack == true
                              ? IconButton(
                                  onPressed: _returnOneStep,
                                  icon: const Icon(
                                    Icons.arrow_back_sharp,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                  tooltip: 'Назад',
                                )
                              : const SizedBox(height: 0),
                        snapshot.data.docs.isNotEmpty ?
                          SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: snapshot.data!.docs
                                  .map<Widget>((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                return GestureDetector(
                                  onTap: () {
                                    if (data['is_subcat'] == null &&
                                        data['is_nestedcat'] != null &&
                                        data['is_nestedcat'] == true) {
                                      _initCategories('categories/' +
                                          data['id_category'].toString() +
                                          '/doctors');
                                    } else if (data['is_subcat'] != null &&
                                        data['is_nestedcat'] == null) {
                                      _initCategories('doctors/' +
                                          data['id_category'].toString() +
                                          '/' +
                                          data['id_category'].toString());
                                    } else if ((data['is_nestedcat'] != null &&
                                            data['is_nestedcat'] == true) ||
                                        (data['is_nestedcat'] == null)) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DocPage(
                                                'doctors/' +
                                                    data['id_category']
                                                        .toString() +
                                                    '/' +
                                                    data['id_category']
                                                        .toString(),
                                                data['id_doctor'])),
                                      );
                                    } else if (data['is_nestedcat'] != null &&
                                        data['is_nestedcat'] == false &&
                                        data['id_category'].toInt() == 2) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ChatsPage()),
                                      );
                                    } else if (data['is_nestedcat'] != null &&
                                        data['is_nestedcat'] == false &&
                                        data['id_category'].toInt() == 3) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const DocumentsPage()),
                                      );
                                    } else {
                                      null;
                                    }
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.all(12),
                                    elevation: 4,
                                    color: const Color.fromRGBO(64, 75, 96, .9),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 16),
                                      child: Row(
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 1.5),
                                                    child:
                                                    Text(data['category'],
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold)),  
                                                    ),
                                                      (data['license'] != null &&
                                                          data['license'] == 0) 
                                                      ? const Icon(Icons.av_timer, color: Colors.yellow, size: 20,)
                                                      : (data['license'] != null && 
                                                            data['license'] == 1)
                                                      ? const Icon(Icons.check, color: Colors.green, size: 20,)
                                                      : (data['license'] != null && 
                                                            data['license'] == 2)
                                                          ? const Icon(Icons.close, color: Colors.red, size: 20,)
                                                          : const SizedBox(width: 0, height: 0,)
                                                ],
                                              ),
                                              data['name'] != null &&
                                                      data['uid'] != null
                                                  ? Text(data['name'],
                                                      style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w400))
                                                  : data['name'] == null &&
                                                          data['uid'] != null
                                                      ? const Text(
                                                          'Доктор Айболит',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400))
                                                      : const SizedBox(height: 0),
                                              const SizedBox(height: 4),
                                            ],
                                          ),
                                          const Spacer(),
                                          CircleAvatar(
                                            backgroundImage: data['img'] != null && data['img'] != ""
                                            ? AssetImage('assets/images/' + data['img'])
                                            : const AssetImage('assets/images/home_img.png'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : const Text('Похоже здесь пока нет данных\n Нажмите на стрелку выше чтобы вернуться назад', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      );
                  } else {
                    return
                        // Expanded(
                        // child:
                        Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Flexible(
                          child: Text(
                            "Ошибка загрузки данных.\nПожалуйста, повторите попытку позже",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      // ),
                    );
                  }
                },
              ),
              floatingActionButton: FloatingActionButton(
                  onPressed: (() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReminderPage(),
                        ),);
                  }),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.notification_add,),
                ),),
              /////
              Scaffold(
                        body: 
              FutureBuilder(
                  future: _plannedVisits,
                  builder: (BuildContext context,
                      AsyncSnapshot snapshot) {
                    if (snapshot.hasError) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              "Ошибка загрузки данных.\nПожалуйста, повторите попытку позже: ${snapshot.error.toString()}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Flexible(
                            child: Text(
                              "Загрузка данных, пожалуйста, подождите..",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }
                    
                    if (snapshot.hasData) {
                      if(snapshot.data!.docs.isNotEmpty && (snapshot.data!.docs[0].data()['name'] != null)){
                      return ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(),
                          itemCount: snapshot.data.size,
                          itemBuilder: (context, index) {
                            var _data = snapshot.data!.docs[index].data();
                              return Card(
                                color: const Color.fromARGB(255, 0, 115, 153),
                                child: ListTile(
                                    title: Text(((_data['role'] == 'p') ? (_data['category'] + ' - ' + _data['name']) : _data['name']),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(DateTime.fromMillisecondsSinceEpoch(_data['date']).toString())).toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    leading: const CircleAvatar(
                                        backgroundImage: AssetImage(
                                            'assets/images/checklist.png')),
                                    trailing: const Icon(
                                      Icons.calendar_month,
                                      color: Colors.black,
                                    )));
                          });
                      }else{
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            Flexible(
                              child: Text(
                                'Пока что здесь пусто',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      }
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Flexible(
                            child: Text(
                              "Ошибка загрузки данных.\nПожалуйста, повторите попытку позже",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        // ),
                      );
                    }
                  }),
                  floatingActionButton: FloatingActionButton(
                    onPressed: (() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReminderPage(),
                          ),);
                    }),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.notification_add,),
                  ),),
              /////
              const CalendarPage(),
              /////
            ],
          ),
        ),
      ],
    );
  }
}