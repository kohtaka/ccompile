class Project {
  int bits;

  CompilerSettings compilerSettings;

  LinkerSettings linkerSettings;

  List<String> clean = [];

  Project() {
    compilerSettings = new CompilerSettings();
    linkerSettings = new LinkerSettings();
  }

  int getBits() {
    if(bits == 0) {
      return DartUtils.getVmBits();
    }

    return bits;
  }
}
