import 'package:firebase_auth/firebase_auth.dart';
import 'package:cottage_app/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:cottage_app/services/authservice.dart';
import 'package:cottage_app/services/signin.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
 final formKey = new GlobalKey<FormState>();

  String phoneNo, verificationId, smsCode;

  bool codeSent = false;
Widget getImageAsset(){
  AssetImage assetImage = AssetImage("assets/welcome.jpg");
  Image image = Image(image: assetImage,width:1000.0,height:600.0,fit: BoxFit.cover,);
  return Container(child: image,);
}
  @override
  Widget build(BuildContext context) {
    Widget _signInButton() {
      return OutlineButton(
        splashColor: Colors.grey,
        onPressed: () {
          signInWithGoogle().whenComplete(() {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          });
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        highlightElevation: 0,
        borderSide: BorderSide(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(image: AssetImage('assets/google.jpg',),height: 30,width: 30,),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Google',
                  style: TextStyle(
                      fontSize: 23,
                      color: Colors.black,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Form(
          key: formKey,
          child:Center(
        child: ListView(
          children: <Widget>[
             getImageAsset(),
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    
                    decoration: InputDecoration(hintText: ' Enter your phone number',prefixText: '+91',prefixIcon: Icon(Icons.phone),enabledBorder: OutlineInputBorder(
          borderSide:BorderSide(color: Colors.grey)),
                border: OutlineInputBorder(),
          ),
                    onChanged: (val) {
                      setState(() {
                        this.phoneNo = '+91'+val;
                      });
                    },
                  )),
                  codeSent ? Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0),
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(hintText: 'Enter OTP',prefixIcon: Icon(Icons.vpn_key),enabledBorder: OutlineInputBorder(
          borderSide:BorderSide(color: Colors.grey)),
          border: OutlineInputBorder(),),
                    onChanged: (val) {
                      setState(() {
                        this.smsCode = val;
                      });
                    },
                  )) : Container(),
              Padding(
                  padding: EdgeInsets.only(left: 25.0, right: 25.0,top: 10),
                  child: RaisedButton(
                      child: Center(child: codeSent ? Text('Continue',style: TextStyle(fontSize: 20),):Text('Verify',style: TextStyle(fontSize: 20),)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0),),
                      
                      onPressed: () {
                        AuthService().savePhoneNumber(this.phoneNo);
                        codeSent ? AuthService().signInWithOTP(smsCode, verificationId):verifyPhone(phoneNo);
                      })),
            SizedBox(height: 20,),
            Center(
              child: Text('Or Sign In With',
                style: TextStyle(color: Colors.black,fontSize: 22,fontWeight: FontWeight.bold),),
            ),
            SizedBox(height: 20,),
            _signInButton()

            ],
          )),
     ) );

  }

  Future<void> verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      AuthService().signIn(authResult);
    };

    final PhoneVerificationFailed verificationfailed =
        (AuthException authException) {
      print('${authException.message}');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }


}
