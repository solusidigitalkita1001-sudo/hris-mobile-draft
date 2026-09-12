import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final workflow = File('.github/workflows/mobile-ci.yml').readAsStringSync();

  test('workflow is valid YAML with quality and Android jobs', () {
    final yaml = loadYaml(workflow) as YamlMap;
    final jobs = yaml['jobs'] as YamlMap;
    expect(jobs.keys, containsAll(['quality', 'android']));
  });

  test('CI runs the required quality gates', () {
    expect(workflow, contains('permissions:\n  contents: read'));
    expect(workflow, contains('git diff --exit-code -- pubspec.lock'));
    expect(
      workflow,
      contains('dart format --output=none --set-exit-if-changed lib test tool'),
    );
    expect(workflow, contains('flutter analyze'));
    expect(workflow, contains('flutter test --coverage'));
  });

  test('CI pins Flutter and builds a guarded production artifact', () {
    expect(
      workflow,
      contains('FLUTTER_VERSION: f0bbd8333c91b52d879e7c034645887b5768b43a'),
    );
    expect(workflow, contains('flutter build appbundle --release'));
    expect(workflow, contains('--dart-define=APP_ENV=production'));
    expect(
      workflow,
      contains('--dart-define=BASE_URL=https://ci.invalid/api/v1'),
    );
    expect(workflow, contains('--dart-define=ENABLE_LOGGING=false'));
    expect(
      workflow,
      contains('build/app/outputs/bundle/release/app-release.aab'),
    );
  });
}
