import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';


class Reminder{
    Future<String> get _localPath async {
      final directory = await getApplicationDocumentsDirectory();
      
      return directory.path;
    }

    Future<File> get _localFile async {
      final path = await _localPath;
      return File(path + '/' + FirebaseAuth.instance.currentUser!.uid + '.json');
    }

    Future<File> writeJson(int id, String text, String desc, String time/*, int interval*/) async {
      final file = await _localFile;
      final decodedJson = await json.decode(await file.readAsString());
      decodedJson[(id > 0 ? id - 1 : 0).toString()] = {'id': id, 'text': text, 'desc': desc, 'time': time/*, 'interval': interval*/};
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

    Future<File> createJson() async {
      final file = await _localFile;

      await file.create();

      Map result = {"count": 0};

      return await file.writeAsString(json.encode(result));
    }

    Future<void> deleteJson() async {
      try {
        final file = await _localFile;

        // Read the file
      await file.delete();
        // return await json.decode(contents);
      } catch (e) {
        // If encountering an error, return 0
        return;
      }
    }
 }
   