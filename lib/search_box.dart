import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raavi/constants.dart';


class SearchBox extends StatefulWidget {

  SearchBox({
    Key key,


    this.function,
    this.hintText

  }) : super(key: key);


  final Function function;
  final String hintText;


  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  final GlobalKey<FormState> _amountFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(top: 0, ),
//      padding: EdgeInsets.symmetric(
//        horizontal: kDefaultPadding,
//        vertical: kDefaultPadding / 4, // 5 top and bottom
//      ),
      decoration: BoxDecoration(
        color: Color(0xff3FD2E6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _fuc,
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
//            Expanded(
//              flex: 1,
//              child: Container(child: Center(child: Icon(CupertinoIcons.money_dollar, color: Colors.white,),),
//              decoration: BoxDecoration(
//                color: const Color(0xFF343a40),
//                borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), bottomLeft: Radius.circular(12.0)),
//              ),
//              ),
//            ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.hintText, style: TextStyle(color: Colors.white, fontSize: 12),),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: RaisedButton(
                  color: const Color(0xff3FD2E6).withOpacity(0.1),
                  onPressed: _fuc,
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.only(topRight: Radius.circular(12.0), bottomRight: Radius.circular(12.0))),
                  child: Center(child: Icon(Icons.search, color: Colors.white, size: 15,)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool amountValidateAndSave() {
    final form = _amountFormKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  _fuc() async {
//    if (amountValidateAndSave()) {
      widget.function();
//    }else{
//      print('no price set');
//    }
  }
}





