class Cleaner implements ProjectTool {
  abstract Future<ProcessResult> run(Project project, [String workingDirectory]);
}
