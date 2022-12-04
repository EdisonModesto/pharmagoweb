import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharmagoweb/Navbar.dart';

class loginUI extends StatefulWidget {
  const loginUI({Key? key}) : super(key: key);

  @override
  State<loginUI> createState() => _loginUIState();
}

class _loginUIState extends State<loginUI> {

  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  
  Future<void> signIn() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrl.text,
          password: passwordCtrl.text
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>navBar()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Login to PharmaGo",
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 55,
                  child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autovalidateMode: AutovalidateMode.disabled,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '';
                        }
                        return null;
                      },
                      controller: emailCtrl,
                      style: const TextStyle(
                          fontSize: 14
                      ),
                      decoration: const InputDecoration(
                        errorStyle: TextStyle(height: 0),
                        label: Text("Email"),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                          borderSide: BorderSide(
                            color: Color(0xff219C9C),
                            width: 2.0,
                          ),
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 6.0,
                          ),
                        ),
                      )
                  ),
                ),
                SizedBox(
                  height: 55,
                  child: TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '';
                        }
                        return null;
                      },
                      controller: passwordCtrl,
                      style: const TextStyle(
                          fontSize: 14
                      ),
                      decoration: const InputDecoration(
                        errorStyle: TextStyle(height: 0),
                        label: Text("Password"),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                          borderSide: BorderSide(
                            color: Color(0xff219C9C),
                            width: 2.0,
                          ),
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(8),
                          ),
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 6.0,
                          ),
                        ),
                      )
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formkey.currentState!.validate()) {
                      signIn();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(409, 53),
                      backgroundColor: const Color(0xff219C9C),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6))
                      )
                  ),
                  child: const Text(
                      "Login"
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
