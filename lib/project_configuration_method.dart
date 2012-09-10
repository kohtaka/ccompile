class ProjectConfigurationMethod {
  static const ProjectConfigurationMethod DART_SDK =
      const ProjectConfigurationMethod('DART_SDK');

  static const ProjectConfigurationMethod OPERATING_SYSTEM =
      const ProjectConfigurationMethod('OPERATING_SYSTEM');

  final String method;

  const ProjectConfigurationMethod(this.method);

  String toString() => method;
}
