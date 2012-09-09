#library('example_build');

#import('dart:io');
#import('dart:math');
#import('dart:mirrors');
#import('../ccompile.dart');

void main() {
  build();
}

void build() {
  var workingDirectory = getScriptDirectory();
  var separator = Platform.pathSeparator;
  var projectName = '${workingDirectory}${separator}sample_extension.yaml';
  var clean = true;
  var builder = new ProjectBuilder();
  builder.loadProject(projectName).then((project) {
    print('Building project "$projectName"');
    builder.build(project, workingDirectory)
    .chain((result) {
      if(clean) {
        return builder.clean(project, workingDirectory).chain((_) {
          return new Future.immediate(result);
        });
      }

      return new Future.immediate(result);
    })
    .then((result) {
      if(result.exitCode != 0) {
        print('Error building project.');
        print('Exit code: ${result.exitCode}');
        if(!result.stdout.isEmpty()) {
          print('${result.stdout}');
        }

        if(!result.stderr.isEmpty()) {
          print('${result.stderr}');
        }
      } else {
        print('Project is built successfully.');
      }
    });
  });
}

String getScriptDirectory() {
  // Don't use this in your projects.
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