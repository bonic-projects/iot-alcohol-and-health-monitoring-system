import 'package:flutter_test/flutter_test.dart';
import 'package:alcohol_and_health_monitoring/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('DatabsaeServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
