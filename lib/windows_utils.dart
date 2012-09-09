class WindowsUtils {
  static String findFileInEnvPath(Map<String, String> env, String filename) {
    if(env == null || filename == null) {
      return filename;
    }

    var paths = {};
    for(var key in env.getKeys()) {
      if(key.toUpperCase() == 'PATH') {
        paths = env[key].split(';');
      }
    }

    for(var i = paths.length; i >= 0; i--) {
      var path = paths[i - 1];
      if(path.isEmpty()) {
        continue;
      }

      if(!path.endsWith('\\')) {
        path = '$path\\';
      }

      path = '${path}$filename';

      var file = new File(path);
      if(file.existsSync()) {
        filename = path;
        break;
      }
    }

    return filename;
  }
}
