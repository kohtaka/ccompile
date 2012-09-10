class GnuCompiler implements ProjectTool {
  Future<ProcessResult> run(Project project, [String workingDirectory]) {
    var options = new ProcessOptions();
    var executable = 'g++';
    var arguments = _projectToArguments(project);
    options.workingDirectory = workingDirectory;
    return Process.run(executable, arguments, options);
  }

  List<String> _projectToArguments(Project project) {
    var settings = project.compilerSettings;
    var arguments = ['-c'];
    arguments.addAll(settings.arguments);

    var includes = SystemUtils.expandEnvironmentVars(settings.includes);
    includes = includes.map((elem) => PathUtils.correctPathSeparators(elem));
    includes.forEach((include) {
      arguments.add('-I$include');
    });

    settings.defines.forEach((k, v) {
      if(v == null) {
        arguments.add('-D$k');
      } else {
        arguments.add('-D$v=$k');
      }
    });

    var inputFiles = SystemUtils.expandEnvironmentVars(settings.inputFiles);
    inputFiles = inputFiles.map((elem) => PathUtils.correctPathSeparators(elem));
    inputFiles.forEach((inputFile) {
      arguments.add('$inputFile');
    });

    return arguments;
  }
}
