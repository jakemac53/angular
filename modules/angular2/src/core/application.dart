library angular2.src.core.application.dart;

import "package:angular2/src/reflection/reflection.dart" show reflector;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;

export 'application_common.dart' hide bootstrap;
import 'application_common.dart' as common show bootsrap;

Future<ApplicationRef> bootstrap(
    Type appComponentType,
    [List componentInjectableBindings = null, Function errorReporter = null]) {
  reflector.reflectionCapabilities = new ReflectionCapabilities();
  return
      bootstrap(appComponentType, componentInjectableBindings, errorReporter);
}
