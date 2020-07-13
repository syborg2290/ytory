import 'package:animator/animator.dart';
import 'package:content_placeholder/content_placeholder.dart';
import 'package:flutter/material.dart';

shimmerEffectLoadingGallery(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  double height = MediaQuery.of(context).size.height;
  return SingleChildScrollView(
    child: Padding(
      padding: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
      child: Animator(
        duration: Duration(milliseconds: 1000),
        tween: Tween(begin: 0.95, end: 1.0),
        curve: Curves.easeInCirc,
        cycles: 0,
        builder: (anim) => Transform.scale(
            scale: anim.value,
            child: ContentPlaceholder(
              bgColor: Color(0xffe0e0e0),
              borderRadius: 30.0,
              highlightColor: Colors.grey[200],
              context: context,
              child: Column(children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                    ContentPlaceholder.block(
                        width: width * 0.27,
                        height: height * 0.15,
                        rightSpacing: 10,
                        borderRadius: 20),
                  ],
                ),
              ]),
            )),
      ),
    ),
  );
}
