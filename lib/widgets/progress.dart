import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Container CircularProgress(context) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 8.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
    ),
  );
}

Container LinearProgress(context) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(bottom: 8.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
    ),
  );
}
