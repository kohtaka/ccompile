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
    return new Cleaner();
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

  Future<Project> loadProject(String filepath, [String format]) {
    return Project.load(filepath, format);
  }

  Project loadProjectSync(String filepath, [String format]) {
    return Project.loadSync(filepath, format);
  }

  bool isSupportedPlatform(String platform) {
    return ['linux', 'macos', 'windows'].some((elem) => elem == platform);
  }

  void _unsupportedPlatform() {
    throw('Unsupported target $_platform.');
  }
}
