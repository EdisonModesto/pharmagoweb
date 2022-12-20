import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ntp/ntp.dart';

class ChatUI extends StatefulWidget {
  const ChatUI({Key? key}) : super(key: key);

  @override
  State<ChatUI> createState() => _ChatUIState();
}

class _ChatUIState extends State<ChatUI> {


  CollectionReference messages = FirebaseFirestore.instance.collection('Channels');
  ScrollController _scrollController = ScrollController();
  TextEditingController msgCtrl = TextEditingController();



  var storage = FirebaseStorage.instance;



  late var ref = FirebaseStorage.instance.ref("userReseta/${FirebaseAuth.instance.currentUser!.uid}").child('userReseta/');
  late var url = "";

  void initCloud()async{
    url = await ref.getDownloadURL();
    setState((){});
  }

  @override
  void dispose() {
    super.dispose();
    msgCtrl.dispose();
  }

  void checkAutoMsg()async{
    var docu = FirebaseFirestore.instance.collection("Channels").doc(FirebaseAuth.instance.currentUser!.uid);
    DateTime startDate = new DateTime.now().toLocal();
    var snap = await docu.get();
    int offset = await NTP.getNtpOffset(localTime: startDate);
    startDate.add(Duration(milliseconds: offset));


    var diff = startDate.difference(snap["lastUpdate"].toDate()).inMinutes;
    print(startDate.difference(snap["lastUpdate"].toDate()).inMinutes);

    if(diff > 15){
      print("AUTOREPLY SENT");
      messages.add({
        "message": "Hello! Thanks for visiting PharmaGo, we will be with you in just a moment.",
        "user": "AutoReplyBot",
        "time": startDate.add(Duration(milliseconds: offset))
      });
      var snap = FirebaseFirestore.instance.collection("Channels").doc(FirebaseAuth.instance.currentUser!.uid).update({
        "lastUpdate": startDate.add(Duration(milliseconds: offset)),
      });
    }
  }


  void jump(){
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.elasticOut);
    } else {
      Timer(Duration(milliseconds: 400), () => jump());
    }
  }

  @override
  void initState() {
    super.initState();
    messages = messages.doc(FirebaseAuth.instance.currentUser!.uid).collection("Messages");
    initCloud();
    checkAutoMsg();
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: StreamBuilder(
                            stream: messages.orderBy("time").snapshots(),
                            builder: (context,snapshot){
                              if (snapshot.hasError) {
                                return const Text('Something went wrong');
                              }

                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: const CircularProgressIndicator());
                              }

                              return ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                controller: _scrollController,
                                itemBuilder: (context,index){
                                  var RawMessage = snapshot.data?.docs[index]["message"];
                                  var parsedMessage = RawMessage.split("|");
                                  print(parsedMessage);
                                  WidgetsBinding.instance.addPostFrameCallback((_){
                                    if(_scrollController.hasClients){
                                      jump();
                                    }
                                  });
                                  return snapshot.data?.docs[index]["user"] == FirebaseAuth.instance.currentUser?.uid ?
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: parsedMessage[0] == "image" ?
                                        Container(
                                          height: 250,
                                          width: 175,
                                          decoration: const BoxDecoration(
                                              color: Color(0xff219C9C),
                                              borderRadius: BorderRadius.all(Radius.circular(15))
                                          ),
                                          margin: const EdgeInsets.only(bottom: 10, left: 30),
                                          padding: const EdgeInsets.only(left: 15, right: 15,top: 10, bottom: 10),
                                          child: Text("View Image in the mobile app")
                                        ) :
                                        Container(
                                          decoration: const BoxDecoration(
                                              color: Color(0xff219C9C),
                                              borderRadius: BorderRadius.all(Radius.circular(15))
                                          ),
                                          margin: const EdgeInsets.only(bottom: 10, left: 30),
                                          padding: const EdgeInsets.only(left: 15, right: 15,top: 10, bottom: 10),
                                          child: Text(
                                            parsedMessage[1],
                                            softWrap: true,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                      :
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: parsedMessage[0] == "image" ?
                                        Container(
                                          height: 250,
                                          width: 175,
                                          decoration: const BoxDecoration(
                                              color: Color(0xffD9DEDC),
                                              borderRadius: BorderRadius.all(Radius.circular(15))
                                          ),
                                          margin: const EdgeInsets.only(bottom: 10, right: 30),
                                          padding: const EdgeInsets.only(left: 15, right: 15,top: 10, bottom: 10),
                                          child: Text("View Image in the mobile app")
                                        ) :

                                        Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(Radius.circular(15))
                                          ),
                                          margin: const EdgeInsets.only(bottom: 10, right: 30),
                                          padding: const EdgeInsets.only(left: 15, right: 15,top: 10, bottom: 10),
                                          child: Text(
                                            snapshot.data?.docs[index]["message"],
                                            softWrap: true,
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                },
                              );
                            }),
                      ),
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      decoration: const BoxDecoration(
                          color: Color(0xffD9DEDC),
                          borderRadius: BorderRadius.all(Radius.circular(15))
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: msgCtrl,
                              decoration: const InputDecoration(
                                hintText: "Message",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              try {
                                DateTime startDate = new DateTime.now().toLocal();
                               // int offset = await NTP.getNtpOffset(localTime: startDate);
                                messages.add({
                                  "message": "msg|${msgCtrl.text}",
                                  "user": FirebaseAuth.instance.currentUser?.uid,
                                  "time": startDate
                                });
                                var snap = FirebaseFirestore.instance.collection("Channels").doc(FirebaseAuth.instance.currentUser!.uid).update({
                                  "lastUpdate": startDate,
                                });
                                msgCtrl.text = "";
                              } catch(e){
                                print(e);
                              }
                            },
                            icon: const Icon(Icons.send),
                          )
                        ],
                      ),
                    ),
                  ],
                )
            ),
          ),
        ),
      );
    });
  }
}
