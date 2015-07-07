library angular2.test.transform.reflection_remover.reflection_remover_files;

// This file is intentionally formatted as a string to avoid having the
// automatic transformer prettify it.
//
// This file represents transformed user code. Because this code will be
// linked to output by a source map, we cannot change line numbers from the
// original code and we therefore add our generated code on the same line as
// those we are removing.

var code = """
library web_foo;

import 'package:angular2/angular2_static.dart';import 'index.ng_deps.dart' as ngStaticInit;

void main() {
  bootstrapStatic(MyComponent, ngStaticInit.initReflector);
}
""";
