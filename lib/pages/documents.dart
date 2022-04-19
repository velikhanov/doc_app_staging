import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doc_app/api/get_data.dart';
import 'package:doc_app/api/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  
  bool _isFirstPage = true;
  var _allDocs = getDocuments(FirebaseAuth.instance.currentUser!.uid, true);

  Future _showAttachment(String _url, bool isImg) async {
      return await showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel:
                  MaterialLocalizations.of(context).modalBarrierDismissLabel,
              barrierColor: Colors.black45,
              transitionDuration: const Duration(milliseconds: 200),
              pageBuilder: (BuildContext buildContext, Animation animation,
                  Animation secondaryAnimation) {
                
              if(isImg == true){
                return SafeArea(
                  child: Material(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(_url),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          onPressed: (() => Navigator.pop(context)), 
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white,),
                        ),
                      ),
                    ),
                  ),
                );
              }else{
                return SafeArea(
                  child:  Material(
                    child: Stack(
                      children: [
                        SfPdfViewer.network(_url),
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            onPressed: (() => Navigator.pop(context)), 
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.black,),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Color.fromARGB(255, 177, 191, 200),
        child: Stack(
    children: [
      Padding(
          padding: const EdgeInsets.only(top: 50, left: 10, right: 10, bottom: 10),
          child: 
    FutureBuilder(
      future: _allDocs,
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
          if(_isFirstPage == true && snapshot.data.isNotEmpty){
            return ListView.separated(
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(),
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                var _data = snapshot.data![index];
                  return Card(
                    color: const Color.fromARGB(255, 0, 115, 153),
                    child: ListTile(
                        onTap: (() => setState(() {
                        _isFirstPage = false;
                        _allDocs = getDocuments(FirebaseAuth.instance.currentUser!.uid, false, email: _data);
                      })),
                        title: Text(_data,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        // subtitle: Text(_data['date'],
                        // subtitle: ,
                            // style: const TextStyle(
                            //     fontWeight: FontWeight.bold)),
                        leading: const CircleAvatar(
                            backgroundImage: AssetImage(
                                'assets/images/checklist.png')),
                        // trailing: Icon(Icons.access_time_filled, color: Colors.black,)));
                        trailing: const Icon(
                          Icons.document_scanner,
                          color: Colors.black,
                        ),),
                    );
              });
          }else if(_isFirstPage == false && snapshot.data.isNotEmpty){
            return GridView.count(
              physics: const ScrollPhysics(),
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this produces 2 rows.
              crossAxisCount: 3,
              // Generate 100 widgets that display their index in the List.
              children: List.generate(snapshot.data.length, (index) {
                var _data = snapshot.data[index];
                var attachment = Storage().getImg(FirebaseAuth.instance.currentUser!.uid + '/' + _data['member_2'] + '/' + _data['attachment']);
                  return FutureBuilder(
                    future: attachment,
                    builder: (BuildContext context,
                        AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        return const SizedBox(
                          height: 90,
                          width: 90,
                          child:
                          Center(child:  Text(
                            "Ошибка загрузки..",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 90,
                          width: 90,
                          child:
                          Center(child:  Text(
                            "Загрузка данных..",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasData){
                        var _data = snapshot.data;
                        return Column(
                          children: [
                            const SizedBox(height: 2.5,),
                            _data.toString().isNotEmpty && _data.toString().contains('.pdf') ?
                              SizedBox(
                                  height: 90,
                                  width: 90,
                                  child: IconButton(
                                    onPressed: (() => _showAttachment(_data, false)), 
                                    icon: const Icon(Icons.picture_as_pdf, color: Colors.black, size: 90,)),
                                      

                              )
                              : Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  image: DecorationImage(image: NetworkImage(_data), fit: BoxFit.cover),
                                ),
                                child: TextButton(
                                  onPressed: (() => _showAttachment(_data, true)),
                                  child: const SizedBox(),
                                ),
                              ),
                            const SizedBox(height: 2.5,)
                          ],
                        );
                      }else{
                        return const SizedBox(
                          height: 90,
                          width: 90,
                          child:
                          Center(child:  Text(
                            "Ошибка загрузки..",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                    }
                  );
              }),
            );
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
      }
    ),
      ),
     Align(
        alignment: Alignment.topLeft,
        child: 
          IconButton(
            onPressed: (() => Navigator.pop(context)),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
      ),
    ],
        ),
      ),
    );
  }
}