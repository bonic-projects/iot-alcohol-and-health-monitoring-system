import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:alcohol_and_health_monitoring/app/app.bottomsheets.dart';
import 'package:alcohol_and_health_monitoring/app/app.locator.dart';
import 'package:alcohol_and_health_monitoring/ui/common/app_strings.dart';
import 'package:alcohol_and_health_monitoring/ui/views/home/home_viewmodel.dart';

import '../helpers/test_helpers.dart';

void main() {
  HomeViewModel getModel() => HomeViewModel();

  group('HomeViewmodelTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());


  });
}
