import 'package:flutter/material.dart';

const primaryColor = Color(0xff2532A1);
const secondaryAccent = Color(0xffF6B700);
const primaryLight = Color(0xffD3EFFF);
const primaryLightVariant = Color(0xffFFF9D9);

class ListDataScreen extends StatelessWidget {
  final Widget widget;
  final String title;

  const ListDataScreen({super.key, required this.widget, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Column(
        children: [
          Container(
              padding:
                  EdgeInsets.only(left: 18, right: 10, bottom: 16, top: 40),
              color: primaryColor,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  InkWell(
                      onTap: () {
                        // Scaffold.of(context).openDrawer();
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.arrow_back_sharp,
                        size: 24,
                        color: Colors.white,
                      )),
                  Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: "DMSans",
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Spacer(),
                ],
              )),
          Expanded(
              child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30)),
                  child: Container(
                      padding: const EdgeInsets.only(top: 16),
                      color: primaryLightVariant,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: widget)))
        ],
      ),
    );
  }
}
