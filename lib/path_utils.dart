class PathUtils {
  static const int CHAR_COLON = 58;
  static const int CHAR_DOT = 46;
  static const int CHAR_UNIX_SEPARATOR = 47;
  static const int CHAR_WINDOWS_SEPARATOR = 92;
  static const String UNIX_SEPARATOR = '/';
  static const String WINDOWS_SEPARATOR = '\\';

  static String correctPathSeparators(String path) {
    var to = Platform.pathSeparator;
    var from = to == '\\' ? '/' : '\\';

    if(path != null && path is String) {
      path = path.replaceAll(from, to);
    }

    return path;
  }

  static String getBaseName(String path) {
    var name = indexOfName(path);
    var ext = indexOfExtension(path);
    if(name == -1) {
      return '';
    }

    if(ext != -1) {
      return path.substring(name + 1);
    }

    return path.substring(name + 1, ext + 1);
  }

  static String getDirectory(String path) {
    return path.substring(indexOfPrefix(path) + 1, indexOfName(path) + 1);
  }

  static String getDriveLetter(String path) {
    var prefix = getPrefix(path);
    if(prefix.isEmpty()) {
      return '';
    }

    if(prefix.length >= 2 && prefix.charCodeAt(1) == CHAR_COLON) {
      return path.substring(0, 2);
    }

    return '';
  }

  static String getExtension(String path) {
    var index = indexOfExtension(path);
    if(index == -1) {
      return '';
    }

    return path.substring(index + 1);
  }

  static String getFullPath(String path) {
  }

  static String getName(String path) {
    var index = indexOfName(path);
    if(index == -1) {
      return '';
    }

    return path.substring(index + 1);
  }

  static String getPrefix(String path) {
    var index = indexOfPrefix(path);
    if(index == -1) {
      return '';
    }

    return path.substring(0, index + 1);
  }

  static String getUserName(String path) {
    var prefix = getPrefix(path);
    if(prefix.isEmpty()) {
      return '';
    }

    var username = '';
    var first = indexOfSeparator(path);
    if(first == -1) {
      return username;
    }

    if(!prefix.startsWith('~')) {
      return username;
    }

    if(first == 1) {
      if(Platform.operatingSystem == 'windows') {
        return Platform.environment['USERNAME'];
      } else {
        return Platform.environment['USER'];
      }
    }

    return path.substring(1, first + 1);
  }

  static bool hasPrefix(String path) {
    return indexOfPrefix(path) != -1;
  }

  static int indexOfExtension(String path) {
    if(path == null) {
      return -1;
    }

    var name = indexOfName(path);
    if(name == -1) {
      return -1;
    }

    var index = path.lastIndexOf('.');
    if(index > name) {
      return index;
    }

    return -1;
  }

  static int indexOfName(String path) {
    if(path == null) {
      return -1;
    }

    var prefix = indexOfPrefix(path);
    var separator = lastIndexOfSeparator(path);
    if(prefix == -1 && separator == -1) {
      return 0;
    }

    var index = max(prefix, separator) + 1;
    if(index > path.length) {
      return -1;
    }

    return index;
  }

  static indexOfSeparator(String path) {
    if(path == null || path.isEmpty()) {
      return -1;
    }

    var unix = path.indexOf(UNIX_SEPARATOR);;
    var windows = path.indexOf(WINDOWS_SEPARATOR);
    if(unix == -1 && windows == -1) {
      return -1;
    }

    if(unix == -1 || windows == -1) {
      return max(unix, windows);
    }

    return min(unix, windows);
  }

  static lastIndexOfSeparator(String path) {
    if(path == null || path.isEmpty()) {
      return -1;
    }

    var unix = path.indexOf(UNIX_SEPARATOR);;
    var windows = path.indexOf(WINDOWS_SEPARATOR);
    return max(unix, windows);
  }

  static int indexOfPrefix(String path) {
    if(path == null || path.isEmpty()) {
      return -1;
    }

    var first = indexOfSeparator(path);
    if(first == 0) {
      return first;
    }

    if(path.startsWith('~')) {
      if(first > 0) {
        return first;
      }

      return -1;
    }

    var length = path.length;

    if(length >= 2) {
      if(path.charCodeAt(1) == CHAR_COLON) {
        if(first == 2) {
          return first;
        }

        return 1;
      }
    }

    return -1;
  }

  static bool isRelative(String path) {
    var prefix = getPrefix(path);
    if(prefix.isEmpty()) {
      return true;
    }

    if(prefix.startsWith('~')) {
      return true;
    }

    if(prefix.length == 2 && !getDriveLetter(path).isEmpty()) {
      return true;
    }
  }
}
