#library('example_build');

#import('dart:io');
#import('../lib/ccompile.dart');
#import('example_utils.dart');

void main() {
  build();
}

void build() {
  var workingDirectory = ExampleUtils.getRootScriptDirectory();
  var projectName = '${workingDirectory}/sample_extension.yaml';
  var builder = new ProjectBuilder();
  var errors = [];
  builder.loadProject(projectName).then((project) {
    SystemUtils.writeStdout('Building project "$projectName"');
    builder.buildAndClean(project, workingDirectory).then((result) {
      if(result.exitCode != 0) {
        SystemUtils.writeStdout('Error building project.');
        SystemUtils.writeStdout('Exit code: ${result.exitCode}');
        if(!result.stdout.isEmpty()) {
          SystemUtils.writeStdout(result.stdout);
        }

        if(!result.stderr.isEmpty()) {
          SystemUtils.writeStderr(result.stderr);
        }
      } else {
        SystemUtils.writeStdout('Project is built successfully.');
        SystemUtils.writeStdout(
            'To check the work done, run "example_use_sample_extension.dart".');
      }
    });
  });
}
