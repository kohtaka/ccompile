class LinuxConfigurator implements ProjectTool {
  Future<ProcessResult> run(Project project, [String workingDirectory]) {
    return FutureUtils.fromSync(() => _configure(project));
  }

  ProcessResult _configure(Project project) {
    if(project.configurationMethod == null) {
      return new ProjectToolResult();
    }

    switch(project.configurationMethod) {
      case ProjectConfigurationMethod.DART_SDK:
        return _configureForDartSDK(project);
      default:
        return ProjectConfigurationUtils.getErrorConfigurationMethod(
            project.configurationMethod);
    }
  }

  ProcessResult _configureForDartSDK(project) {
    project.bits = DartUtils.getVmBits();
    switch(project.bits) {
      case 32:
        project.compilerSettings.arguments.add('-m32');
        project.linkerSettings.arguments.add('-m32');
        break;
      case 64:
        break;
      default:
        return ProjectConfigurationUtils.getErrorProcessorBits(
            project.bits);
    }

    return new ProjectToolResult();
  }

  ProcessResult _configureForOperatingSystem(project) {
    return new ProjectToolResult();
  }
}
