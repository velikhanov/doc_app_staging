import 'package:flutter/material.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
    return Material(
      child: PagedVerticalCalendar(
        /// customize the month header look by adding a week indicator
        monthBuilder: (context, month, year) {
          return Column(
            children: [
              /// create a customized header displaying the month and year
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                margin: const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 10),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: Text(
                  DateFormat.yMMM('ru').format(DateTime(year, month))[0].toUpperCase() + DateFormat.yMMM('ru').format(DateTime(year, month)).substring(1),
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    color: Colors.white,
                    fontSize: 20
                  ),
                ),
              ),

              /// add a row showing the weekdays
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    weekText('Пн'),
                    weekText('Вт'),
                    weekText('Ср'),
                    weekText('Чт'),
                    weekText('Пт'),
                    weekText('Сб'),
                    weekText('Вс'),
                  ],
                ),
              ),
            ],
          );
        },

        /// added a line between every week
        dayBuilder: (context, date) {
          return Column(
            children: [
              DateFormat('d').format(date) == DateFormat('d').format(DateTime.now()) 
              ? Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    color: Colors.black,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: 
                Text(
                  DateFormat('d').format(date),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              )
              : Text(
                  DateFormat('d').format(date),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              const Divider(),
            ],
          );
        },
      ),
    );
  }

  Widget weekText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, right: 4, left: 4, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey, 
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
