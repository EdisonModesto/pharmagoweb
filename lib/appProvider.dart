import 'package:flutter/cupertino.dart';

class appProvider with ChangeNotifier{
  bool isAdmin = false;

  void changeStatus(newStatus){
    isAdmin = newStatus;
    notifyListeners();
  }

}