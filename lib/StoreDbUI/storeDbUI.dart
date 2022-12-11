import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_web/firebase_storage_web.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:shimmer/shimmer.dart';
import "package:path/path.dart" as Path;

class StoreDbUI extends StatefulWidget {
  const StoreDbUI({Key? key}) : super(key: key);

  @override
  State<StoreDbUI> createState() => _StoreDbUIState();
}

class _StoreDbUIState extends State<StoreDbUI> {
  String selectedItem = "";
  TextEditingController stringCtrl = TextEditingController();
  TextEditingController headCtrl = TextEditingController();
  TextEditingController descCtrl = TextEditingController();
  TextEditingController stockCtrl = TextEditingController();
  TextEditingController priceCtrl = TextEditingController();

  Future<QuerySnapshot<Map<String, dynamic>>> getUsers() async {
    return await FirebaseFirestore.instance.collection("Shop").get();
  }

  Future<Map<String, dynamic>?> getUserData()async{
    var userDoc = await FirebaseFirestore.instance.collection("Shop").doc(selectedItem).get();

    if (userDoc.exists) {
      return userDoc.data();
    }
  }

  void editString(key, value)async{
    stringCtrl.text = value;
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text("Edit"),
        content: TextField(
          controller: stringCtrl,
          decoration: const InputDecoration(
              hintText: "Enter new value"
          ),
          onTap: (){
            stringCtrl.text = "";
          },
          onSubmitted: (value){
            stringCtrl.text = value;
          },
        ),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: const Text("Cancel")),
          TextButton(onPressed: (){
            FirebaseFirestore.instance.collection("Shop").doc(selectedItem).update({
              "$key": stringCtrl.text
            });
            Navigator.pop(context);
            setState(() {

            });

          }, child: const Text("Save"))
        ],
      );
    });
  }

  void addItem(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text("Edit"),
        content: SizedBox(
          height: 250,
          child: Column(
            children: [
              TextField(
                controller: headCtrl,
                decoration: const InputDecoration(
                    hintText: "Item Title"
                ),
                onTap: (){
                  headCtrl.text = "";
                },
                onSubmitted: (value){
                  headCtrl.text = value;
                },
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                    hintText: "Item Description"
                ),
                onTap: (){
                  descCtrl.text = "";
                },
                onSubmitted: (value){
                  descCtrl.text = value;
                },
              ),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(
                    hintText: "Item Price"
                ),
                onTap: (){
                  priceCtrl.text = "";
                },
                onSubmitted: (value){
                  priceCtrl.text = value;
                },
              ),
              TextField(
                controller: stockCtrl,
                decoration: const InputDecoration(
                    hintText: "Item Stocks"
                ),
                onTap: (){
                  stockCtrl.text = "";
                },
                onSubmitted: (value){
                  stockCtrl.text = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: const Text("Cancel")),
          TextButton(onPressed: (){
            FirebaseFirestore.instance.collection("Shop").doc(headCtrl.text).set({
              "Heading": headCtrl.text,
              "Description": descCtrl.text,
              "Price": priceCtrl.text,
              "Stock": stockCtrl.text,
            });

            Navigator.pop(context);
            setState(() {

            });

          }, child: const Text("Save"))
        ],
      );
    });
  }

  var storage = FirebaseStorage.instance;
  var _photo;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery(id) async {
    _photo = await ImagePickerWeb.getImageAsBytes();
    print("UPLOADING");
    uploadFile(id);
  }

  Future uploadFile(var id) async {
    if (_photo == null) return;
    //final fileName = Path.basename(_photo!.path);
    final destination = 'shopImages/${id}';

    try {
     // print(_photo!.path);
      final ref = FirebaseStorageWeb(bucket: "gs://pharmago-c4dca.appspot.com").ref("gs://pharmago-c4dca.appspot.com/${destination}/itemImage/").putData(_photo!);
      //final ref = FirebaseStorage.instance.ref(destination).child('itemImage/');
      //ref.put();
      print("SUCCESS??");
    } catch (e) {
      print(e);
      print('error occured');
    }
  }

  Future<String> getURL(var ref)async{
    try{
      String url = await ref.getDownloadURL();
      print(url);
      return url;
    } catch (e) {
      print(e);
      print('error occured');
    };
  //  print("URL!: ${url1}");

    //String url = await ref.getDownloadURL();
    //print(url);
    return "";
  }


    @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builder, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        height: constraints.maxHeight * 0.9,
        child: Padding(
          padding: const EdgeInsets.only(left: 100, right: 100),
          child: Card(
            color: const Color(0xffD9DEDC),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))
            ),
            child: Padding(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        "Store",
                        style: GoogleFonts.poppins(
                            fontSize: 35,
                            fontWeight: FontWeight.w700
                        )
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: constraints.maxHeight * 0.9,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              color: Colors.white,
                              child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: FutureBuilder(
                                    future: getUsers(),
                                    builder: (builder, snapshot){
                                      if(snapshot.hasData){
                                        return Column(
                                          children: [
                                            Expanded(
                                              child: ListView.builder(
                                                  itemCount: snapshot.data!.docs.length,
                                                  itemBuilder: (builder, index){
                                                    var ref = FirebaseStorageWeb(bucket: "gs://pharmago-c4dca.appspot.com").ref("gs://pharmago-c4dca.appspot.com/shopImages/${snapshot.data!.docs[index].id}/itemImage");
                                                    print(ref);
                                                    return ListTile(
                                                      onTap: (){
                                                        setState(() {
                                                          selectedItem = snapshot.data!.docs[index].id;
                                                        });
                                                      },
                                                      leading:
                                                        FutureBuilder(
                                                          future: getURL(ref),
                                                          builder: (context, snapshot1) {
                                                            if (snapshot1.hasData) {
                                                              if(snapshot1.data! != ""){
                                                                return InkWell(
                                                                  onTap: () async {
                                                                    await imgFromGallery(snapshot.data!.docs[index].id);
                                                                  },
                                                                  child: Icon(Icons.check_box),
                                                                );
                                                              } else {
                                                                return InkWell(
                                                                  onTap: () async {
                                                                    await imgFromGallery(snapshot.data!.docs[index].id);
                                                                  },
                                                                  child: Icon(Icons.local_pharmacy_outlined),
                                                                );
                                                              }
                                                            }
                                                            return SizedBox();
                                                          }
                                                        ),
                                                      title: Text(snapshot.data!.docs[index].data()["Heading"]),
                                                      subtitle: Text(snapshot.data!.docs[index].data()["Price"]),
                                                      trailing: const Icon(Icons.arrow_forward_ios),
                                                    );
                                                  }
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: (){
                                                addItem();
                                              },
                                              child: const Text("Add Item"),
                                            )
                                          ],
                                        );
                                      }

                                      return const Center(
                                        child: CircularProgressIndicator(

                                        ),
                                      );
                                    },
                                  )
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20,),
                        Expanded(
                          child: SizedBox(
                            height: constraints.maxHeight * 0.9,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                              ),
                              color: Colors.white,
                              child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: FutureBuilder(
                                    future: getUserData(),
                                    builder: (builder, snapshot){
                                      if(snapshot.hasData){
                                        return ListView.builder(
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (builder, index){
                                              return ListTile(
                                                onTap: (){},
                                                leading: const Icon(Icons.person),
                                                title: Text(snapshot.data!.keys.elementAt(index)),
                                                subtitle: Text(snapshot.data!.values.elementAt(index).toString()),
                                                trailing: snapshot.data!.values.elementAt(index) is String ?
                                                ElevatedButton(
                                                  onPressed: (){
                                                    editString(snapshot.data!.keys.elementAt(index), snapshot.data!.values.elementAt(index));
                                                  },
                                                  child: const Text("Edit"),
                                                ) : const SizedBox(),
                                              );
                                            }
                                        );
                                      }

                                      return ListView.builder(
                                        itemCount: 10,
                                        itemBuilder: (context, index){
                                          return const SizedBox();
                                        },
                                      );
                                    },
                                  )
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
