class MsvcLinker implements ProjectTool {
  Future<ProcessResult> run(Project project, [String workingDirectory]) {
    return MsvcUtils.getEnvironment(
        project.getBits(WindowsUtils.getSystemBits())).chain((env) {
      var options = new ProcessOptions();
      if(env != null) {
        options.environment = env;
      }

      var executable = WindowsUtils.findFileInEnvPath(env, 'link.exe');
      var arguments = _projectToArguments(project);
      options.workingDirectory = workingDirectory;
      return Process.run(executable, arguments, options);
    });
  }

  List<String> _projectToArguments(Project project) {
    var settings = project.linkerSettings;
    var arguments = [];

    arguments.addAll(settings.arguments);

    var inputFiles = SystemUtils.expandEnvironmentVars(settings.inputFiles);
    inputFiles = inputFiles.map((elem) => FileUtils.correctPathSeparators(elem));
    inputFiles.forEach((inputFile) {
      arguments.add('"$inputFile"');
    });

    var libpaths = SystemUtils.expandEnvironmentVars(settings.libpaths);
    libpaths = libpaths.map((elem) => FileUtils.correctPathSeparators(elem));
    libpaths.forEach((libpath) {
      arguments.add('/LIBPATH:"$libpath"');
    });

    if(!settings.outputFile.isEmpty()) {
      arguments.add('/OUT"${settings.outputFile}"');
    }

    return arguments;
  }
}
