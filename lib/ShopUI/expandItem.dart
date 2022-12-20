import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../chat/chatUI.dart';

class expandItem extends StatefulWidget {

  const expandItem({required this.heading, required this.price, required this.stocks, required this.desc, required this.id, Key ? key}) : super(key: key);

  final String heading, price, stocks, desc, id;

  @override
  State<expandItem> createState() => _expandItemState();
}

class _expandItemState extends State<expandItem> {

  Future<String> getURL(var ref)async{

    String url = await ref.getDownloadURL();
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FutureBuilder<String>(
            future: getURL(FirebaseStorage.instance.ref("shopImages/${widget.id}").child('itemImage/')),
            builder: (context,  AsyncSnapshot<String> snapshot){
              if(snapshot.hasData){
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    image: DecorationImage(
                      image: NetworkImage(
                        "${snapshot.data}",
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }else{
                return Center(child: const CircularProgressIndicator());

              }
            },
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 50,
            color: const Color(0xff219C9C),
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset("assets/images/PharmaGo_rounded.png", scale: 3.5,),
                const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    "PharmaGo",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            overflow: TextOverflow.ellipsis,
                            widget.heading,
                            style: const TextStyle(
                                fontSize: 16
                            ),
                            softWrap: true,
                            maxLines: 2,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  overflow: TextOverflow.ellipsis,
                                  "PHP ${widget.price}",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xff219C9C)
                                  ),
                                  softWrap: true,
                                  maxLines: 2,
                                ),
                                SizedBox(
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: (){
                                          var collection = FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).collection("Cart").doc();
                                          collection.set({
                                            "Item": widget.id,
                                          });
                                        },
                                        icon: const Icon(Icons.add_shopping_cart_sharp),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            overflow: TextOverflow.ellipsis,
                            "About",
                            style: TextStyle(
                                fontSize: 14
                            ),
                            softWrap: true,
                            maxLines: 2,
                          ),
                          Text(
                            overflow: TextOverflow.ellipsis,
                            "\nName: ${widget.heading}",
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                            softWrap: true,
                            maxLines: 2,
                          ),
                          Text(
                            overflow: TextOverflow.ellipsis,
                            "\nQuantity: ${widget.stocks}",
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            overflow: TextOverflow.ellipsis,
                            "Description",
                            style: TextStyle(
                                fontSize: 14
                            ),
                            softWrap: true,
                            maxLines: 2,
                          ),
                          Text(
                            overflow: TextOverflow.ellipsis,
                            "\n${widget.desc}",
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                            softWrap: true,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}