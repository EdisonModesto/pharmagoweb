import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderDbUI extends StatefulWidget {
  const OrderDbUI({Key? key}) : super(key: key);

  @override
  State<OrderDbUI> createState() => _OrderDbUIState();
}

class _OrderDbUIState extends State<OrderDbUI> {
  String selectedItem = "";
  String selectedOrderItem = "";
  TextEditingController stringCtrl = TextEditingController();

  Future<QuerySnapshot<Map<String, dynamic>>> getUsers() async {
    return await FirebaseFirestore.instance.collection("Orders").get();
  }

  Future<Map<String, dynamic>?> getUserData()async{
    var userDoc = await FirebaseFirestore.instance.collection("Orders").doc(selectedItem).get();

    if (userDoc.exists) {
      return userDoc.data();
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getDocOrders() async {
    var userDoc = await FirebaseFirestore.instance.collection("Orders").doc(selectedItem).get();
    return await FirebaseFirestore.instance.collection("Orders").doc(selectedItem).collection("items").get();
  }

  Future<Map<String, dynamic>?> getItemData()async{
    var userDoc = await FirebaseFirestore.instance.collection("Orders").doc(selectedItem).collection("items").doc(selectedOrderItem).get();
    if (userDoc.exists) {
      return userDoc.data();
    }
  }

  void editString1(key, value)async{
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
            FirebaseFirestore.instance.collection("Users").doc(selectedItem).update({
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

  void editString2(key, value)async{
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
            FirebaseFirestore.instance.collection("Orders").doc(selectedItem).collection("items").doc(selectedOrderItem).update({
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
                        "Orders",
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
                          flex: 1,
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
                                                title: Text(snapshot.data!.docs[index].data()["Buyer"]),
                                                subtitle: Text(snapshot.data!.docs[index].data()["Status"]),
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
                          flex: 2,
                          child: Column(
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
                                                      IconButton(
                                                        onPressed: (){
                                                          editString1(snapshot.data!.keys.elementAt(index), snapshot.data!.values.elementAt(index));
                                                        },
                                                        icon: const Icon(Icons.edit),
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
                                                future: getDocOrders(),
                                                builder: (builder, snapshot){
                                                  if(snapshot.hasData){
                                                    return ListView.builder(
                                                        itemCount: snapshot.data!.docs.length,
                                                        itemBuilder: (builder, index){
                                                          return ListTile(
                                                            onTap: (){
                                                              setState(() {
                                                                selectedOrderItem = snapshot.data!.docs[index].id;
                                                              });
                                                            },
                                                            leading: const Icon(Icons.person),
                                                            title: Text(snapshot.data!.docs[index].data()["itemName"]),
                                                            subtitle: Text(snapshot.data!.docs[index].data()["itemPrice"]),
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
                                    ),
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
                                                future: getItemData(),
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
                                                            IconButton(
                                                              onPressed: (){
                                                                editString2(snapshot.data!.keys.elementAt(index), snapshot.data!.values.elementAt(index));
                                                              },
                                                              icon: const Icon(Icons.edit),
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
