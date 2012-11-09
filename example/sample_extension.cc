#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "dart_api.h"

Dart_NativeFunction ResolveName(Dart_Handle name, int argc);

DART_EXPORT Dart_Handle sample_extension_Init(Dart_Handle parent_library) {
  if (Dart_IsError(parent_library)) { return parent_library; }

  Dart_Handle result_code = Dart_SetNativeResolver(parent_library, ResolveName);
  if (Dart_IsError(result_code)) return result_code;

  return Dart_Null();
}

Dart_Handle HandleError(Dart_Handle handle) {
  if (Dart_IsError(handle)) Dart_PropagateError(handle);
  return handle;
}

void GetHello(Dart_NativeArguments arguments) {
  Dart_EnterScope();
  Dart_Handle result = HandleError(Dart_NewStringFromCString("Hello from native C++ extension!"));
  Dart_SetReturnValue(arguments, result);
  Dart_ExitScope();
}

struct FunctionLookup {
  const char* name;
  Dart_NativeFunction function;
};

FunctionLookup function_list[] = {
    {"GetHello", GetHello},    
    {NULL, NULL}};

Dart_NativeFunction ResolveName(Dart_Handle name, int argc) {
  if (!Dart_IsString(name)) return NULL;
  Dart_NativeFunction result = NULL;
  Dart_EnterScope();
  const char* cname;
  HandleError(Dart_StringToCString(name, &cname));

  for (int i=0; function_list[i].name != NULL; ++i) {
    if (strcmp(function_list[i].name, cname) == 0) {
      result = function_list[i].function;
      break;
    }
  }
  Dart_ExitScope();
  return result;
}
