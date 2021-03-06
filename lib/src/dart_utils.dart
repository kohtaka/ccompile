part of ccompile;

class DartUtils {
  static String getSdkFolder() {
    var path = Platform.environment['DART_SDK'];
    if(path == null) {
      return null;
    }

    if(path.endsWith('\\') || path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    return path;
  }

  static int getVmBits() {
    const ELFCLASS32 = 0x1;
    const ELFCLASS64 = 0x2;
    const MH_MAGIC = 0xFEEDFACE;
    const MH_MAGIC_64 = 0xFEEDFACF;
    const IMAGE_FILE_MACHINE_I386 = 0x14C;
    const IMAGE_FILE_MACHINE_AMD64 = 0x8664;
    var bits = null;

    var dartSdkPath = getSdkFolder();
    if(dartSdkPath == null || dartSdkPath.isEmpty) {
      return bits;
    }

    switch(Platform.operatingSystem) {
      case 'linux':
        switch(_getEIClassFromELF('$dartSdkPath/bin/dart')) {
          case ELFCLASS32:
            bits = 32;
            break;
          case ELFCLASS64:
            bits = 64;
            break;
        }
        break;
      case 'macos':
        switch(_getMHMagicFromPEF('$dartSdkPath/bin/dart')) {
          case MH_MAGIC:
            bits = 32;
            break;
          case MH_MAGIC_64:
            bits = 64;
            break;
        }
        break;
      case 'windows':
        switch(_getBinaryTypeFromPE('$dartSdkPath\\bin\\dart.exe')) {
          case IMAGE_FILE_MACHINE_I386:
            bits = 32;
            break;
          case IMAGE_FILE_MACHINE_AMD64:
            bits = 64;
            break;
        }
        break;
    }

    return bits;
  }

  static int _getEIClassFromELF(String filename) {
    var ELFMAG = 0x464C457F;
    var eiClass = 0;
    var file = new File(filename);

    if(!file.existsSync()) {
      return eiClass;
    }

    var fp = file.openSync(FileMode.READ);
    var buffer = [0, 0, 0, 0];
    if(FileUtils.readAsListSync(fp, buffer, 0) != buffer.length) {
      return eiClass;
    }

    if(_listToLong(buffer) != ELFMAG) {
      return eiClass;
    }

    buffer = [0];
    if(FileUtils.readAsListSync(fp, buffer, 4) != buffer.length) {
      return eiClass;
    }

    eiClass = buffer[0];

    fp.closeSync();
    return eiClass;
  }

  static int _getMHMagicFromPEF(String filename) {
    var mhMagic = 0;
    var file = new File(filename);

    if(!file.existsSync()) {
      return mhMagic;
    }

    var fp = file.openSync(FileMode.READ);
    var buffer = [0, 0, 0, 0];
    if(FileUtils.readAsListSync(fp, buffer, 0) != buffer.length) {
      return mhMagic;
    }

    mhMagic = _listToLong(buffer);
    fp.closeSync();
    return mhMagic;
  }

  static int _getBinaryTypeFromPE(String filename) {
    var binaryType = 0;
    var file = new File(filename);

    if(!file.existsSync()) {
      return binaryType;
    }

    var fp = file.openSync(FileMode.READ);
    var func  = (result) {
      var buffer = [0, 0];
      if(FileUtils.readAsListSync(fp, buffer, 0) != buffer.length) {
        return result;
      }

      if(_listToShort(buffer) != 0x5A4D) {
        return result;
      }

      buffer = [0, 0, 0, 0];
      if(FileUtils.readAsListSync(fp, buffer, 0x3C) != buffer.length) {
        return result;
      }

      int offset = _listToLong(buffer);
      if(FileUtils.readAsListSync(fp, buffer, offset) != buffer.length) {
        return result;
      }

      if(_listToLong(buffer) != 0x4550) {
        return result;
      }

      if(FileUtils.readAsListSync(fp, buffer, offset + 4) != buffer.length) {
        return result;
      }

      return _listToShort(buffer);
    };

    binaryType = func(binaryType);
    fp.closeSync();
    return binaryType;
  }

  static int _listToShort(List<int> buffer, {bool reverse: true}) {
    if(reverse) {
      return buffer[0] + buffer[1] * 0x100;
    } else {
      return buffer[0] * 0x100 + buffer[1];
    }
  }

  static int _listToLong(List<int> buffer, {bool reverse: true}) {
    if(reverse) {
      return buffer[0] + buffer[1] * 0x100 + buffer[2] * 0x10000 +
          buffer[3] * 0x1000000;
    } else {
      return buffer[0] * 0x1000000 + buffer[1] * 0x10000 + buffer[2] * 0x100 +
          buffer[3];
    }
  }
}
