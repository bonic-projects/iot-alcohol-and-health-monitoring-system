import 'package:alcohol_and_health_monitoring/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:alcohol_and_health_monitoring/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:alcohol_and_health_monitoring/ui/views/home/home_view.dart';
import 'package:alcohol_and_health_monitoring/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:alcohol_and_health_monitoring/services/databsae_service.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    // @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DatabsaeService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
