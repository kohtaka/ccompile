#library('example_build');

#import('../lib/ccompile.dart');
#import('example_utils.dart');

void main() {
  build();
}

void build() {
  ExampleUtils.findLibrary("example_build");
  var workingDirectory = ExampleUtils.getScriptDirectory();
  var projectName = '${workingDirectory}/sample_extension.yaml';
  var builder = new ProjectBuilder();
  var errors = [];
  builder.loadProject(projectName).then((project) {
    print('Building project "$projectName"');
    builder.buildAndClean(project, workingDirectory).then((result) {
      if(result.exitCode != 0) {
        print('Error building project.');
        print('Exit code: ${result.exitCode}');
        if(!result.stdout.isEmpty()) {
          print('${result.stdout}');
        }

        if(!result.stderr.isEmpty()) {
          print('${result.stderr}');
        }
      } else {
        print('Project is built successfully.');
        print('To check the work done, run "example_use_sample_extension.dart".');
      }
    });
  });
}
