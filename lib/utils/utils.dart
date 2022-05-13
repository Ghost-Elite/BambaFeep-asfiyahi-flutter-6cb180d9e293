import 'package:flutter/material.dart';


class Utils{
  static Route createRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        //var begin = Offset(1.0, 0.0);
        //var end = Offset.zero;
        //var tween = Tween(begin: begin, end: end);
        //var offsetAnimation = animation.drive(tween);

        /*return SlideTransition(
          position: offsetAnimation,
          child: child,
        );*/
        return FadeTransition(
          opacity:animation,
          child: child,
        );
      },
    );
  }
  static void navigationPage(BuildContext context,Widget w, bool goback) {
    Navigator.of(context).pushAndRemoveUntil(createRoute(w), (Route<dynamic> route) => goback);
  }

}