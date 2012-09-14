class UnixCleaner implements ProjectTool {
  Future<ProcessResult> run(Project project, [String workingDirectory]) {
    return new Future.immediate(null);
  }
}

