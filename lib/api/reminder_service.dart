import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';


class Reminder{
    Future<String> get _localPath async {
      final directory = await getApplicationDocumentsDirectory();
      
      return directory.path;
    }

    Future<File> get _localFile async {
      final path = await _localPath;
      return File('$path/reminder.json');
    }

    Future<File> writeJson(int id, String text, String desc, String time/*, int interval*/) async {
      final file = await _localFile;
      // final String response = await rootBundle.loadString('assets/reminder.json');
      final decodedJson = await json.decode(await file.readAsString());
      decodedJson[(id > 0 ? id - 1 : 0).toString()] = {'id': id, 'text': text, 'desc': desc, 'time': time/*, 'interval': interval*/};
      // decodedJson[(id > 0 ? id - 1 : 0).toString()] = {'text': text};
      // decodedJson[(id > 0 ? id - 1 : 0).toString()] = {'desc': desc};
      await decodedJson.remove('count');
      decodedJson['count'] = id;
      
      // Write the file
      return await file.writeAsString(json.encode(decodedJson));
    }

    Future<File> deleteFromJson(int id) async {
      final file = await _localFile;
      final decodedJson = await json.decode(await file.readAsString());
      await decodedJson.remove(id.toString());
      if(id != 0){
        for (int i = id; i < decodedJson['count'] - 1; i++) {
          decodedJson[i.toString()] = decodedJson[(i + 1).toString()];
          decodedJson[i.toString()]['id'] = i + 1;
        }
      }
      if(id != 0){
        int count = decodedJson['count'] - 1;
        await decodedJson.remove('count');
        decodedJson['count'] = count;
      }else{
        await decodedJson.remove('count');
        decodedJson['count'] = 0;
      }

      // Write the file
      return await file.writeAsString(json.encode(decodedJson));
      // return file;
    }

    Future<Map> readJson() async {
      try {
        final file = await _localFile;

        // Read the file
        final jsonResponce = await json.decode(await file.readAsString());

      return await jsonResponce;
        // return await json.decode(contents);
      } catch (e) {
        // If encountering an error, return 0
        return {};
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
   