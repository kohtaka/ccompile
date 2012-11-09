part of ccompile;

abstract class ProjectTool {
  Future<ProcessResult> run(Project project, [String workingDirectory]);
}
