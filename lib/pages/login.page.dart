import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raavi/Home.dart';
import 'package:raavi/firebase_analytics.dart';
import 'package:raavi/widget/button.dart';
import 'package:raavi/widget/customTextField.dart';
import 'package:raavi/widget/first.dart';
import 'package:raavi/widget/textLogin.dart';
import 'package:raavi/widget/verticalText.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email;
  String _password;
  bool _isobscure = true;
  bool _loading = false;
  String errorMsg = "", _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blueGrey, const Color(0xff202835)]),
        ),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[
                    VerticalText(),
                    TextLogin(),
//                    Row(
//                      children: [
//                        Padding(
//                          padding: const EdgeInsets.all(13.0),
//                          child: Image.asset(
//                            'assets/images/avatar.png',
//                            fit: BoxFit.cover,
//                          ),
//                        ),
//                      ],
//
//                    )
                  ]),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(bottom: 20, top: 0),
                            child: CustomTextField(
                              list: [FilteringTextInputFormatter.deny(RegExp('[ ]')),],

                              onSaved: (input) {
                                _email = input;
                              },
                              validator: (value) => !EmailValidator.validate(value, true)
                                  ? 'Not a valid email.'
                                  : null,
                              icon: Icon(Icons.email),
                              icon2: (null),
                              hint: "EMAIL",
                            )),

                        Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child:
                            CustomTextField(
                              list: [FilteringTextInputFormatter.deny(RegExp('[ ]')),],
                              icon: Icon(Icons.lock),
//                            controller: _pass,
                              obsecure: _isobscure? true : false,
                              icon2: _isobscure?(Icons.visibility) : (Icons.visibility_off),
                              obscure: _isobscure? (){
                                setState(() {
                                  _isobscure = false;
                                });
                              }
                                  :
                                  (){
                                setState(() {
                                  _isobscure = true;
                                });
                              },
                              onSaved: (input) => _password = input,
                              validator: (input) =>
                              input.isEmpty ? "*Required" : null,
                              hint: "PASSWORD",
                            )),

                      ],
                    ),
                  ),
//                InputEmail(),
//                PasswordInput(),
                  ButtonLogin(function: (){
                    print('log in');

                    validateAndLogin();
                  },

                    ok: 'login',
                    isLoading: _loading,

                  ),
                  FirstTime(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void validateAndLogin() {
    if (validateAndSave()) {
      setState(() {
        _loading = true;
      });
      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email, password: _password)
          .then((auth) async {
// shared preference starts here for login
        if (auth != null) {

          analytics.logLogin();
//          showNotification('you just signed in');
//
//          await ChatDBFireStore.checkUserExists(user);
        }
        else {
//          setState(() {
//            error = 'Error signing in!';
//            _isLoading = false;
//          });
        }


        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home()));


//        Navigator.of(context).pushReplacementNamed('/home');
      })
          .catchError((e) {
        print(e);
        setState(() {
          setState(() {
            _loading = false;
          });
          _error = e.message;
        });
        _scaffoldKey.currentState.showSnackBar( SnackBar
          (content:  Text( _error, style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red,));

      });
    } else {
      print('form is invalid');
    }
  }


  Future<void> validateAndReset() async {
    if (validateAndSave()) {
      setState(() {
        _loading = true;
      });
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email)
          .then((value) {
        setState(() {
          _loading = false;
          _scaffoldKey.currentState.showSnackBar( SnackBar
            (content:  Text( 'A reset link has been successfully sent to your email address', style: TextStyle(color: Colors.white),),
            backgroundColor: Color(0xff211332),));
        });
      }).catchError((e){
        setState(() {
          _loading = false;
          _error = e.message;
        });
        _scaffoldKey.currentState.showSnackBar( SnackBar
          (content:  Text( _error, style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red,));
      });

    } else {
      print('Reset form is invalid');
    }
  }


}


