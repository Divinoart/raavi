import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonLogin extends StatefulWidget {
  ButtonLogin(
      {this.function, this.ok, this.isLoading});
  final Function function;
  final String ok;
  final bool isLoading;

  @override
  _ButtonLoginState createState() => _ButtonLoginState(function: (){function();}, ok: ok, isloading: isLoading);
}

class _ButtonLoginState extends State<ButtonLogin> {
  _ButtonLoginState(
      {this.function, this.ok, this.isloading});
  final Function function;
  final String ok;
  final bool isloading;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, right: 50, left: 200),
      child: Container(
        alignment: Alignment.bottomRight,
        height: 50,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color(0xff202835),
              blurRadius: 10.0, // has the effect of softening the shadow
              spreadRadius: 0.0, // has the effect of extending the shadow
              offset: Offset(
                1.0, // horizontal, move right 10
                1.0, // vertical, move down 10
              ),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: FlatButton(
          onPressed: (){widget.function();},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              widget.isLoading?
              Theme(data: ThemeData(cupertinoOverrideTheme: CupertinoThemeData(brightness: Brightness.light)),
                child: CupertinoActivityIndicator(
                  animating: true,
                ),
              )
              :Text(
                widget.ok,
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              widget.isLoading? SizedBox(): Icon(
                Icons.arrow_forward,
                color: Colors.lightBlueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
