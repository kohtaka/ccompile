class FileUtils {
  static String correctPathSeparators(String path) {
    var to = Platform.pathSeparator;
    var from = to == '\\' ? '/' : '\\';

    if(path != null && path is String) {
      path = path.replaceAll(from, to);
    }

    return path;
  }

  static int readAsListSync(RandomAccessFile fp, List<int> buffer, int position) {
    fp.setPositionSync(position);
    if(fp.positionSync() != position) {
      return 0;
    }

    return fp.readListSync(buffer, 0, buffer.length);
  }

  static String readAsTextSync(String filename) {
    var file = new File(filename);
    if(!file.existsSync()) {
      throw('File "$filename" not found.');
    }

    return file.readAsTextSync();
  }

  static void findFiles(List<String> files, String directory, bool recursive) {
    var workDir = new Directory(directory);
    var lister = workDir.list(recursive);
  }

  static void foo() {
  }

  static List<String> _matchFiles(List<String> filenames, List variants) {
    var results = [];
    for(var filename in filenames) {
      var parts = filename.split('.');
      var len = parts.length;
      for(var exprs in variants) {
        if(len != exprs.length) {
          continue;
        }

        var found = true;
        for(var i = 0; i < len; i++) {
          if(!exprs[i].allMatches(parts[i]).iterator().hasNext()) {
            found = false;
            break;
          }
        }

        if(found) {
          results.add(filename);
          break;
        }
      }
    }

    return results;
  }

  static List _metachars = const ['[', ']', '\\', '^', @'$', '|', '+', '(', ')'];

  static List _filemaskToRegExp(String filemask, ignoreCase) {
    var exprs = [];
    if(filemask == null) {
      return exprs;
    }

    for(var pattern in filemask.split('.')) {
      pattern = pattern.replaceAll('*', '.*');
      pattern = pattern.replaceAll('?', '.');

      for(var metachar in _metachars) {
        pattern = pattern.replaceAll('$metachar', '\\$metachar');
      }

      exprs.add(new RegExp(pattern, false, ignoreCase));
    }

    return exprs;
  }
}

class FileFinder {
  List<String> filters = [];

  bool searchForFiles = true;

  bool searchForDirs = false;

  bool recursive = false;

  String workingDirectory;

  Future<List<String>> find() {
    Path workingPath;
    if(workingDirectory == null) {
      workingPath = new Path(new Directory.current().path);
    } else {
      workingPath = new Path(workingDirectory);
      if(!workingPath.isAbsolute) {
        workingPath = new Path(new Directory.current().path)
          .append(workingDirectory);
      }
    }

    var dirs = {};
    for(var filter in filters) {
      var path = new Path(filter);
      if(!path.isAbsolute) {
        path = workingPath.append(filter);
      }

      var key = path.directoryPath.toNativePath();
      if(!dirs.containsKey(key)) {
        dirs[key] = [];
      }

      dirs[key].add(path.filename);
    }

    var listers = [];

    for(var key in dirs.getKeys()) {
      var dir = new Directory(key);
      var lister = new FilteredDirectoryLister(dir, dirs[key], recursive);
      listers.add(lister);
    }
  }
}

class FilteredDirectoryLister implements DirectoryLister {
  static List _meta = const ['[', ']', '\\', '^', @'$', '|', '+', '(', ')'];

  DirectoryLister _lister;

  Function _onDir;

  Function _onFile;

  List<List<RegExp>> _variants;

  FilteredDirectoryLister(Directory dir, List<String> filemasks,
      [bool recursive]) {
    _lister = dir.list(recursive);
    _lister.onDir = _filterDir;
    _lister.onFile = _filterFile;

    var ignoreCase = Platform.operatingSystem == 'windows';

    for(var filemask in filemasks) {
      _variants.add(_filemaskToRegExp(filemask, ignoreCase));
    }
  }

  void set onDir(void onDir(String dir)) {
    _onDir = onDir;
  }

  void set onFile(void onFile(String file)) {
    _onFile = onFile;
  }

  void set onDone(void onDone(bool completed)) {
    _lister.onDone = onDone;
  }

  void set onError(void onError(e)) {
    _lister.onError = onError;
  }

  void _filterDir(String dir) {
    _filter(dir, _onDir);
  }

  void _filterFile(String file) {
    _filter(file, _onFile);
  }

  void _filter(String filename, Function cb) {
    if(cb == null) {
      return;
    }

    if(_match(filename, _variants)) {
      cb(filename);
    }
  }

  List<RegExp> _filemaskToRegExp(String filemask, ignoreCase) {
    var exprs = [];
    if(filemask == null) {
      return exprs;
    }

    for(var pattern in filemask.split('.')) {
      pattern = pattern.replaceAll('*', '.*');
      pattern = pattern.replaceAll('?', '.');

      for(var ch in _meta) {
        pattern = pattern.replaceAll('$ch', '\\$ch');
      }

      exprs.add(new RegExp(pattern, false, ignoreCase));
    }

    return exprs;
  }

  bool _match(String filename, List<List<RegExp>> variants) {
    var found = false;
    var parts = filename.split('.');
    var len = parts.length;
    for(var exprs in variants) {
      if(len != exprs.length) {
        continue;
      }

      var found = true;
      for(var i = 0; i < len; i++) {
        if(!exprs[i].allMatches(parts[i]).iterator().hasNext()) {
          found = false;
          break;
        }
      }

      if(found) {
        break;
      }
    }

    return found;
  }
}
