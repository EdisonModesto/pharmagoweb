import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class StoreDbUI extends StatefulWidget {
  const StoreDbUI({Key? key}) : super(key: key);

  @override
  State<StoreDbUI> createState() => _StoreDbUIState();
}

class _StoreDbUIState extends State<StoreDbUI> {
  String selectedItem = "";

  Future<QuerySnapshot<Map<String, dynamic>>> getUsers() async {
    return await FirebaseFirestore.instance.collection("Shop").get();
  }

  Future<Map<String, dynamic>?> getUserData()async{
    var userDoc = await FirebaseFirestore.instance.collection("Shop").doc(selectedItem).get();

    if (userDoc.exists) {
      return userDoc.data();
    }
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
                                        print(snapshot.data!.docs[0].id);
                                        return ListView.builder(
                                            itemCount: snapshot.data!.docs.length,
                                            itemBuilder: (builder, index){
                                              return ListTile(
                                                onTap: (){
                                                  setState(() {
                                                    selectedItem = snapshot.data!.docs[index].id;
                                                  });
                                                },
                                                leading: const Icon(Icons.local_pharmacy),
                                                title: Text(snapshot.data!.docs[index].data()["Heading"]),
                                                subtitle: Text(snapshot.data!.docs[index].data()["Price"]),
                                                trailing: const Icon(Icons.arrow_forward_ios),
                                              );
                                            }
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
                                                trailing: const Icon(Icons.arrow_forward_ios),
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
