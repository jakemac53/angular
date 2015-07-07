library angular2.transform.reflection_remover.codegen;

import 'package:analyzer/src/generated/ast.dart';
import 'package:path/path.dart' as path;

import 'package:angular2/src/transform/common/names.dart';

class Codegen {
  static const _PREFIX_BASE = 'ngStaticInit';

  /// The prefix used to import our generated file.
  final String prefix;
  /// The import uris
  final String importUri;

  Codegen(String entryPointPath, {String prefix})
      : this.prefix = prefix == null ? _PREFIX_BASE : prefix,
        importUri = '${path.basename(path.withoutExtension(entryPointPath))}'
            '$DEPS_EXTENSION' {
    if (this.prefix.isEmpty) throw new ArgumentError.value('(empty)', 'prefix');
  }

  /// Generates code to import the library containing the method which sets up
  /// Angular2 reflection statically.
  ///
  /// The code generated here should follow the example of code generated for
  /// an {@link ImportDirective} node.
  String codegenImport() {
    return 'import \'${importUri}\' as ${prefix};';
  }

  /// Generates code to call the `bootstrapStatic` method which sets up Angular2
  /// reflection statically. Takes in the original call to bootstrap as an
  /// argument, so it can pass in the same values.
  String codegenBootstrapCall(MethodInvocation originalBootstrap) {
    var originalArgs = originalBootstrap.argumentList.arguments;
    assert(originalArgs.length >= 1);
    var extraArgs = '';
    if (originalArgs.length > 1) {
      extraArgs = ', ' + originalArgs.getRange(1, originalArgs.length).map(
        (Expression argument) => '$argument').join(', ');
    }
    return 'bootstrapStatic(${originalArgs[0]}, ${prefix}.${SETUP_METHOD_NAME}'
        '$extraArgs);';
  }
}
