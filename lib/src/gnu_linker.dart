part of ccompile;

class GnuLinker implements ProjectTool {
  Future<ProcessResult> run(Project project, [String workingDirectory]) {
    var options = new ProcessOptions();
    var executable = 'gcc';
    var arguments = _projectToArguments(project);
    options.workingDirectory = workingDirectory;
    return Process.run(executable, arguments, options);
  }

  List<String> _projectToArguments(Project project) {
    var settings = project.linkerSettings;
    var arguments = [];
    arguments.addAll(settings.arguments);

    if(project.getBits() == 32) {
      arguments.add('-m32');
    }

    var libpaths = SystemUtils.expandEnvironmentVars(settings.libpaths);
    libpaths = libpaths.map((elem) => FileUtils.correctPathSeparators(elem));
    libpaths.forEach((libpath) {
      arguments.add('-L$libpath');
    });

    if(!settings.outputFile.isEmpty) {
      arguments.add('-o');
      arguments.add('${settings.outputFile}');
    }

    var inputFiles = SystemUtils.expandEnvironmentVars(settings.inputFiles);
    inputFiles = inputFiles.map((elem) => FileUtils.correctPathSeparators(elem));
    inputFiles.forEach((inputFile) {
      var ext = new Path.fromNative(inputFile).extension;
      if(ext.isEmpty) {
        inputFile = '$inputFile.o';
      }
      arguments.add('$inputFile');
    });

    return arguments;
  }
}
