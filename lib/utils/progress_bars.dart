import 'package:flutter/material.dart';
import 'package:grafpix/pixloaders/pix_loader.dart';

Container circularProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: PixLoader(loaderType: LoaderType.Rocks, faceColor: Colors.black),
  );
}

Container flashProgress() {
  return Container(
    padding: EdgeInsets.only(bottom: 10.0),
    child: PixLoader(loaderType: LoaderType.Flashing, faceColor: Colors.black),
  );
}
