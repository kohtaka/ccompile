class MsvcUtils {
  static Future<String> getEnvironmentScript(String cpuType) {
    if(cpuType == null || (cpuType != 'x86' && cpuType != 'x64')) {
      throw new IllegalArgumentException('cpuType: $cpuType');
    }

    var key = @'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio';

    return WindowsRegistry.queryAllKeys(key).chain((reg) {
      if(reg == null) {
        return new Future.immediate(null);
      }

      var regVC7 = reg[@'SxS\VC7'];
      if(regVC7 == null) {
        return new Future.immediate(null);
      }

      var versions = [];
      for(var version in reg.keys.getKeys()) {
        if(regVC7.values.containsKey(version)) {
          versions.add(regVC7.values[version].value);
        }
      }

      if(versions.length == 0) {
        return new Future.immediate(null);
      }

      var scriptName = '';

      switch(cpuType) {
        case 'x86':
          scriptName = 'vcvars32.bat';
          break;
        case 'x64':
          scriptName = 'vcvarsx86_amd64.bat';
          break;
      }

      if(scriptName.isEmpty()) {
        return new Future.immediate(null);
      }

      var fullScriptPath = '';
      for(var i = versions.length; i > 0; i--) {
        var vc7Path = versions[i - 1];
        var file = new File('${vc7Path}bin\\$scriptName');

        if(file.existsSync()) {
          fullScriptPath = file.fullPathSync();
          break;
        }
      }

      if(fullScriptPath.isEmpty()) {
        return new Future.immediate(null);
      }

      return new Future.immediate(fullScriptPath);
    });
  }

  static Future<Map<String, String>> getEnvironment(String cpuType) {
    if(cpuType == null || (cpuType != 'x86' && cpuType != 'x64')) {
      throw new IllegalArgumentException('cpuType: $cpuType');
    }

    return getEnvironmentScript(cpuType).chain((script) {
      if(script == null) {
        return new Future.immediate(null);
      }

      var executable = '"$script" && set';
      return Process.run(executable, []).chain((result) {
        if(result != null && result.exitCode == 0) {
          var env = new Map<String, String>();
          var exp = const RegExp(@'(^\S+)=(.*)$', true);
          var matches = exp.allMatches(result.stdout);
          for(var match in matches) {
            env[match.group(1)] = match.group(2);
          }

          return new Future.immediate(env);
        }

        return new Future.immediate(null);
      });
    });
  }

  static getCpuType(int bits) {
    return {'32': 'x86', '64': 'x64'}['$bits'];
  }
}
