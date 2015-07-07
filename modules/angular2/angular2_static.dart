export 'angular2_exports.dart';
export 'src/core/application_common.dart';

Future<ApplicationRef> bootstrap(
    Type appComponentType, Function reflectorInitializerFn,
    [List componentInjectableBindings = null, Function errorReporter = null]) {
  try {
    reflectorInitializerFn();
  } catch(e, s) {
    print('Failed to properly initialize your app. This is likely a bug related'
        'to the angular transformer. Please file an issue here: '
        'https://github.com/angular/angular/issues/new.');
    print('Error:\n $e');
    print('Stack Trace:\n $s');
  }
  return bootstrap(appComponentType, componentInjectableBindings, errorReporter);
}
