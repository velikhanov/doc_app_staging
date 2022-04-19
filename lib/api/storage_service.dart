
import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Storage{
  final storage = FirebaseStorage.instance;

  Future<void> uploadFile(
    String filePath,
    String fileName
  ) async{
    File file = File(filePath);

    try{
      await storage.ref(fileName).putFile(file);
    } on FirebaseException catch(e){
      inspect(e);
    }
  }

  Future<String> getImg(String filePath) async{
    return await storage.ref(filePath).getDownloadURL();
  }
}