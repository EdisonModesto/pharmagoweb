import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmagoweb/Directory/DirectoryUI.dart';
import 'package:pharmagoweb/ShopUI/ShopUI.dart';
import 'package:pharmagoweb/StoreDbUI/storeDbUI.dart';
import 'package:pharmagoweb/appProvider.dart';
import 'package:pharmagoweb/chat/chatUI.dart';
import 'package:pharmagoweb/registerProvider.dart';
import 'package:provider/provider.dart';
import 'package:side_navigation/side_navigation.dart';

import 'Authentication/loginUI.dart';
import 'OrdersDbUI/orderDbUI.dart';
import 'UserDbUI/userDbUI.dart';

class navBar extends StatefulWidget {
  const navBar({Key? key}) : super(key: key);

  @override
  State<navBar> createState() => _navBarState();
}

class _navBarState extends State<navBar> {

  List<Widget> views = const [
    UserDbUI(),
    StoreDbUI(),
    OrderDbUI()
  ];

  List<Widget> userViews = const [
    ShopUI(),
    DirectoryUI(),
    ChatUI()
  ];

  List<SideNavigationBarItem> adminSide = const [
    SideNavigationBarItem(
      icon: CupertinoIcons.person,
      label: 'User Database',
    ),
    SideNavigationBarItem(
      icon: Icons.storefront_outlined,
      label: 'Store Database',
    ),
    SideNavigationBarItem(
      icon: CupertinoIcons.cart,
      label: 'Orders Database',
    ),
  ];

  List<SideNavigationBarItem> userSide = const [
    SideNavigationBarItem(
      icon: Icons.shopping_cart_outlined,
      label: 'Shop',
    ),
    SideNavigationBarItem(
      icon: Icons.map_outlined,
      label: 'Directory',
    ),
    SideNavigationBarItem(
      icon: Icons.chat,
      label: 'Chat with Pharmacist',
    ),
  ];

  int selectedIndex = 0;

  void listenAuthState(){
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>loginUI()));
      }
    });
  }

  getUserInfo() async {
    if(FirebaseAuth.instance.currentUser != null) {
      var collection = FirebaseFirestore.instance.collection('Users').doc(
          FirebaseAuth.instance.currentUser?.uid);
      var docSnapshot = await collection.get();
      Map<String, dynamic>? data = docSnapshot.data();

      print(data);
      context.read<registerProvider>().addDetails(
          data!["Mobile"], data["Name"], data["Address"], data["Age"],
          data["Weight"], data["Height"]);
    }
  }


  @override
  void initState() {
    listenAuthState();
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavigationBar(
            selectedIndex: selectedIndex,
            header: SideNavigationBarHeader(
                image: const CircleAvatar(
                  backgroundColor: Color(0xffE6E6E6),
                  child: Icon(CupertinoIcons.person_2, color: Colors.grey,),
                ),
                title: Text(
                  'PharmaGo',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
                subtitle: Text(
                  '',
                  style: GoogleFonts.poppins(
                    color: Color(0xffE6E6E6),
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                )
            ),
            footer: SideNavigationBarFooter(
                label: ElevatedButton(
                  onPressed: (){
                    FirebaseAuth.instance.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffE6E6E6),
                    foregroundColor: Color(0xff219C9C),
                    fixedSize: Size(175,50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Logout",
                    style: GoogleFonts.poppins(),
                  ),
                )
            ),
            theme: SideNavigationBarTheme(
              backgroundColor: const Color(0xff219C9C),
              togglerTheme: SideNavigationBarTogglerTheme.standard(),
              itemTheme: SideNavigationBarItemTheme(
                  unselectedItemColor: const Color(0xffE6E6E6),
                  selectedItemColor: Colors.white,
                  iconSize: 32.5,
                  labelTextStyle: GoogleFonts.poppins(
                    fontSize: 20,
                  )
              ),
              dividerTheme: const SideNavigationBarDividerTheme(

                showFooterDivider: true,
                showMainDivider: true,
                showHeaderDivider: true,
                headerDividerColor: Colors.white,


              ),
            ),
            items: context.watch<appProvider>().isAdmin ? adminSide : userSide,
            onTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: context.watch<appProvider>().isAdmin ? views[selectedIndex] : userViews[selectedIndex],
          )
        ],
      ),
    );
  }
}
