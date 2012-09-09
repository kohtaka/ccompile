#library("example_use_sample_extension");

#import("sample_extension.dart");

void main() {
  var ext = new SampleExtension();
  var hello = ext.getHello();
  print(hello);
}