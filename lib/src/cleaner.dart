part of ccompile;

class Cleaner implements ProjectTool {
  Future<ProcessResult> run(Project project, [String workingDirectory]) {
    return _clean(project, workingDirectory);
  }

  Future<ProcessResult> _clean(Project project, String workingDirectory) {
    if(workingDirectory == null) {
      workingDirectory = new Directory.current().path;
    }

    return FileFinder.find(workingDirectory, project.clean).chain((files) {
      files.forEach((file) {
        var fp = new File(file);
        if(fp.existsSync()) {
          fp.deleteSync();
        }
      });

      return new Future.immediate(new ProjectToolResult());
    });
  }
}
