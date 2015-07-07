library angular2.transform.reflection_remover.ast_tester;

import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:angular2/src/transform/common/names.dart';

/// An object that checks for `bootstrap` calls and `angular2.dart` imports
/// syntactically, that is, without resolution information.
class AstTester {
  const AstTester();

  bool isBootstrap(MethodInvocation node) =>
      node.methodName.name == BOOTSTRAP_NAME;

  bool isAngular2Import(ImportDirective node) =>
      node.uri.stringValue == ANGULAR_IMPORT;
}
