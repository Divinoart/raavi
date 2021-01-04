import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raavi/assets/usermanagement.dart';
import 'package:raavi/widget/button.dart';
import 'package:raavi/widget/customTextField.dart';
import 'package:raavi/widget/singup.dart';
import 'package:raavi/widget/textNew.dart';
import 'package:raavi/widget/userOld.dart';

import '../firebase_analytics.dart';

class NewUser extends StatefulWidget {
  @override
  _NewUserState createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email;
  String _password, _fullName;
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
                  Row(
                    children: <Widget>[
                      SingUp(),
                      TextNew(),
                    ],
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(bottom: 20, top: 0),
                            child: CustomTextField(
                              onSaved: (input) {
                                _fullName = input;
                              },
                              validator: (value) => value.isEmpty
                                  ? 'Required'
                                  : null,
                              icon: Icon(Icons.email),
                              icon2: (null),
                              hint: "FULL NAME",
                            )),
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
                    print('signing up');
                    validateAndSubmit();
                  },
                    ok: 'Sign Up',
                    isLoading: _loading,

                  ),
                  UserOld(),
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

  void validateAndSubmit(){
    if (validateAndSave() ) {
      setState(() {
        _loading = true;
      });
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _email, password: _password)
          .then((signedInUser) async {
        //for share preference
        if (signedInUser != null) {

          print("Registered");
//          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
        }
        else {
//          setState(() {
//            error = 'Error while registering the user!';
//            _isLoading = false;
//          });
        }
        //end of shared preference

        await signedInUser.user.updateProfile(displayName: _fullName, photoURL: 'test.com');
        //todo send email verification
        await signedInUser.user.sendEmailVerification();
        await signedInUser.user.reload();
        User updatedUser = await FirebaseAuth.instance.currentUser;
        print('USERNAME IS: ${updatedUser.displayName} ');
      }).then((user) async {
        User updatedUser = await FirebaseAuth.instance.currentUser;

          print('user1:${updatedUser.photoURL}:ok');
          UserManagement().storeNewUser(updatedUser, context);
          analytics.logEvent(
              name: 'Register',
              parameters: {'User': updatedUser.displayName.toString(),});
//          await ChatDBFireStore.checkUserExists(user).then((value) {
////            showNotification('Account successfully created');
//
//            Navigator.of(context).pop();
//            Navigator.of(context).pushReplacementNamed('/home');
//          });

      }).catchError((e) {
        print(e);
        setState(() {
          _loading = false;
          _error = e.message;
        });

        _scaffoldKey.currentState.showSnackBar( SnackBar
          (content:  Text( _error, style: TextStyle(color: Colors.white),),
          backgroundColor: Colors.red,));



      });
    }else{

      print ('form is invalid');
    }


  }

}
