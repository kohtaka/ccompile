part of ccompile;

class ProjectHelper {
  static Future<Project> create(Map map) {
    FutureUtils.fromSync(() => createSync(map));
  }

  static Project createSync(Map map) {
    var parser = new ProjectParser();
    var project = parser.parse(map);
    if(parser.hasErrors) {
      var nl = Platform.operatingSystem == 'windows' ? '\r\n' : '\n';
      var errors = Strings.join(parser.errors, nl);
      throw('During the parsing of the project there was an error(s):$nl$errors');
    }

    return project;
  }

  static Future<Project> load(String filepath, [String format]) {
    return FutureUtils.fromSync(() => loadSync(filepath, format));
  }

  static Project loadSync(String filepath, [String format]) {
    if(filepath == null || filepath.isEmpty) {
      throw new IllegalArgumentException('filename: $filepath');
    }

    if(format != null && format != 'json' && format != 'yaml') {
      throw new IllegalArgumentException('format: $format');
    }

    if(format == null) {
      var ext = new Path.fromNative(filepath).extension;
      switch(ext.toLowerCase()) {
        case 'json':
          format = 'json';
          break;
        case 'yaml':
        case 'yml':
          format = 'yaml';
          break;
        default:
          throw('Unrecognized format of file "$filepath".');
      }
    }

    var text = FileUtils.readAsStringSync(filepath);

    var map;
    if(format == 'json') {
      map = JSON.parse(text);
    }

    if(format == 'yaml') {
      map = loadYaml(text);
    }

    if(map is! Map) {
      throw('Invalid project structure. Project must be a Map.');
    }

    return createSync(map);
  }
}
