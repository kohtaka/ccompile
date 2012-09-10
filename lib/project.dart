class Project {
  int bits;

  String cpuType;

  CompilerSettings compilerSettings;

  LinkerSettings linkerSettings;

  List<String> clean = [];

  ProjectConfigurationMethod configurationMethod;

  Project() {
    bits = DartUtils.getVmBits();
    compilerSettings = new CompilerSettings();
    linkerSettings = new LinkerSettings();
  }
}
