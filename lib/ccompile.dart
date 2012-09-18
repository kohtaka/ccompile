#library('ccompile');

#import('dart:json');
#import('dart:isolate');
#import('dart:io');
#import('dart:math');

#import('yaml/yaml.dart');

#import('../packages/file_finder/file_finder.dart');

#source('src/cleaner.dart');
#source('src/compiler_settings.dart');
#source('src/dart_utils.dart');
#source('src/file_utils.dart');
#source('src/future_utils.dart');
#source('src/gnu_compiler.dart');
#source('src/gnu_linker.dart');
#source('src/linker_settings.dart');
#source('src/msvc_compiler.dart');
#source('src/msvc_linker.dart');
#source('src/msvc_utils.dart');
#source('src/project.dart');
#source('src/project_builder.dart');
#source('src/project_tool.dart');
#source('src/project_tool_result.dart');
#source('src/system_utils.dart');
#source('src/windows_registry.dart');
#source('src/windows_utils.dart');
