class WindowsConfigurator implements ProjectTool {
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
      case ProjectConfigurationMethod.OPERATING_SYSTEM:
        return _configureForOperatingSystem(project);
      default:
        return ProjectConfigurationUtils.getErrorConfigurationMethod(
            project.configurationMethod);
    }
  }

  ProcessResult _configureForDartSDK(project) {
    project.bits = DartUtils.getVmBits();
    switch(project.bits) {
      case 32:
        project.cpuType = 'x86';
        break;
      case 64:
        project.cpuType = 'x64';
        break;
      default:
        return ProjectConfigurationUtils.getErrorProcessorBits(
            project.bits);
    }

    return new ProjectToolResult();
  }

  ProcessResult _configureForOperatingSystem(project) {
    var arch = Platform.environment['PROCESSOR_ARCHITECTURE'];
    switch(arch) {
      case 'x86':
        project.bits = 32;
        project.cpuType = 'x86';
        break;
      case 'AMD64':
        project.bits = 64;
        project.cpuType = 'x64';
        break;
      default:
        return ProjectConfigurationUtils.getErrorProcessorBits(
            project.bits);
    }

    return new ProjectToolResult();
  }
}
