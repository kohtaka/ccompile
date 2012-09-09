#library('ccompile');

#import('dart:json');
#import('dart:isolate');
#import('dart:io');
#import('dart:math');

#import('lib/yaml/yaml.dart');

#source('lib/compiler_settings.dart');
#source('lib/dart_sdk.dart');
#source('lib/file_utils.dart');
#source('lib/future_utils.dart');
#source('lib/gnu_compiler.dart');
#source('lib/gnu_linker.dart');
#source('lib/linker_settings.dart');
#source('lib/msvc_compiler.dart');
#source('lib/msvc_linker.dart');
#source('lib/msvc_utils.dart');
#source('lib/path_utils.dart');
#source('lib/project.dart');
#source('lib/project_builder.dart');
#source('lib/project_tool.dart');
#source('lib/system_utils.dart');
#source('lib/unix_cleaner.dart');
#source('lib/windows_cleaner.dart');
#source('lib/windows_registry.dart');
#source('lib/windows_utils.dart');
