import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmagoweb/StoreDbUI/storeDbUI.dart';
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


  @override
  void initState() {
    listenAuthState();
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
                  'SuperAdmin',
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
            items: const [
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
            ],
            onTap: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: views.elementAt(selectedIndex),
          )
        ],
      ),
    );
  }
}
