import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_storage_web/firebase_storage_web.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'cartList.dart';
import 'checkoutUI.dart';
import 'expandItem.dart';

class ShopUI extends StatefulWidget {
  const ShopUI({Key? key}) : super(key: key);

  @override
  State<ShopUI> createState() => _ShopUIState();
}

class _ShopUIState extends State<ShopUI> {

  CollectionReference shop = FirebaseFirestore.instance.collection('Shop');

  Future<String> getURL(var ref)async{
    String url = await ref.getDownloadURL();
    return url;
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
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Shopping",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                IconButton(
                                    onPressed: ()async{
                                      List name = [];
                                      List price = [];
                                      var collec;
                                      collec = await FirebaseFirestore.instance.collection("Orders").doc(FirebaseAuth.instance.currentUser!.uid).get().then((value)async{
                                        if(value.exists){
                                          var docum = await FirebaseFirestore.instance.collection("Orders").doc(FirebaseAuth.instance.currentUser!.uid).collection("items").snapshots();
                                          docum.forEach((element) {
                                            element.docs.forEach((element1) {
                                              name.add(element1.data()["itemName"]);
                                              price.add(element1.data()["itemPrice"]);
                                              print(element1.data()["itemName"]);
                                              print(element1.data()["itemPrice"]);
                                            });
                                          });

                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>checkoutUI(names: name, prices: price,)));

                                          //print(docum!["Buyer"]);
                                        }else{

                                        }
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.book,
                                      color: Color(0xff414141),
                                    )
                                ),
                                IconButton(
                                    onPressed: (){
                                      showMaterialModalBottomSheet(
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(20),
                                                  topLeft: Radius.circular(20)
                                              )
                                          ),
                                          builder: (context) => const cartList()
                                      );
                                    },
                                    icon: Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Color(0xff219C9C),
                                    )
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      Expanded(
                          child: StreamBuilder(
                              stream: shop.snapshots(),
                              builder: (context,snapshot) {
                                if (snapshot.hasError) {
                                  return const Text('Something went wrong');
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(child: const CircularProgressIndicator());
                                }

                                return GridView.count(
                                  padding: const EdgeInsets.only(left: 0, right: 0, top: 15),
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 30,
                                  mainAxisSpacing: 20,
                                  children: List.generate(snapshot.data!.docs.length, (index) {
                                    late var ref = FirebaseStorage.instance.ref("shopImages/${snapshot.data?.docs[index].id}").child('itemImage/');
                                    var ref1 = FirebaseStorageWeb(bucket: "gs://pharmago-c4dca.appspot.com").ref("shopImages/${snapshot.data?.docs[index].id}").child('itemImage/');
                                    return ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      child: ElevatedButton(
                                        onPressed: (){
                                          showMaterialModalBottomSheet(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topRight: Radius.circular(20),
                                                    topLeft: Radius.circular(20)
                                                )
                                            ),
                                            context: context,
                                            builder: (context) => expandItem(heading: snapshot.data?.docs[index]['Heading'], price: snapshot.data?.docs[index]['Price'], stocks: snapshot.data?.docs[index]['Stock'], desc: snapshot.data?.docs[index]['Description'], id: snapshot.data!.docs[index].id,),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            fixedSize: Size(145, 145)
                                        ),
                                        child: Container(
                                          color: Color(0xffD9DEDC),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: FutureBuilder<String>(
                                                  future: getURL(ref),
                                                  builder: (context, AsyncSnapshot<String> snapshot){
                                                    if(snapshot.hasData){
                                                      return ClipRRect(
                                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12) ),
                                                        child: Container(
                                                          width: MediaQuery.of(context).size.width,
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              image: NetworkImage(
                                                                  "${snapshot.data}"
                                                              ),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    } else{
                                                      return Center(child: const CircularProgressIndicator());
                                                    }
                                                  },
                                                ),
                                              ),
                                              Container(
                                                height: 100,
                                                width: MediaQuery.of(context).size.width,
                                                color: Colors.white,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 15, right: 15),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        snapshot.data?.docs[index]['Heading'],
                                                        style: const TextStyle(
                                                            color: Color(0xff424242)
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      Text(
                                                        "Stocks: ${snapshot.data?.docs[index]['Stock']}",
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Color(0xff424242)
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  ),
                                );
                              })
                      )
                    ]
                ),
              )
            ),
          ),
        ),
      );
    });
  }
}
