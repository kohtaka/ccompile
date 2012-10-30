library sample_extension;

import "dart-ext:sample_extension";

class SampleExtension {
  String getHello() native "GetHello";
}