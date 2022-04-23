import 'dart:async';
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:doc_app/api/reminder_service.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({Key? key}) : super(key: key);

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {

  // Reminder reminder = Reminder();

  // Future<String> data = Reminder().readJson();
  Future _createReminder() async {
    return await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          final TimeOfDay now = TimeOfDay.now();
          TimeOfDay time = now;
          int dropdownvalue = 1;
          List<int> _numbers = [
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            15,
            16,
            17,
            18,
            19,
            20,
            21,
            22,
            23,
            24
          ];

        Future<void> notify() async {
            String timezone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: AwesomeNotifications.maxID + 1,
                channelKey: 'doc_app_reminder_key_1',
                title: DateFormat.Hm().format(DateTime.now()).toString() +
                    ' , у Вас плановый прием лекарств',
                body: 'Вам необходимо принять Аналгин',
                // bigPicture: 'https://protocoderspoint.com/wp-content/uploads/2021/05/Monitize-flutter-app-with-google-admob-min-741x486.png',
                // bigPicture: '',
                // notificationLayout: NotificationLayout.BigPicture
              ),
              schedule:
                  NotificationInterval(interval: 2, timeZone: timezone, repeats: false),
            );
          }
          
          Future<void> selectTime(BuildContext context) async {
            await showTimePicker(
              context: context,
              initialTime: time,
              initialEntryMode: TimePickerEntryMode.input,
              cancelText: 'Отменить',
              helpText: 'Введите время',
              hourLabelText: 'Часы',
              minuteLabelText: 'Минуты',
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
              // onEntryModeChanged:
            ).then((value) {
              if (value != null) {
                setState(() {
                  time = value;
                });
              }
            });
          }

          return SafeArea(
            child: WillPopScope(
              onWillPop: () async => false,
              child: Material(
                color: const Color.fromARGB(200, 33, 33, 33),
                child: Padding(
                  padding: const EdgeInsets.only(top: 150, bottom: 150, left: 15, right: 15),
                  child: Container(
                    color: Colors.white,
                    height: 300,
                    child: 
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Создание напоминания',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child:
                        TextFormField(
                          // cursorColor: Theme.of(context).cursorColor,
                          cursorColor: Colors.blue,
                          // initialValue: 'Input text',
                          maxLength: 20,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.medication_liquid),
                            // labelText: 'Label text',
                            labelStyle: TextStyle(
                              color: Color(0xFF6200EE),
                            ),
                            // helperText: 'Helper text',
                            helperStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            hintText: 'Введите название',
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17.5),
                            suffixIcon: Icon(
                              Icons.check_circle,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6200EE)),
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(height: 5,),
                      // const Text('Выберите время для напоминаний', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center,),
                      StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer),
                            const Text(' Выберите вермя',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20)),
                            TextButton(
                                onPressed: () {
                                  selectTime(buildContext).then((value) {
                                    setState(() {});
                                  });
                                },
                                child: Text(
                                  (time.hour.toString() == '0'
                                          ? '00'
                                          : time.hour.toString()) +
                                      ':' +
                                      (time.minute.toString().length < 2
                                          ? '0' + time.minute.toString()
                                          : time.minute.toString()),
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                )),
                          ],
                        );
                      }),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.av_timer_outlined),
                          const Text(' Выберите интервал',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),),
                          // const SizedBox(width: 15,),
                          StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return DropdownButton(
                              value: dropdownvalue,
                              style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                              alignment: AlignmentDirectional.centerEnd,
                              dropdownColor: Colors.white,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: _numbers.map((items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items.toString()),
                                  // onTap: (){
                                  //   set
                                  // },
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                setState(() {
                                  dropdownvalue = newValue!;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                              onPressed: (() => Navigator.pop(buildContext)),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                                shape: MaterialStateProperty.resolveWith<
                                    OutlinedBorder>((_) {
                                  return RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  );
                                }),
                              ),
                              child: const Text(
                                'Отменить',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              )),
                              TextButton(
                              onPressed: (){
                                // if(AwesomeNotifications.maxID > 5){
                                //   inspect(AwesomeNotifications.maxID);
                                //   inspect('Too much notifications');
                                //   return;
                                // }
                                Timer.periodic(const Duration(minutes: 1), (timer) {
                                  if (DateTime.now()== DateTime.parse("2022-04-23 17:59:00")){
                                    timer.cancel();
                                    notify();
                                  }
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                                shape: MaterialStateProperty.resolveWith<
                                    OutlinedBorder>((_) {
                                  return RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  );
                                }),
                              ),
                              child: const Text(
                                'Создать напоминание',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                ),
            ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    inspect(Reminder().readJson());
    return SafeArea(
      child: Scaffold(
        // backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        appBar: AppBar(
          // foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          // backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          // brightness: Brightness.dark,
          centerTitle: true,
          title: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(
                    text: 'Напоминания',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),
          leading: IconButton(
            onPressed: (() => Navigator.pop(context)),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 22.5,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
          child: Center(
            child: Column(
              children: [
                // FutureBuilder(
                //   future: Reminder().readJson(),
                //   builder: (BuildContext context,
                //       AsyncSnapshot snapshot) {
                //         // inspect(snapshot.data);
                //     if (snapshot.hasData) {
                //     return ListView.separated(
                //       scrollDirection: Axis.vertical,
                //       shrinkWrap: true,
                //       separatorBuilder: (BuildContext context, int index) =>
                //           const SizedBox(),
                //       itemCount: snapshot.data['count'],
                //       itemBuilder: (context, index) {
                //         var _data = snapshot.data[index.toString()];
                //         return Card(
                //           color: const Color.fromARGB(255, 85, 0, 255),
                //           child: ListTile(
                //               title: Text(_data['title'],
                //                   style: const TextStyle(
                //                       fontWeight: FontWeight.bold, color: Colors.white)),
                //               subtitle: Text(_data['subtitle'],
                //                   style: const TextStyle(
                //                       fontWeight: FontWeight.bold, color: Colors.white)),
                //               leading: const Icon(Icons.notifications_active, color: Colors.white, size: 40),
                //               // leading: CircleAvatar(
                //               //     backgroundImage: AssetImage(
                //               //         'assets/images/reminder.png')),
                //               trailing: IconButton(
                //                 onPressed: ((){
                //                   // Reminder().deleteFromJson(1);
                //                   // AwesomeNotifications().cancelSchedule(_data['id']).then((value){

                //                   // });
                //                 }), 
                //                 // onPressed: null, 
                //                 icon: const Icon(Icons.close, color: Colors.white, size: 30,)),
                //               ));
                //     });
                //     }else{
                //       return Text('test');
                //     }
                //     }
                //   ),
                  const SizedBox(height: 10,),
                  TextButton(
                    onPressed: () {
                      _createReminder();
                      // Reminder().writeJson();
                    },
                    style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.blue),
                    shape: MaterialStateProperty.resolveWith<
                        OutlinedBorder>((_) {
                      return RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      );
                    }),
                  ),
                  child: const Text(
                        '+ Добавить напоминание',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
