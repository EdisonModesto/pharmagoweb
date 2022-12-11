import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../Navbar.dart';
import '../appProvider.dart';

class UserLoginUI extends StatefulWidget {
  const UserLoginUI({Key? key}) : super(key: key);

  @override
  State<UserLoginUI> createState() => _UserLoginUIState();
}

class _UserLoginUIState extends State<UserLoginUI> {
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passwordCtrl = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  late ConfirmationResult confirmationResult;

  void sendOTP()async{
    FirebaseAuth auth = FirebaseAuth.instance;

// Wait for the user to complete the reCAPTCHA & for an SMS code to be sent.
    confirmationResult = await auth.signInWithPhoneNumber('+63${emailCtrl.text.substring(1)}');
    setState(() {
      otpSent = true;
    });
  }

  verifyOTP()async{
    UserCredential userCredential = await confirmationResult.confirm('${passwordCtrl.text}').whenComplete((){
      context.read<appProvider>().changeStatus(false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>navBar()));
    });

  }


  bool otpSent = false;

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
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.disabled,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length != 11) {
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
                        label: Text("Number"),
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
                      obscureText: false,
                      keyboardType: TextInputType.number,
                      onChanged: (value){
                        if(value.length == 6){
                          verifyOTP();
                        }
                      },
                      controller: passwordCtrl,
                      style: const TextStyle(
                          fontSize: 14
                      ),
                      enabled: otpSent,
                      decoration: const InputDecoration(
                        errorStyle: TextStyle(height: 0),
                        label: Text("Enter OTP"),
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
                      sendOTP();
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
                      "Send OTP"
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
