class UnixUtils {
  Future<ProcessResult> uname(List arguments) {
    return Process.run('uname', arguments);
  }

  Future<String> getMachineHardwareName() {
    return uname(['-m']).chain((result) {
      if(result.exitCode == 0) {
        return new Future.immediate(result.stdout);
      }

      return new Future.immediate('');
    });
  }
}
