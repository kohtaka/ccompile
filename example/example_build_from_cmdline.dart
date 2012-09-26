#import('dart:io');
#import('dart:mirrors');

main() {
  var project = '../example/sample_extension.yaml';
  var prjPath = new Path.fromNative(project);
  var curDir = Utils.getRootScriptDirectory();
  var curDirPath = new Path.fromNative(curDir);
  var filepath = curDirPath.join(prjPath).toNativePath();
  runAsDartScript(filepath);
}

void runAsDartScript(String project) {
  var env = 'CCOMPILE';
  var ccompile = 'ccompile.dart';
  var path = Utils.findFileInPathEnv(ccompile);
  if(path.isEmpty()) {
    path = Utils.findFileInEnv(env, ccompile);
  }

  if(path.isEmpty()) {
    Utils.writeString('Can not find $ccompile either in env["PATH"] nor env["${env}"]', stderr);
    return;
  }

  var arguments = [path, project];
  Utils.writeString('Building project...', stdout);
  Process.run('dart', arguments).then((ProcessResult result) {
    if(result.exitCode == 0) {
      Utils.writeString('Building complete successfully.', stdout);
    } else {
      Utils.writeString('Building complete with some errors.', stdout);
      Utils.writeString(result.stdout, stdout);
      Utils.writeString(result.stderr, stderr);
    }
  });
}

class Utils {
  static String findFileInPathEnv(String filename) {
    var separator = Platform.operatingSystem == 'windows' ? ';' : ':';
    var envPath = Platform.environment['PATH'];
    if(envPath == null) {
      return '';
    }

    for(var item in envPath.split(separator)) {
      var path = new Path.fromNative('$item').append(filename).toNativePath();
      if(new File(path).existsSync()) {
        return path;
      }
    }

    return '';
  }

  static String findFileInEnv(String env, String filename) {
    var path = Platform.environment[env];
    if(path == null) {
      return '';
    }

    path = new Path.fromNative('$path').append(filename).toNativePath();
    path = expandEnvironmentVars([path])[0];
    if(new File(path).existsSync()) {
      return path;
    }

    return '';
  }

  static List<String> expandEnvironmentVars(List<String> strings) {
    var list = [];
    var len = strings.length;
    for(var string in strings) {
      list.add(_expandMacro(string, (s) => Platform.environment[s]));
    }

    return list;
  }

  static String _expandMacro(String string, String callback(String)) {
    RegExp exp = const RegExp(r'(%\S+?%)');
    var matches = exp.allMatches(string);
    for(var match in matches) {
      var seq = match.group(0);
      var key = seq.substring(1, seq.length - 1);
      string = string.replaceAll(seq, callback(key));
    }

    return string;
  }

  static String newline = Platform.operatingSystem == 'windows' ? '\r\n' : '\n';

  static void writeString(String string, OutputStream stream) {
    stream.writeString('$string$newline');
  }

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