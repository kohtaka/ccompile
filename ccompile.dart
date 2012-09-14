#library('ccompile');

#import('dart:json');
#import('dart:isolate');
#import('dart:io');
#import('dart:math');

#import('lib/yaml/yaml.dart');

#source('lib/src/cleaner.dart');
#source('lib/src/compiler_settings.dart');
#source('lib/src/dart_utils.dart');
#source('lib/src/file_utils.dart');
#source('lib/src/future_utils.dart');
#source('lib/src/gnu_compiler.dart');
#source('lib/src/gnu_linker.dart');
#source('lib/src/linker_settings.dart');
#source('lib/src/msvc_compiler.dart');
#source('lib/src/msvc_linker.dart');
#source('lib/src/msvc_utils.dart');
#source('lib/src/project.dart');
#source('lib/src/project_builder.dart');
#source('lib/src/project_tool.dart');
#source('lib/src/project_tool_result.dart');
#source('lib/src/system_utils.dart');
#source('lib/src/unix_cleaner.dart');
#source('lib/src/unix_utils.dart');
#source('lib/src/windows_cleaner.dart');
#source('lib/src/windows_registry.dart');
#source('lib/src/windows_utils.dart');
