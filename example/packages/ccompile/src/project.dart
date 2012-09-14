class Project {
  int bits;

  CompilerSettings compilerSettings;

  LinkerSettings linkerSettings;

  List<String> clean = [];

  Project() {
    compilerSettings = new CompilerSettings();
    linkerSettings = new LinkerSettings();
  }

  int getBits([int defaultValue]) {
    if(bits == 0) {
      return DartUtils.getVmBits();
    }

    if(bits == null) {
      return defaultValue;
    }

    return bits;
  }

  static Future<Project> create(Map map) {
    FutureUtils.fromSync(() => createSync(map));
  }

  static Project createSync(Map map) {
    if(map == null) {
      throw new IllegalArgumentException('map: $map');
    }

    var project = new Project();
    _parseProject(project, map, false);
    return project;
  }

  static Future<Project> load(String filepath, [String format]) {
    return FutureUtils.fromSync(() => loadSync(filepath, format));
  }

  static Project loadSync(String filepath, [String format]) {
    if(filepath == null || filepath.isEmpty()) {
      throw new IllegalArgumentException('filename: $filepath');
    }

    if(format != null && format != 'json' && format != 'yaml') {
      throw new IllegalArgumentException('format: $format');
    }

    if(format == null) {
      var ext = new Path(filepath).extension;
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

    var text = FileUtils.readAsTextSync(filepath);

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

  static void _parseProject(Project project, Map sections, bool skipTargets) {
    var platform = Platform.operatingSystem;

    sections.forEach((name, section) {
      switch(name) {
        case 'bits':
          _parseBits(project, section);
          break;
        case 'compiler':
          _checkIsMap(section, 'compiler');
          _parseCompilerSettings(project, section);
          break;
        case 'linker':
          _checkIsMap(section, 'linker');
          _parseLinkerSettings(project, section);
          break;
        case 'platforms':
          if(!skipTargets) {
            if(section.containsKey(platform)) {
              _checkIsMap(section[platform], 'targets');
              _parseProject(project, section[platform], true);
            }
          } else {
            _unknownSection(name);
          }
          break;
        case 'clean':
          _checkIsListOfStrings(section, 'clean');
          project.clean.addAll(section);
          break;
        default:
          _unknownSection(name);
          break;
      }
    });
  }

  static void _parseBits(Project project, value) {
    if( value == null || value is int) {
      project.bits = value;
    } else {
      throw('Project section "bits" must be an int value or null.');
    }
  }

  static void _parseCompilerSettings(Project project, Map sections) {
    var settings = project.compilerSettings;
    sections.forEach((name, section) {
      switch(name) {
        case 'arguments':
          _checkIsListOfStrings(section, 'arguments');
          settings.arguments.addAll(section);
          break;
        case 'defines':
          _checkIsMap(section, 'defines');
          section.forEach((k, v) {
            settings.defines[k] = v;
          });
          break;
        case 'includes':
          _checkIsListOfStrings(section, 'includes');
          settings.includes.addAll(section);
          break;
        case 'input_files':
          _checkIsListOfStrings(section, 'input_files');
          settings.inputFiles.addAll(section);
          break;
        default:
          _unknownSection(name);
      }
    });
  }

  static void _parseLinkerSettings(Project project, Map sections) {
    var settings = project.linkerSettings;
    sections.forEach((name, section) {
      switch(name) {
        case 'arguments':
          _checkIsListOfStrings(section, 'arguments');
          settings.arguments.addAll(section);
          break;
        case 'input_files':
          _checkIsListOfStrings(section, 'input_files');
          settings.inputFiles.addAll(section);
          break;
        case 'libpaths':
          _checkIsListOfStrings(section, 'libpaths');
          settings.libpaths.addAll(section);
          break;
        case 'output_file':
          _checkIsString(section, 'output_file');
          settings.outputFile = section;
          break;
        default:
          _unknownSection(name);
          break;
      }
    });
  }

  static void _checkIsListOfStrings(list, String section) {
    _checkIsList(list, section);

    var len = list.length;
    for(var i = 0; i < len; i++) {
      if(list[0] is! String) {
        throw('Element #"i" in project section "$section" must be a String.');
      }
    }
  }

  static void _checkIsList(list, String section) {
    if(list is! List) {
      throw('Project section "$section" must be a List.');
    }
  }

  static void _checkIsMap(map, String section) {
    if(map is! Map) {
      throw('Project section "$section" must be a Map.');
    }
  }

  static void _checkIsString(string, String section) {
    if(string is! String) {
      throw('Project section "$section" must be a String.');
    }
  }

  static void _unknownSection(String section) {
    throw('Unknown section "$section" in project structure.');
  }
}
