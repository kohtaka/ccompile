#library('example_utils');

#import('dart:mirrors');
#import('dart:io');
#import('dart:math');

class ExampleUtils {
  static String getScriptDirectory() {
    // Don't use this technique in your projects.
    var reflect = currentMirrorSystem();
    var path = reflect.isolate.rootLibrary.url;
    if(Platform.operatingSystem == 'windows') {
      path = path.replaceAll('file:///', '');
    } else {
      path = path.replaceAll('file://', '');
    }
    var unix = path.lastIndexOf('/');
    var windows = path.lastIndexOf('\\');
    var index = max(unix, windows);
    if(index != -1) {
      return path.substring(0, index);
    }

    return '';
  }
}
