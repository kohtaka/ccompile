#library('ccompile_tool');

#import('dart:io');
#import('packages/args/args.dart');
#import('../lib/ccompile.dart');

main() {
  new CcompileTool().run().then((result) {
    exit(result);
  });
}

class CcompileTool {
  bool clean = true;

  bool compile = true;

  bool link = true;

  String format;

  String projectArgument;

  String projectDirectory;

  String projectFileName;

  String projectFullPath;

  int exitCode = 0;

  ArgParser _parser;

  bool _break;

  Future<int> run() {
    List<Future> tasks = [_parse(), _prepare(), _build()];
    _break = false;
    exitCode = 0;
    return Futures.wait(tasks).chain((_) {
      return new Future.immediate(exitCode);
    });
  }

  Future _parse() {
    return FutureUtils.fromSync(_parseSync);
  }

  _parseSync() {
    if(_break) {
      return;
    }

    _parser = new ArgParser();
    _parser.addFlag('compile', abbr: 'c', defaultsTo: true,
      help: 'Compile project');
    _parser.addFlag('clean', abbr: 'n', defaultsTo: true, help: 'Clean project');
    _parser.addFlag('link', abbr: 'l', defaultsTo: true, help: 'Link project');
    _parser.addOption('format', abbr: 'f', allowed: ['json', 'yaml'],
      help: 'Project file format. Specify format other than project filename extension',
      allowedHelp: {
        'json': 'The project format is JSON',
        'yaml': 'The project format is YAML',
      });

    var options = new Options();
    if(options.arguments.length == 0) {
      _printUsage();
      _break = true;
      return;
    }

    var arguments = options.arguments;
    projectArgument = arguments[0];
    arguments.removeRange(0, 1);
    var argResults;
    try {
      argResults = _parser.parse(arguments);
    } on FormatException catch (fe) {
      SystemUtils.writeStderr(fe.message);
      _printUsage();
      _break = true;
      exitCode = -1;
      return;
    } catch(e) {
      throw(e);
    }

    if(argResults.rest.length != 0) {
      SystemUtils.writeStderr('Illegal arguments:');
      argResults.rest.forEach((arg) => SystemUtils.writeStderr(arg));
      _printUsage();
      _break = true;
      exitCode = -1;
      return;
    }

    clean = argResults['clean'];
    compile = argResults['compile'];
    link = argResults['link'];
    format = argResults['format'];
    return;
  }

  Future _prepare() {
    return FutureUtils.fromSync(_prepareSync);
  }

  void _prepareSync() {
    if(_break) {
      return;
    }

    projectDirectory = _getDirectoryPath(projectArgument);
    if(projectDirectory == null) {
      SystemUtils.writeStderr('Project file "$projectArgument" not found.');
      _break = true;
      exitCode = -1;
      return;
    }

    projectFileName = new Path.fromNative(projectArgument).filename;
    projectFullPath = new Path.fromNative(projectDirectory).append(projectFileName)
        .toNativePath();
    return;
  }

  Future _build() {
    return FutureUtils.fromValue(null).chain((_) {
      if(_break) {
        return new Future.immediate(null);
      }

      var builder = new ProjectBuilder();
      return builder.loadProject(projectFullPath, format).chain((project) {
        return builder.customBuild(project, projectDirectory, compile, link, clean)
            .chain((ProcessResult result) {
          if(result.exitCode != 0) {
            exitCode = -1;
            SystemUtils.writeStdout(result.stdout);
            SystemUtils.writeStderr(result.stderr);
          }

          return new Future.immediate(null);
        });
      });
    });
  }


  String _getDirectoryPath(String filename) {
    var path = new Path.fromNative(filename);
    if(!path.isAbsolute) {
      var curDir = new Directory.current();
      var curDirPath = new Path.fromNative(curDir.path);
      path = curDirPath.join(path);
      filename = path.toNativePath();
    }

    var file = new File(filename);
    if(!file.existsSync()) {
      return  null;
    }

    return file.directorySync().path;
  }

  String _printUsage() {
    SystemUtils.writeStdout('');
    SystemUtils.writeStdout('Usage: cbuild project [options]');
    SystemUtils.writeStdout('Options:');
    SystemUtils.writeStdout(_parser.getUsage());
  }
}
