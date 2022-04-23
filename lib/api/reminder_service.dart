import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';


class Reminder{
    Future<String> get _localPath async {
      final directory = await getApplicationDocumentsDirectory();
      inspect(directory.path);
      return directory.path;
    }

    Future<File> get _localFile async {
      final path = await _localPath;
      return File('$path/reminder.json');
    }

    Future<File> writeJson() async {
      final file = await _localFile;
      final String response = await rootBundle.loadString('assets/reminder.json');
      // Write the file
      return file.writeAsString(response);
    }

    Future<int> readJson() async {
      try {
        final file = await _localFile;

        // Read the file
        final contents = await file.readAsString();

        return await json.decode(contents);
      } catch (e) {
        // If encountering an error, return 0
        return 0;
      }
    }

    // Future<Map> readJson() async {
    //   final String response = await rootBundle.loadString('assets/reminder.json');
    //   final data = await json.decode(response);
    //   return await data;
    // }

    // Future<void> writeJson() async {
    //   final String response = await rootBundle.loadString('assets/reminder.json');
    //   final data = await json.decode(response);
    //   // ... 
    // }

    // Future<void> updateJson() async{
    //   final String response = await rootBundle.loadString('assets/reminder.json');
    // }

    // Future<void> deleteFromJson(int id) async{
    //   final String response = await rootBundle.loadString('assets/reminder.json');
    //   // final data = await json.decode(response)[id.toString()];
    //   final data = await json.decode(response).remove(id.toString());
    //   // var file = await File('reminder.json').writeAsString(json.encode(data));
    //   file.writeAsString(json.encode(data));
      
    // }
 }
   