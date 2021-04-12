import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar Header(context,
    {bool isAppTitle, String titleText, bool removeBackButton = true}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? true : false,
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
    title: Text(
      isAppTitle ? "futtershare" : titleText,
      style: TextStyle(
          fontFamily: isAppTitle ? "Signatra" : "",
          fontSize: isAppTitle ? 50.0 : 22.0,
          color: Colors.white),
    ),
  );
}
