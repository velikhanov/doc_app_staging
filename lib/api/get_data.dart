import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Get all categories according to the user's role on the home page
getCategoryData(String _collection) async {
  QuerySnapshot<Map<String, dynamic>> _userRole = await FirebaseFirestore
      .instance
      .collection('roles')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();

  for (QueryDocumentSnapshot<Map<String, dynamic>> element in _userRole.docs) {
    if (element.data()['role'] == 'd') {
      Future<QuerySnapshot> _snapshot = FirebaseFirestore.instance
          .collection(_collection)
          .where('for_d', isEqualTo: true)
          .get();

      return _snapshot;
    } else if (element.data()['role'] == 'p') {
      Future<QuerySnapshot<Map<String, dynamic>>> _snapshot =
          FirebaseFirestore.instance.collection(_collection).get();

      return _snapshot;
    }
  }
}

// Mapping data for category selection on the registration page for doctors
getCategoriesSignUp(String _collection) {
  Future<QuerySnapshot<Map<String, dynamic>>> _snapshot =
      FirebaseFirestore.instance.collection(_collection).get();

  return _snapshot;
}
// Returns users pesonal data for editing
getUserPersonalData() async{
  QuerySnapshot<Map<String, dynamic>> _userRole = await FirebaseFirestore
      .instance
      .collection('roles')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();

  for (QueryDocumentSnapshot<Map<String, dynamic>> element in _userRole.docs) {
    if (element.data()['role'] == 'd') {
      Future<QuerySnapshot<Map<String, dynamic>>> _snapshot =
          FirebaseFirestore.instance.collection('doctors/' + element.data()['path'].toString()).where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();

      return _snapshot;
    }else if (element.data()['role'] == 'p') {
      Future<QuerySnapshot<Map<String, dynamic>>> _snapshot =
        FirebaseFirestore.instance.collection('users').where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();

      return _snapshot;
    }
  }
}

// Get doctor's details on his personal page
getDoctorData(String _collection, {int? id, bool lastId = false}) {
  if (lastId == false) {
    Future<DocumentSnapshot> _snapshot = FirebaseFirestore.instance
        .collection(_collection)
        .doc(id.toString())
        .get();

    return _snapshot;
  } else {
    Future<QuerySnapshot> _snapshot =
        FirebaseFirestore.instance.collection(_collection).get();

    return _snapshot;
  }
}

// Get user role (doctor or patient)
getUserRole(String _collection) {
  Future<QuerySnapshot> _snapshot =
      FirebaseFirestore.instance.collection(_collection).get();

  return _snapshot;
}

// Get visit history list
getPlannedVisits(String _currentUser, {bool returnAll = false, bool firstPage = false, String? docUid}) async {

  QuerySnapshot<Map<String, dynamic>> _userRole = await FirebaseFirestore
    .instance
    .collection('roles')
    .where('uid', isEqualTo: _currentUser)
    .get();

  for (QueryDocumentSnapshot<Map<String, dynamic>> element in _userRole.docs) {
    if (element.data()['role'] == 'p') {
      if(returnAll == true){
        List _checkList = [];
        List _finalList = [];
        QuerySnapshot<Map<String, dynamic>> _snapshot = await FirebaseFirestore
          .instance
          .collection('planned_visits/' + _currentUser + '/' + _currentUser)
          .orderBy('date', descending: firstPage == true ? true : false)
          .get();
          if(firstPage == true){
            for (var item in _snapshot.docs) {
              // if(!_checkList.contains(item.data()['name'] + '-' + item.data()['category'])){
              //   _checkList.add(item.data()['name'] + '-' + item.data()['category']);
              //   _finalList.add(item);
              // }
              if(!_checkList.contains(item.data()['email'])){
                _checkList.add(item.data()['email']);
                _finalList.add(item);
              }
            }
            return _finalList.reversed.toList();
          } else if(firstPage == false && docUid!.isNotEmpty){
            return await FirebaseFirestore
              .instance
              .collection('planned_visits/' + _currentUser + '/' + _currentUser)
              .where('doc_uid', isEqualTo: docUid)
              .get().then((value) => value.docs.toList());
              // .get().then((value) => value.docs.reversed.toList());
          }
      } else {
        return await FirebaseFirestore
          .instance
          .collection('planned_visits/' + _currentUser + '/' + _currentUser)
          .where('date', isGreaterThan: DateTime.now().millisecondsSinceEpoch)
          // .get().then((value) => value.docs.reversed.toList());
          .get().then((value) => value.docs.toList());
      }
    } else if (element.data()['role'] == 'd') {
      if(returnAll == true){
        List _checkList = [];
        List _finalList = [];
        QuerySnapshot<Map<String, dynamic>> _snapshot = await FirebaseFirestore
            .instance
            .collection('appointments/' + _currentUser + '/' + _currentUser)
            .orderBy('date', descending: firstPage == true ? true : false)
            .get();
          if(firstPage == true){
            for (var item in _snapshot.docs) {
              // if(!_checkList.contains(item.data()['name'])){
              //   _checkList.add(item.data()['name']);
              //   _finalList.add(item);
              // }
              if(!_checkList.contains(item.data()['email'])){
                _checkList.add(item.data()['email']);
                _finalList.add(item);
              }
            }
            return _finalList.reversed.toList();
          }else if(firstPage == false && docUid!.isNotEmpty){
            return await FirebaseFirestore
              .instance
              .collection('appointments/' + _currentUser + '/' + _currentUser)
              .where('user_uid', isEqualTo: docUid)
              // .get().then((value) => value.docs.reversed.toList());
              .get().then((value) => value.docs.toList());
          }
      } else {
        return await FirebaseFirestore
            .instance
            .collection('appointments/' + _currentUser + '/' + _currentUser)
            .where('date', isGreaterThan: DateTime.now().millisecondsSinceEpoch)
            // .get().then((value) => value.docs.reversed.toList());
            .get().then((value) => value.docs.toList());
      }
    }
  }
}

// Gets times for booking
getTimesForBooking() {
  Stream<QuerySnapshot<Map<String, dynamic>>> _snapshot =
      FirebaseFirestore.instance.collection('test').snapshots();

  return _snapshot;
}

// Specific chat data
getChatMessages(String _collection) {
  Stream<QuerySnapshot<Map<String, dynamic>>> _snapshot = FirebaseFirestore
      .instance
      .collection(_collection)
      .orderBy('id_message', descending: true)
      .snapshots();
  return _snapshot;
}

// All patient/doctor chats
getChats(String _collection, String uid) async { 
  QuerySnapshot<Map<String, dynamic>> _userRole = await FirebaseFirestore
      .instance
      .collection('roles')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();

  for (QueryDocumentSnapshot<Map<String, dynamic>> element in _userRole.docs) {
    if (element.data()['role'] == 'p') {
      QuerySnapshot<Map<String, dynamic>> _getMemberUid =
          await FirebaseFirestore.instance
              .collection(_collection)
              .where('member_1', isEqualTo: uid)
              .get();
      List _result = [];
      List _responce = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> el
          in _getMemberUid.docs) {
        QuerySnapshot<Map<String, dynamic>> _snapshot = await FirebaseFirestore
            .instance
            .collection('chats/' + uid + '/' + el.data()['member_2'])
            .orderBy('id_message', descending: false)
            .get();
        if (_snapshot.docs.isNotEmpty) {
          _result.add(_snapshot.docs.last.data());
        }
      }
      for (var _res in _result) {
        _responce.add(_res);
      }
      return _responce;
    } else if (element.data()['role'] == 'd') {
      QuerySnapshot<Map<String, dynamic>> _getMemberUid =
          await FirebaseFirestore.instance
              .collection(_collection)
              .where('member_2', isEqualTo: uid)
              .get();

      List _result = [];
      List _responce = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> el
          in _getMemberUid.docs) {
        QuerySnapshot<Map<String, dynamic>> _snapshot = await FirebaseFirestore
            .instance
            .collection('chats/' + el.data()['member_1'] + '/' + uid)
            .orderBy('id_message', descending: false)
            .get();

        if (_snapshot.docs.isNotEmpty) {
          _result.add(_snapshot.docs.last.data());
        }
      }
      for (var _res in _result) {
        _responce.add(_res);
      }
      return _responce;
    }
  }
}

// Return related documentation that was used by doctors or patients
getDocuments(String uid, bool isFirstPage, {String? email}) async {
  QuerySnapshot<Map<String, dynamic>> _userRole = await FirebaseFirestore
      .instance
      .collection('roles')
      .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();

  for (QueryDocumentSnapshot<Map<String, dynamic>> element in _userRole.docs) {
    if (element.data()['role'] == 'p') {
      List _result = [];
      QuerySnapshot<Map<String, dynamic>> _getMemberUid =
          await FirebaseFirestore.instance
              .collection('all_chats')
              .where('member_1', isEqualTo: uid)
              .get();
      for (QueryDocumentSnapshot<Map<String, dynamic>> el
          in _getMemberUid.docs) {
        QuerySnapshot<Map<String, dynamic>> _snapshot = await FirebaseFirestore
            .instance
            .collection('chats/' + uid + '/' + el.data()['member_2'])
            .where('attachment', isNotEqualTo: "")
            .orderBy('attachment', descending: false)
            .get();
        if (isFirstPage == true) {
          _result.add(_snapshot.docs[0].data()['member_2_email']);
        } else {
          for (var _res in _snapshot.docs) {
            if (_res.data()['member_2_email'] == email) {
              _result.add(_res);
            }
          }
        }
      }
      return _result;
    } else if (element.data()['role'] == 'd') {
      List _result = [];
      QuerySnapshot<Map<String, dynamic>> _getMemberUid =
          await FirebaseFirestore.instance
              .collection('all_chats')
              .where('member_2', isEqualTo: uid)
              .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> el
          in _getMemberUid.docs) {
        QuerySnapshot<Map<String, dynamic>> _snapshot = await FirebaseFirestore
            .instance
            .collection('chats/' + el.data()['member_1'] + '/' + uid)
            .where('attachment', isNotEqualTo: "")
            .orderBy('attachment', descending: false)
            .get();

        if (isFirstPage == true) {
          _result.add(_snapshot.docs[0].data()['member_1_email']);
        } else {
          for (var _res in _snapshot.docs) {
            if (_res.data()['member_1_email'] == email) {
              _result.add(_res);
            }
          }
        }
      }
      return _result;
    }
  }
}
