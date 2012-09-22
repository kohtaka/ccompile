@echo off
set SCRIPTPATH=%~dp0
set arguments=%*
dart.exe %SCRIPTPATH%ccompile.dart %arguments%