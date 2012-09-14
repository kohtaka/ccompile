class WindowsCleaner implements ProjectTool {
  Future<ProcessResult> run(Project project, [String workingDirectory]) {
    return FutureUtils.fromSync(() =>
      _buildCleanTasks(project, workingDirectory)).chain((tasks) {
        if(tasks.length == 0) {
          return new Future.immediate(new ProjectToolResult());
        }

        return Futures.wait(tasks).chain((_) {
          return new Future.immediate(new ProjectToolResult());
        });
      });
  }

  List<Future> _buildCleanTasks(Project project, String workingDirectory) {
    if(project.clean.length == 0) {
      return [];
    }

    var commands = [];
    var futures = [];
    var files = project.clean.map((el) => FileUtils.correctPathSeparators(el));
    files.forEach((filename) {
      commands.add('del $filename');
    });

    var cmd = Strings.join(commands, ' && ');
    cmd = 'cmd /c  $cmd';
    var options = new ProcessOptions();
    options.workingDirectory = workingDirectory;
    futures.add(Process.run(cmd, [], options));
    return futures;
  }
}
