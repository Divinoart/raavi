import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField(
      {this.icon, this.icon2,
      this.hint, this.obscure, this.controller, this.list,
      this.obsecure = false,
      this.validator,
      this.onSaved});
  final FormFieldSetter<String> onSaved;
  final Icon icon;
  final IconData icon2;
  final String hint;
  final List<TextInputFormatter> list;
  final Function obscure;
  final bool obsecure;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5),
      child: TextFormField(
        onSaved: onSaved,
        controller: controller,
        validator: validator,
        autofocus: true,
        obscureText: obsecure,
        inputFormatters: list,
        style: TextStyle(
          fontSize: 15,
          color: Colors.white
        ),
        decoration: InputDecoration(
            hintStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: Colors.white ),
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),
            prefixIcon: Padding(
              child: IconTheme(
                data: IconThemeData(color: Theme.of(context).primaryColor),
                child: icon,
              ),
              padding: EdgeInsets.only(left: 30, right: 10),
            ),


          suffixIcon:
          Padding(
            child: IconButton(
              icon: Icon(icon2),
              color: Theme.of(context).primaryColor,
//              iconSize: 30.0,
              onPressed: obscure
            ),
            padding: EdgeInsets.only(left: 10, right: 20),
          ),
        ),
      ),
    );
  }
}
