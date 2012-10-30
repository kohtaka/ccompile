part of ccompile;

class MsvcUtils {
  static Future<String> getEnvironmentScript(int bits) {
    if(bits == null || (bits != 32 && bits != 64)) {
      throw new IllegalArgumentException('bits: $bits');
    }

    var key = r'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio';

    return WindowsRegistry.queryAllKeys(key).chain((reg) {
      if(reg == null) {
        return new Future.immediate(null);
      }

      var regVC7 = reg[r'SxS\VC7'];
      if(regVC7 == null) {
        return new Future.immediate(null);
      }

      var versions = [];
      for(var version in reg.keys.keys) {
        if(regVC7.values.containsKey(version)) {
          versions.add(regVC7.values[version].value);
        }
      }

      if(versions.length == 0) {
        return new Future.immediate(null);
      }

      var scriptName = '';

      switch(bits) {
        case 32:
          scriptName = 'vcvars32.bat';
          break;
        case 64:
          scriptName = 'vcvarsx86_amd64.bat';
          break;
      }

      if(scriptName.isEmpty) {
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

      if(fullScriptPath.isEmpty) {
        return new Future.immediate(null);
      }

      return new Future.immediate(fullScriptPath);
    });
  }

  static Future<Map<String, String>> getEnvironment(int bits) {
    if(bits == null || (bits != 32 && bits != 64)) {
      throw new IllegalArgumentException('bits: $bits');
    }

    return getEnvironmentScript(bits).chain((script) {
      if(script == null) {
        return new Future.immediate(null);
      }

      var executable = '"$script" && set';
      return Process.run(executable, []).chain((result) {
        if(result != null && result.exitCode == 0) {
          var env = new Map<String, String>();
          var exp = const RegExp(r'(^\S+)=(.*)$', multiLine: true);
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
}
