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
  Future<void> _remindersLimitNotification(String text, String type) async{
    Widget okButton = TextButton(
      child: const Text('Закрыть',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
      onPressed: () {
        if(type == 'time'){
          Navigator.of(context).pop();
        }else if(type == 'count'){
          Navigator.of(context)..pop()..pop();
        }else{
          Navigator.of(context).pop();
        }
      },
    );

    AlertDialog alert = AlertDialog(
      // title: Text("My title"),
      content: Text(text,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
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
          // final TimeOfDay now = TimeOfDay.now();
          // TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 1)));
          TimeOfDay time = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 10)));
          // int dropdownvalue = 1;
          // List<int> _numbers = [
          //   1,
          //   2,
          //   3,
          //   4,
          //   5,
          //   6,
          //   7,
          //   8,
          //   9,
          //   10,
          //   11,
          //   12,
          //   13,
          //   14,
          //   15,
          //   16,
          //   17,
          //   18,
          //   19,
          //   20,
          //   21,
          //   22,
          //   23,
          //   24
          // ];
        TextEditingController titleFormController = TextEditingController();
        TextEditingController subTitleFormController = TextEditingController();
        Future<void> notify(int id, String text, String desc, String time/*, int interval*/) async {
            // String timezone = await AwesomeNotifications().getLocalTimeZoneIdentifier();
            // TODO check this => inspect(DateTime.parse(DateTime.now().year.toString() + DateTime.now().month.toString() + DateTime.now().day.toString() + time + ':00'));
            await AwesomeNotifications().createNotification(
              content: NotificationContent(
                id: id,
                channelKey: 'doc_app_reminder_key_1',
                title: DateFormat.Hm().format(DateTime.now()).toString() + ', ' + text,
                body: desc,
              ),
              schedule:
                  // NotificationInterval(interval: 1/*interval * 60 * 60*/, timeZone: timezone, repeats: true),
                        NotificationCalendar.fromDate(date: DateTime.parse(DateTime.now().year.toString() + '-' + (DateTime.now().month.toString().length < 2 ? '0' + DateTime.now().month.toString() : DateTime.now().month.toString()) + '-' + (DateTime.now().day.toString().length < 2 ? '0' + DateTime.now().day.toString() : DateTime.now().day.toString()) + ' ' + time + ':00'), repeats: true),
            ).then((value) async{
              if(value == true){
                await Reminder().writeJson(id, text, desc, time/*, interval*/);
              }
            });
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
                          controller: titleFormController,
                          // cursorColor: Theme.of(context).cursorColor,
                          cursorColor: Colors.blue,
                          // initialValue: 'Input text',
                          maxLength: 20,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.title),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child:
                        TextFormField(
                          controller: subTitleFormController,
                          // cursorColor: Theme.of(context).cursorColor,
                          cursorColor: Colors.blue,
                          // initialValue: 'Input text',
                          maxLength: 20,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.description),
                            // labelText: 'Label text',
                            labelStyle: TextStyle(
                              color: Color(0xFF6200EE),
                            ),
                            // helperText: 'Helper text',
                            helperStyle: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                            hintText: 'Описание уведомления',
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
                      // const SizedBox(
                      //   height: 5,
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     const Icon(Icons.av_timer_outlined),
                      //     const Text(' Выберите интервал',
                      //         style: TextStyle(
                      //             color: Colors.black,
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 20),),
                      //     // const SizedBox(width: 15,),
                      //     StatefulBuilder(builder:
                      //         (BuildContext context, StateSetter setState) {
                      //       return DropdownButton(
                      //         value: dropdownvalue,
                      //         style: const TextStyle(
                      //             color: Colors.blue,
                      //             fontWeight: FontWeight.bold,
                      //             fontSize: 20),
                      //         alignment: AlignmentDirectional.centerEnd,
                      //         dropdownColor: Colors.white,
                      //         icon: const Icon(Icons.keyboard_arrow_down),
                      //         items: _numbers.map((items) {
                      //           return DropdownMenuItem(
                      //             value: items,
                      //             child: Text(items.toString()),
                      //             // onTap: (){
                      //             //   set
                      //             // },
                      //           );
                      //         }).toList(),
                      //         onChanged: (int? newValue) {
                      //           setState(() {
                      //             dropdownvalue = newValue!;
                      //           });
                      //         },
                      //       );
                      //     }),
                      //   ],
                      // ),
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
                              onPressed: () async{
                                var jsonResult = await Reminder().readJson();
                                // if(AwesomeNotifications.maxID > 5){
                                //   inspect(AwesomeNotifications.maxID);
                                //   inspect('Too much notifications');
                                //   return;
                                // }
                                // Timer.periodic(const Duration(minutes: 1), (timer) {
                                //   if (DateTime.now()== DateTime.parse("2022-04-23 17:59:00")){
                                //     timer.cancel();
                                  String notifyTime = (time.hour.toString() == '0' ? '00': time.hour.toString()) + ':' +(time.minute.toString().length < 2 ? '0' + time.minute.toString(): time.minute.toString());
                                  DateTime timeNow = DateTime.parse(DateTime.now().year.toString() + '-' + (DateTime.now().month.toString().length < 2 ? '0' + DateTime.now().month.toString() : DateTime.now().month.toString()) + '-' + (DateTime.now().day.toString().length < 2 ? '0' + DateTime.now().day.toString() : DateTime.now().day.toString()) + ' ' + notifyTime + ':00');
                                if(jsonResult.isNotEmpty && titleFormController.text.trim().isNotEmpty && subTitleFormController.text.trim().isNotEmpty && jsonResult['count'] < 5 && timeNow.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch){
                                  // await Reminder().writeJson(jsonResult['count'] + 1, titleFormController.text.trim(), subTitleFormController.text.trim())
                                  // .then((value){setState(() {});});
                                  // Navigator.pop(buildContext);
                                  notify(jsonResult['count'] + 1, titleFormController.text.trim(), subTitleFormController.text.trim(), notifyTime/*, dropdownvalue*/).then((value){
                                    setState(() {});
                                    Navigator.pop(buildContext);
                                  });
                                }else if(jsonResult.isNotEmpty && titleFormController.text.trim().isNotEmpty && subTitleFormController.text.trim().isNotEmpty && jsonResult['count'] < 5 && timeNow.millisecondsSinceEpoch < DateTime.now().millisecondsSinceEpoch){
                                  await _remindersLimitNotification('Время напоминания должно быть в будущем', 'time');
                                }else if(jsonResult.isNotEmpty && titleFormController.text.trim().isNotEmpty && subTitleFormController.text.trim().isNotEmpty && jsonResult['count'] >= 5 && timeNow.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch){
                                  await _remindersLimitNotification('Вы достигли лимита доступных напоминаний', 'count');
                                }else{
                                  await _remindersLimitNotification('Что то пошло не так, пожалуйста повторите попытку позже', 'else');
                                }
                                    // notify(jsonResult['count'] + 1, titleFormController.text.trim(), subTitleFormController.text.trim(), time, dropdownvalue);
                                //   }
                                // });
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
            child: 
                FutureBuilder(
                  future: Reminder().readJson(),
                  builder: (BuildContext context,
                      AsyncSnapshot snapshot) {
                    // if (reminderCount == null || snapshot.connectionState == ConnectionState.waiting) {
                    //   return const Text('Загрузка данных', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center,);
                    // }
                    if (snapshot.hasData) {
                      if(snapshot.data['count'] != null && snapshot.data['count'] > 0){
                        return Column(
                        children: [
                      ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(),
                          itemCount: snapshot.data['count'],
                          itemBuilder: (context, index) {
                            var _data = snapshot.data[index.toString()];
                            return Card(
                              color: const Color.fromARGB(255, 85, 0, 255),
                              child: ListTile(
                                  title: Text(_data['text'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, color: Colors.white)),
                                  subtitle: Text(_data['desc'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold, color: Colors.white)),
                                  leading: const Icon(Icons.notifications_active, color: Colors.white, size: 40),
                                  // leading: CircleAvatar(
                                  //     backgroundImage: AssetImage(
                                  //         'assets/images/reminder.png')),
                                  trailing: IconButton(
                                    onPressed: ((){
                                      Reminder().deleteFromJson(index)
                                      .then((value){
                                        setState((){
                                          AwesomeNotifications().cancelSchedule(index);
                                          AwesomeNotifications().dismiss(index);
                                        });
                                      });
                                      // AwesomeNotifications().cancelSchedule(_data['id']).then((value){

                                      // });
                                    }), 
                                    // onPressed: null, 
                                    icon: const Icon(Icons.close, color: Colors.white, size: 30,)),
                                  ));
                                }),
                                const SizedBox(height: 10,),
                            TextButton(
                              onPressed: () {
                                _createReminder();
                                // Reminder().deleteFromJson(2);
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
                            );
                      }else{
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text('У вас нет активных напоминаний', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center,),
                            const SizedBox(height: 10,),
                              TextButton(
                                onPressed: () {
                                  _createReminder();
                                  // Reminder().deleteFromJson(2);
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
                        ],);
                      }
                    }else{
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text('У вас нет активный напоминаний', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center,),
                            const SizedBox(height: 10,),
                            TextButton(
                              onPressed: () {
                                _createReminder();
                                // Reminder().deleteFromJson(2);
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
                        ],);
                    }
                    }
                  ),
          ),
        ),
      ),
    );
  }
}
