part of ccompile;

class WindowsRegistry {
  static Future<String> query(String keyName, List<String> arguments) {
    return Process.run('reg query "$keyName"', arguments).chain((result) {
      if(result.exitCode != 0) {
        return new Future.immediate(null);
      }

      var regVersion = '\r\n! REG.EXE VERSION ';
      var str = result.stdout;
      if(str.startsWith(regVersion)) {
        str = str.substring(regVersion.length + 7);
      } else {
        str = str.substring(2);
      }

      return new Future.immediate(str);
    });
  }

  static Future<WindowsRegistryKey> queryAllKeys(String keyName) {
    return query(keyName, ['/s']).chain((result) {
      if(result == null) {
        return new Future.immediate(null);
      }

      return new Future.immediate(_parseQuerySubkeys(keyName, result));
    });
  }

  static WindowsRegistryKey _parseQuerySubkeys(String queryKey, String queryResult) {
    var map = new LinkedHashMap<String, WindowsRegistryKey>();
    map[queryKey] = new WindowsRegistryKey(queryKey);
    var strings = queryResult.split('\r\n');
    var count = strings.length;
    var index = 0;

    while(true) {
      if(index >= count) {
        break;
      }

      var fullName = strings[index++];
      if(fullName.isEmpty) {
        break;
      }

      var regKey;
      if(!map.containsKey(fullName)) {
        regKey = new WindowsRegistryKey(fullName);
        map[fullName] = regKey;
      } else {
        regKey = map[fullName];
      }

      var parent;
      var parentName = regKey.parentName;
      if(!map.containsKey(parentName)) {
        parent = new WindowsRegistryKey(parentName);
        map[parentName] = parent;
      } else {
        parent = map[parentName];
      }

      parent.keys[regKey.name] = regKey;

      while(true) {
        if(index >= count) {
          break;
        }

        var string = strings[index++];
        if(string.isEmpty) {
          break;
        }

        var value = new WindowsRegistryValue();
        var exp = const RegExp(r'^\s+(\S+)\s+(\S+)\s+(\S.*)');
        var matches = exp.allMatches(string);
        if(matches.iterator().hasNext) {
          var match = matches.iterator().next();
          var name = match[1];
          value.type = match[2];
          value.value = match[3];
          regKey.values[name] = value;
        }
      }
    }

    return map[queryKey];
  }
}

class WindowsRegistryKey {
  final String fullName;

  String _name;

  Map<String, WindowsRegistryKey> keys = {};

  Map<String, WindowsRegistryValue> values = {};

  WindowsRegistryKey(this.fullName) {
    if(fullName == null || fullName.isEmpty || fullName.endsWith('\\')) {
      throw new IllegalArgumentException('fullName: $fullName');
    }

    var index = fullName.lastIndexOf('\\');
    if(index == -1) {
      _name = fullName;
    } else {
      _name = fullName.substring(index + 1);
    }
  }

  String get name => _name;

  String get parentName {
    if(fullName == name) {
      return '';
    }

    return fullName.substring(0, fullName.length - _name.length - 1);
  }

  WindowsRegistryKey operator [](String relativePath) {
    if(relativePath == null) {
      throw new IllegalArgumentException('relativePath: $relativePath');
    }

    if(relativePath.isEmpty) {
      return this;
    }

    var parts = relativePath.split('\\');
    var key = this;
    for(var part in parts) {
      if(key == null) {
        break;
      }

      if(key.keys.containsKey(part)) {
        key = key.keys[part];
        continue;
      }

      break;
    }

    return key;
  }

  String toString() => '$fullName';
}

class WindowsRegistryValue {
  String type;
  String value;

  String toString() => '{$type} $value';
}