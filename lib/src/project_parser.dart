class ProjectParser {
  MezoniParser _parser;

  bool hasErrors = false;

  List<String> errors = [];

  Project parse(Map map) {
    if(map == null || map is! Map) {
      throw new IllegalArgumentException('map: $map');
    }

    errors = [];
    hasErrors = false;
    var project = new Project();
    _parser = new MezoniParser(_getFormat());
    _parser.parse(map, project);
    if(_parser.errors.length > 0) {
      hasErrors = true;
      _parser.errors.forEach((error) {
        var msg = 'Invalid section ${error} in data.';
        errors.add(msg);
      });

      return null;
    }

    return project;
  }

  Map<String, ParserCallback> _getFormat() {
    Map<String, ParserCallback> format =
      {'"bits"': bits,
       '[clean]': clean,
       '[clean]:"*"': list_item,
       '{compiler}': compiler,
       '{compiler}:[arguments]': compiler_arguments,
       '{compiler}:[arguments]:"*"': list_item,
       '{compiler}:{defines}': compiler_defines,
       '{compiler}:{defines}:"*"': list_item,
       '{compiler}:"executable"': compiler_executable,
       '{compiler}:[includes]': compiler_includes,
       '{compiler}:[includes]:"*"': list_item,
       '{compiler}:[input_files]': compiler_input_files,
       '{compiler}:[input_files]:"*"': list_item,
       '{linker}': linker,
       '{linker}:[arguments]': linker_arguments,
       '{linker}:[arguments]:"*"': list_item,
       '{linker}:[input_files]': linker_input_files,
       '{linker}:[input_files]:"*"': list_item,
       '{linker}:[libpaths]': linker_libpaths,
       '{linker}:[libpaths]:"*"': list_item,
       '{linker}:"output_file"': linker_output_file,
       '{platforms}': platforms,
       '{platforms}:{*}': platform,

       '{platforms}:{*}:"bits"': bits,
       '{platforms}:{*}:[clean]': clean,
       '{platforms}:{*}:[clean]:"*"': list_item,
       '{platforms}:{*}:{compiler}': compiler,
       '{platforms}:{*}:{compiler}:[arguments]': compiler_arguments,
       '{platforms}:{*}:{compiler}:[arguments]:"*"': list_item,
       '{platforms}:{*}:{compiler}:{defines}': compiler_defines,
       '{platforms}:{*}:{compiler}:{defines}:"*"': map_item,
       '{platforms}:{*}:{compiler}:"executable"': compiler_executable,
       '{platforms}:{*}:{compiler}:[includes]': compiler_includes,
       '{platforms}:{*}:{compiler}:[includes]:"*"': list_item,
       '{platforms}:{*}:{compiler}:[input_files]': compiler_input_files,
       '{platforms}:{*}:{compiler}:[input_files]:"*"': list_item,
       '{platforms}:{*}:{linker}': linker,
       '{platforms}:{*}:{linker}:[arguments]': linker_arguments,
       '{platforms}:{*}:{linker}:[arguments]:"*"': list_item,
       '{platforms}:{*}:{linker}:[input_files]': linker_input_files,
       '{platforms}:{*}:{linker}:[input_files]:"*"': list_item,
       '{platforms}:{*}:{linker}:[libpaths]': linker_libpaths,
       '{platforms}:{*}:{linker}:[libpaths]:"*"': list_item,
       '{platforms}:{*}:{linker}:"output_file"': linker_output_file,
       };

    return format;
  }

  int bits(String key, Dynamic value, Project parent) {
    if(value != null) {
      try {
        parent.bits = int.parse(value);
      } catch(e) {
        throw('Illegal value "$value" for bits. Value may be int or null.');
      }
    }

    return parent.bits;
  }

  List clean(String key, Dynamic value, Project parent) {
    if(parent.clean == null) {
      parent.clean = [];
    }

    return parent.clean;
  }

  CompilerSettings compiler(String key, Dynamic value, Project parent) {
    return parent.compilerSettings;
  }

  List compiler_arguments(String key, Dynamic value, CompilerSettings parent) {
    return parent.arguments;
  }

  List compiler_includes(String key, Dynamic value, CompilerSettings parent) {
    return parent.includes;
  }

  List compiler_input_files(String key, Dynamic value, CompilerSettings parent) {
    return parent.inputFiles;
  }

  Map compiler_defines(String key, Dynamic value, CompilerSettings parent) {
    return parent.defines;
  }

  Dynamic compiler_executable(String key, Dynamic value, CompilerSettings parent) {
    parent.executable = value;
    return value;
  }

  LinkerSettings linker(String key, Dynamic value, Project parent) {
    return parent.linkerSettings;
  }

  List linker_input_files(String key, Dynamic value, LinkerSettings parent) {
    return parent.inputFiles;
  }

  List linker_arguments(String key, Dynamic value, LinkerSettings parent) {
    return parent.arguments;
  }

  Dynamic linker_output_file(String key, Dynamic value, LinkerSettings parent) {
    parent.outputFile = value;
    return value;
  }

  List linker_libpaths(String key, Dynamic value, LinkerSettings parent) {
    return parent.libpaths;
  }

  Project platforms(String key, Dynamic value, Project parent) {
    return parent;
  }

  Project platform(String key, Dynamic value, Project parent) {
    if(key != Platform.operatingSystem) {
      return new Project();
    }

    return parent;
  }

  Dynamic list_item(String key, Dynamic value, List parent) {
    parent.add(value);
    return value;
  }

  Dynamic map_item(String key, Dynamic value, Map parent) {
    parent[key] = value;
    return value;
  }
}
