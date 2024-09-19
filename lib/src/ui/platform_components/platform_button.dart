import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class IElevatedButton {
  factory IElevatedButton(TargetPlatform targetPlatform) {
    switch (targetPlatform) {
      case TargetPlatform.android:
        return AndroidButton();

      case TargetPlatform.iOS:
        return AndroidButton();

      default:
        return AndroidButton();
    }
  }

  Widget getPlatformButton(
      Function() function, String buttonTitle, Color? color);
}

class IOSButton implements IElevatedButton {
  @override
  Widget getPlatformButton(
      Function() function, String buttonTitle, Color? color) {
    return CupertinoButton(
      onPressed: function,
      color: color,
      child: Text(buttonTitle,
          style: TextStyle(
              fontSize: 12, fontFamily: "DMSans", fontWeight: FontWeight.bold)),
    );
  }
}

class AndroidButton implements IElevatedButton {
  @override
  Widget getPlatformButton(
      Function() function, String buttonTitle, Color? color) {
    return ElevatedButton(
        onPressed: function,
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(color)),
        child: Text(
          buttonTitle,
          style: TextStyle(
              fontSize: 12, fontFamily: "DMSans", fontWeight: FontWeight.bold),
        ));
  }
}
