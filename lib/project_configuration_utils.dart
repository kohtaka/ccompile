class ProjectConfigurationUtils {
  static ProcessResult getErrorProcessorBits(int bits) {
    var messages = [];
    if(bits == null) {
      messages.add('No information about processor bits.');
    } else {
      messages.add('Unknown $bits-bit processor.');
    }

    return _createProcessResult(messages);
  }

  static ProcessResult getErrorProcessorArchitecture(String arch) {
    var messages = [];
    if(arch == null) {
      messages.add('No information about processor architecture.');
    } else {
      messages.add('Unknown $arch central processor.');
    }

    return _createProcessResult(messages);
  }

  static ProcessResult getErrorConfigurationMethod(
      ProjectConfigurationMethod method) {
    var messages = ['Project configuration method "$method" not supported.'];
    return _createProcessResult(messages);
  }

  static ProcessResult _createProcessResult(List messages) {
    messages.insertRange(0, 1, 'Error auto configuring project.');
    return new ProjectToolResult.error(-1, Strings.join(messages, '\r\n'), '');
  }
}
