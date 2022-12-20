import 'package:flutter/material.dart';

class registerProvider with ChangeNotifier{
  String Number = "";
  String Name = "";
  String Address = "";
  String Age = "";
  String Height = "";
  String Weight = "";

  void addDetails(String p1, p2, p3, p4, p5, p6){
    Number = p1;
    Name = p2;
    Address = p3;
    Age = p4;
    Height = p5;
    Weight = p6;
    notifyListeners();
  }
}