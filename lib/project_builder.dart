class ProjectBuilder {
  String _platform;

  ProjectBuilder() {
    _platform = Platform.operatingSystem;
  }

  Future<ProcessResult> build(Project project, [String workingDirectory]) {
    return compile(project, workingDirectory).chain((result) {
      if(result.exitCode != 0) {
        return new Future.immediate(result);
      }

      return link(project, workingDirectory).chain((result) {
        return new Future.immediate(result);
      });
    });
  }

  Future<ProcessResult> compile(Project project, [String workingDirectory]) {
    return getCompiler().run(project, workingDirectory);
  }

  Future<ProcessResult> link(Project project, [String workingDirectory]) {
    return getLinker().run(project, workingDirectory);
  }

  Future<ProcessResult> clean(Project project, [String workingDirectory]) {
    return getCleaner().run(project, workingDirectory);
  }

  Future<ProcessResult> buildAndClean(Project project, [String workingDirectory]) {
    return build(project, workingDirectory).chain((result) {
      return clean(project, workingDirectory).chain((_) {
        return new Future.immediate(result);
      });
    });
  }

  ProjectTool getCleaner() {
    switch(_platform) {
      case 'linux':
        return new UnixCleaner();
      case 'macos':
        return new UnixCleaner();
      case 'windows':
        return new WindowsCleaner();
      default:
        _unsupportedPlatform();
        break;
    }
  }

  ProjectTool getCompiler() {
    switch(_platform) {
      case 'linux':
        return new GnuCompiler();
      case 'macos':
        return new GnuCompiler();
      case 'windows':
        return new MsvcCompiler();
      default:
        _unsupportedPlatform();
        break;
    }
  }

  ProjectTool getLinker() {
    switch(_platform) {
      case 'linux':
        return new GnuLinker();
      case 'macos':
        return new GnuLinker();
      case 'windows':
        return new MsvcLinker();
      default:
        _unsupportedPlatform();
        break;
    }
  }

  Future<Project> createProject(Map map) {
    FutureUtils.fromSync(() => createProject(map));
  }

  Project createProjectSync(Map map) {
    if(map == null) {
      throw new IllegalArgumentException('map: $map');
    }

    var project = new Project();
    _parseProject(project, map, false);
    return project;
  }

  void _parseProject(Project project, Map sections, bool skipTargets) {
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
            if(section.containsKey(_platform)) {
              _checkIsMap(section[_platform], 'targets');
              _parseProject(project, section[_platform], true);
            }
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

  void _parseBits(Project project, value) {
    if( value == null || value is int) {
      project.bits = value;
    } else {
      throw('Project section "bits" must be an int value or null.');
    }
  }

  void _parseCompilerSettings(Project project, Map sections) {
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

  void _parseLinkerSettings(Project project, Map sections) {
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

  Future<Project> loadProject(String filepath, [String format]) {
    return FutureUtils.fromSync(() => loadProjectSync(filepath, format));
  }

  Project loadProjectSync(String filepath, [String format]) {
    if(filepath == null || filepath.isEmpty()) {
      throw new IllegalArgumentException('filename: $filepath');
    }

    if(format != null && format != 'json' && format != 'yaml') {
      throw new IllegalArgumentException('format: $format');
    }

    if(format == null) {
      var ext = PathUtils.getExtension(filepath);
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

    return createProjectSync(map);
  }

  bool isSupportedPlatform(String platform) {
    return ['linux', 'macos', 'windows'].some((elem) => elem == platform);
  }

  _checkIsListOfStrings(list, String section) {
    _checkIsList(list, section);

    var len = list.length;
    for(var i = 0; i < len; i++) {
      if(list[0] is! String) {
        throw('Element #"i" in project section "$section" must be a String.');
      }
    }
  }

  void _checkIsList(list, String section) {
    if(list is! List) {
      throw('Project section "$section" must be a List.');
    }
  }

  void _checkIsMap(map, String section) {
    if(map is! Map) {
      throw('Project section "$section" must be a Map.');
    }
  }

  void _checkIsString(string, String section) {
    if(string is! String) {
      throw('Project section "$section" must be a String.');
    }
  }

  void _unknownSection(String section) {
    throw('Unknown section "$section" in project structure.');
  }

  void _unsupportedPlatform() {
    throw('Unsupported target $_platform.');
  }
}
