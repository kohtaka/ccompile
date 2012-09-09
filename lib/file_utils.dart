class FileUtils {
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
}
