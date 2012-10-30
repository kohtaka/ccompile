library example_utils;

import 'dart:mirrors';
import 'dart:io';
import 'dart:math';

class ExampleUtils {
  static String getRootScriptDirectory() {
    var reflection = currentMirrorSystem();
    var file = reflection.isolate.rootLibrary.url;
    if(Platform.operatingSystem == 'windows') {
      file = file.replaceAll('file:///', '');
    } else {
      file = file.replaceAll('file://', '');
    }

    return new Path.fromNative(file).directoryPath.toNativePath();
  }
}
