import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import '../../chat/chatUI.dart';
import '../registerProvider.dart';
import 'dialog.dart';

class checkoutUI extends StatefulWidget {
  const checkoutUI({required this.names, required this.prices, Key? key}) : super(key: key);

  final List names;
  final List prices;

  @override
  State<checkoutUI> createState() => _checkoutUIState();
}

class _checkoutUIState extends State<checkoutUI> {

  double total = 0;
  int stats = 0;
  bool isBtnVis = true;
  List status = ["Awaiting Payment", "Waiting Reference No.", "Ready for pickup"];
  String ref = "Payment Required";
  String gcash = "Loading";

  void listenStatus(){
    DocumentReference reference = FirebaseFirestore.instance.collection('Orders').doc(FirebaseAuth.instance.currentUser!.uid);
    var listener;
    listener = reference.snapshots().listen((querySnapshot) {
      print("DEBUG: ${querySnapshot.get("Status")}");
      if(querySnapshot.get("Status") == "For Pickup"){
        setState(() {
          stats = 2;
          ref = querySnapshot.get("RefID").toString();
        });
        FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid).update({
          "FBM": FieldValue.arrayUnion(widget.names)
        });
        showDialog(context: context, builder: (context){
          return const dialogUI(title: "Payment Confirmed!", body: "Your order is now confirmed and is ready for pickup. Please take a screenshot of the receipt and show it to the cashier",);
        });
        listener.cancel();
      } else if(querySnapshot.get("Status") == "For Validation"){
        setState((){
          isBtnVis = false;
          stats +=1;
        });
      }
    });
  }

  void getGcash()async{
    var snap = FirebaseFirestore.instance.collection("shopData").doc("data");
    var data = await snap.get();
    setState((){
      gcash = data["gcash"];
    });
  }

  Future<double> calcPrice()async{
    var doc = FirebaseFirestore.instance.collection("Users").doc(FirebaseAuth.instance.currentUser!.uid);
    var snap = await doc.get();
    var isVerified = snap["isVerified"];
    total = 0;
    for(int i = 0; i < widget.names.length; i++){
      total += double.parse(widget.prices[i]);
    }

    if(isVerified){
      total = total - (0.20 * total);
    }

    return total;
  }

  @override
  void initState() {
    super.initState();
    listenStatus();
    getGcash();
    //listenStatus();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 165,
                          width: MediaQuery.of(context).size.width,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Card(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            color: const Color(0xff219C9C),
                            child:
                            Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Payment",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 16
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "GCash: $gcash",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15
                                    ),
                                  ),
                                  Text(
                                    "Status: ${status[stats]}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12
                                    ),
                                  ),
                                  Visibility(
                                    visible: isBtnVis,
                                    child: ElevatedButton(
                                      onPressed: (){
                                        print("DEBUG: SENDING TO FB");
                                        var col = FirebaseFirestore.instance.collection('Orders').doc(FirebaseAuth.instance.currentUser?.uid);
                                        col.set({
                                          "Buyer": context.read<registerProvider>().Name.split(" ")[0].toString(),
                                          "Total": total,
                                          "Status": "For Validation"
                                        });
                                        var colItems = col.collection("items");
                                        for(int i = 0; i < widget.names.length; i++){
                                          colItems.doc().set({
                                            "itemName": widget.names[i],
                                            "itemPrice": widget.prices[i]
                                          });
                                          print("DEBUGING : $i");
                                        }
                                        showDialog(context: context, builder: (context){
                                          return const dialogUI(title: "Payment Sent!", body: "Please wait for the seller to confirm your payment. A reference number will be available when confirmed.",);
                                        });
                                        listenStatus();
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          elevation: 0,
                                          fixedSize: const Size(200, 10)
                                      ),
                                      child: const Text(
                                        "Payment Sent",
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15))
                          ),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 315,
                            padding: const EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              color: Color(0xffD9DEDC),
                            ),
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                color: Colors.white,
                              ),
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  const Text(
                                    "Receipt",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  const Divider(
                                    thickness: 1, color: Colors.grey,
                                  ),
                                  Text(
                                    "Reference Number: ${ref}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Divider(
                                    thickness: 1, color: Colors.grey,
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: widget.names.length,
                                        itemBuilder: (context, index){
                                          return Container(
                                            height: 30,
                                            width: double.maxFinite,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(widget.names[index]),
                                                Text(widget.prices[index]),
                                              ],
                                            ),
                                          );
                                        }),
                                  ),
                                  const Divider(
                                    thickness: 1, color: Colors.grey,
                                  ),
                                  FutureBuilder(
                                      future: calcPrice(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Text(
                                            "Total: ${snapshot.data}",
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold
                                            ),
                                          );
                                        }
                                        return Center(child: CircularProgressIndicator());
                                      }
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}