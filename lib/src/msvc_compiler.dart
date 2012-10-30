part of ccompile;

class MsvcCompiler implements ProjectTool {
  Future<ProcessResult> run(Project project, [String workingDirectory]) {
    return MsvcUtils.getEnvironment(
        project.getBits(WindowsUtils.getSystemBits())).chain((env) {
      var options = new ProcessOptions();
      if(env != null) {
        options.environment = env;
      }

      var executable = WindowsUtils.findFileInEnvPath(env, 'cl.exe');
      var arguments = _projectToArguments(project);
      options.workingDirectory = workingDirectory;
      return Process.run(executable, arguments, options);
    });
  }

  List<String> _projectToArguments(Project project) {
    var settings = project.compilerSettings;
    var arguments = ['/c'];

    arguments.addAll(settings.arguments);

    var inputFiles = SystemUtils.expandEnvironmentVars(settings.inputFiles);
    inputFiles = inputFiles.map((elem) => FileUtils.correctPathSeparators(elem));
    inputFiles.forEach((inputFile) {
      arguments.add('"$inputFile"');
    });

    var includes = SystemUtils.expandEnvironmentVars(settings.includes);
    includes = includes.map((elem) => FileUtils.correctPathSeparators(elem));
    includes.forEach((include) {
      arguments.add('/I"$include"');
    });

    settings.defines.forEach((k, v) {
      if(v == null) {
        arguments.add('/D$k');
      } else {
        arguments.add('/D$v=$k');
      }
    });

    return arguments;
  }
}
