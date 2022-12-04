import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class UserDbUI extends StatefulWidget {
  const UserDbUI({Key? key}) : super(key: key);

  @override
  State<UserDbUI> createState() => _UserDbUIState();
}

class _UserDbUIState extends State<UserDbUI> {

  TextEditingController stringCtrl = TextEditingController();
  String selectedUser = "";

  Future<QuerySnapshot<Map<String, dynamic>>> getUsers() async {
    return await FirebaseFirestore.instance.collection("Users").get();
  }

  Future<Map<String, dynamic>?> getUserData()async{
    var userDoc = await FirebaseFirestore.instance.collection("Users").doc(selectedUser).get();

    if (userDoc.exists) {
      return userDoc.data();
    }
  }

  void editBoolValue(key,value)async{
    print("VALUE");
    FirebaseFirestore.instance.collection("Users").doc(selectedUser).update({
      "$key": value
    });
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
            FirebaseFirestore.instance.collection("Users").doc(selectedUser).update({
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
                      "Users",
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
                                padding: EdgeInsets.all(8),
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
                                                  selectedUser = snapshot.data!.docs[index].id;
                                                });
                                              },
                                              leading: const Icon(Icons.person),
                                              title: Text(snapshot.data!.docs[index].data()["Name"]),
                                              subtitle: Text(snapshot.data!.docs[index].data()["Mobile"]),
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
                                  padding: EdgeInsets.all(8),
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
                                                trailing: snapshot.data!.values.elementAt(index) is bool ?
                                                ElevatedButton(onPressed: (){
                                                  if(snapshot.data!.values.elementAt(index) == true){
                                                    editBoolValue(snapshot.data!.keys.elementAt(index), false);
                                                    SnackBar snackBar = SnackBar(content: Text("Value Changed to False"));
                                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                  } else {
                                                    editBoolValue(snapshot.data!.keys.elementAt(index), true);
                                                    SnackBar snackBar = SnackBar(content: Text("Value Changed to True"));
                                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                  }
                                                  setState(() {

                                                  });
                                                }, child: Text("Change Status")) :
                                                snapshot.data!.values.elementAt(index) is String ?
                                                ElevatedButton(onPressed: (){
                                                  editString(snapshot.data!.keys.elementAt(index), snapshot.data!.values.elementAt(index));
                                                }, child: Text("Edit Value")): SizedBox(),
                                              );
                                            }
                                        );
                                      }

                                      return ListView.builder(
                                        itemCount: 10,
                                        itemBuilder: (context, index){
                                          return SizedBox();
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
