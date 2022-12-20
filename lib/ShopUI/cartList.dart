import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'checkoutUI.dart';
import 'expandItem.dart';

class cartList extends StatefulWidget {
  const cartList({Key? key}) : super(key: key);

  @override
  State<cartList> createState() => _cartListState();
}

class _cartListState extends State<cartList> {

  var shop = FirebaseFirestore.instance.collection('Shop');
  CollectionReference Cart = FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).collection("Cart");

  List name = [];
  List price = [];

  getFunc(snap)async{
    var item = await shop.doc(snap).get();
    return item.data();
  }

  Future<String> getURL(var ref)async{

    String url = await ref.getDownloadURL();
    return url;
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your Cart",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              TextButton(
                onPressed: (){
                  Cart.get().then((value){
                    for (DocumentSnapshot ds in value.docs){
                      ds.reference.delete();
                    };
                  });
                },
                child: Text(
                    "Clear All"
                ),
              )
            ],
          ),
          Expanded(
              child: StreamBuilder(
                  stream: Cart.snapshots(),
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
                      crossAxisCount: 6,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: List.generate(snapshot.data!.docs.length, (index) {
                        return StreamBuilder(
                            stream: shop.doc(snapshot.data?.docs[index]["Item"]).snapshots(),
                            builder: (context,snapshot1) {
                              name.add(snapshot1.data!["Heading"]);
                              price.add(snapshot1.data!["Price"]);
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
                                      builder: (context) => expandItem(heading: snapshot1.data!['Heading'], price: snapshot1.data!['Price'], stocks: snapshot1.data!['Stock'], desc: snapshot1.data!['Description'], id: snapshot1.data!.id,),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      fixedSize: Size(125, 125)
                                  ),
                                  child: Container(
                                    color: Color(0xffD9DEDC),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12) ),
                                            child: FutureBuilder(
                                              future: getURL(FirebaseStorage.instance.ref("shopImages/${snapshot1.data!.id}").child('itemImage/')),
                                              builder: (context, strSnap){
                                                if(strSnap.hasData){
                                                  return Container(
                                                    width: MediaQuery.of(context).size.width,
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            "${strSnap.data}"
                                                        ),

                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  );
                                                } else{
                                                  return Center(child: CircularProgressIndicator());
                                                }
                                              },
                                            ),
                                          ),
                                        ),

                                        SizedBox(
                                          height: 60,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 15, right: 15),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  snapshot1.data!['Heading'],
                                                  style: const TextStyle(
                                                      color: Color(0xff424242)
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                        );
                      }),
                    );
                  })
          ),
          ElevatedButton(
            onPressed: (){

              showMaterialModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20)
                      )
                  ),
                  builder: (context) =>  checkoutUI(names: name, prices: price,)
              );
             // Navigator.push(context, MaterialPageRoute(builder: (context)=>checkoutUI(names: name, prices: price,)));
              /*PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: checkoutUI(names: name, prices: price,),
                withNavBar: true, // OPTIONAL VALUE. True by default.
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );*/
            },
            style: ElevatedButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width, 53),
                backgroundColor: const Color(0xff219C9C),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6))
                )
            ),
            child: const Text(
                "Check Out"
            ),
          ),
        ],
      ),
    );
  }
}