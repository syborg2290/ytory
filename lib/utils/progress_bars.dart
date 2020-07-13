import 'package:flutter/material.dart';
import 'package:grafpix/pixloaders/pix_loader.dart';
import 'package:ytory/utils/pallete.dart';

Container circularProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: PixLoader(
        loaderType: LoaderType.Spinner, faceColor: Palette.mainAppColor),
  );
}

Container flashProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: PixLoader(
        loaderType: LoaderType.Flashing, faceColor: Palette.mainAppColor),
  );
}
