part of ccompile;

interface ProjectTool {
  Future<ProcessResult> run(Project project, [String workingDirectory]);
}
