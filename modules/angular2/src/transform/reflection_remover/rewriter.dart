library angular2.transform.reflection_remover.rewriter;

import 'package:analyzer/src/generated/ast.dart';
import 'package:angular2/src/transform/common/logging.dart';
import 'package:angular2/src/transform/common/mirror_mode.dart';
import 'package:angular2/src/transform/common/names.dart';
import 'package:path/path.dart' as path;

import 'ast_tester.dart';
import 'codegen.dart';

class Rewriter {
  final String _code;
  final Codegen _codegen;
  final AstTester _tester;
  final MirrorMode _mirrorMode;
  final bool _writeStaticInit;

  Rewriter(this._code, this._codegen, {AstTester tester,
      MirrorMode mirrorMode: MirrorMode.none, bool writeStaticInit: true})
      : _mirrorMode = mirrorMode,
        _writeStaticInit = writeStaticInit,
        _tester = tester == null ? const AstTester() : tester;

  /// Rewrites the provided code removing imports of the
  /// {@link ReflectionCapabilities} library and instantiations of
  /// {@link ReflectionCapabilities}, as detected by the (potentially) provided
  /// {@link AstTester}.
  ///
  /// To the extent possible, this method does not change line numbers or
  /// offsets in the provided code to facilitate debugging via source maps.
  String rewrite(CompilationUnit node) {
    if (node == null) throw new ArgumentError.notNull('node');

    var visitor = new _FindPartsVisitor(_tester);
    node.accept(visitor);
    if (visitor.angular2Import == null) {
      logger.error('Failed to find ${ANGULAR_IMPORT} import.');
      return _code;
    }
    if (visitor.bootstrapCall == null) {
      logger.error('Failed to find ${BOOTSTRAP_NAME} invocation.');
      return _code;
    }

    var buf = new StringBuffer();
    buf.write(_code.substring(0, visitor.angular2Import.offset));
    buf.write('import \'$ANGULAR_STATIC_IMPORT\';');
    buf.write(_codegen.codegenImport());
    buf.write(_code.substring(
        visitor.angular2Import.end, visitor.bootstrapCall.offset));
    buf.write(_codegen.codegenBootstrapCall(visitor.bootstrapCall));
    // need the +1 to get rid of the semicolon.
    buf.write(_code.substring(visitor.bootstrapCall.end + 1));
    return '$buf';
  }

//    var importAdded = false;
//    var buf = new StringBuffer();
//    var idx = visitor.reflectionCapabilityImports.fold(0,
//        (int lastIdx, ImportDirective node) {
//      buf.write(_code.substring(lastIdx, node.offset));
//      if ('${node.prefix}' == _codegen.prefix) {
//        logger.warning(
//            'Found import prefix "${_codegen.prefix}" in source file.'
//            ' Transform may not succeed.');
//      }
//      if (_mirrorMode != MirrorMode.none) {
//        buf.write(_importDebugReflectionCapabilities(node));
//      } else {
//        buf.write(_commentedNode(node));
//      }
//      if (!importAdded && _writeStaticInit) {
//        buf.write(_codegen.codegenImport());
//        importAdded = true;
//      }
//      return node.end;
//    });
//
//    var setupAdded = false;
//    idx = visitor.reflectionCapabilityAssignments.fold(idx,
//        (int lastIdx, AssignmentExpression assignNode) {
//      var node = assignNode;
//      while (node.parent is ExpressionStatement) {
//        node = node.parent;
//      }
//      buf.write(_code.substring(lastIdx, node.offset));
//      switch (_mirrorMode) {
//        case MirrorMode.debug:
//          buf.write(node);
//          break;
//        case MirrorMode.verbose:
//          buf.write(_instantiateVerboseReflectionCapabilities(assignNode));
//          break;
//        case MirrorMode.none:
//        default:
//          buf.write(_commentedNode(node));
//          break;
//      }
//      if (!setupAdded && _writeStaticInit) {
//        buf.write(_codegen.codegenSetupReflectionCall(
//            reflectorAssignment: assignNode));
//        setupAdded = true;
//      }
//      return node.end;
//    });
//    if (idx < _code.length) buf.write(_code.substring(idx));
//    return buf.toString();
//  }

//  String _instantiateVerboseReflectionCapabilities(
//      AssignmentExpression assignNode) {
//    if (assignNode.rightHandSide is! InstanceCreationExpression) {
//      return '$assignNode;';
//    }
//    var rhs = (assignNode.rightHandSide as InstanceCreationExpression);
//    return '${assignNode.leftHandSide} ${assignNode.operator} '
//        'new ${rhs.constructorName}(verbose: true);';
//  }
//
//  String _importDebugReflectionCapabilities(ImportDirective node) {
//    var uri = '${node.uri}';
//    uri = path
//        .join(path.dirname(uri), 'debug_${path.basename(uri)}')
//        .replaceAll('\\', '/');
//    var asClause = node.prefix != null ? ' as ${node.prefix}' : '';
//    return 'import $uri$asClause;';
//  }
//
//  String _commentedNode(AstNode node) {
//    return '/*${_code.substring(node.offset, node.end)}*/';
//  }
}

/// Visitor responsible for finding the Angular 2 `boostrap` call and import to
/// 1angular2.dart`.
class _FindPartsVisitor extends RecursiveAstVisitor {
  ImportDirective angular2Import;
  MethodInvocation bootstrapCall;
  final AstTester _tester;

  _FindPartsVisitor(this._tester);

  @override
  visitImportDirective(ImportDirective node) {
    if (_tester.isAngular2Import(node)) {
      angular2Import = node;
    }
  }

  @override visitMethodInvocation(MethodInvocation node) {
    if (_tester.isBootstrap(node)) {
      bootstrapCall = node;
    }
  }
}
