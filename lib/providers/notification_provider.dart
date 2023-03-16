import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  Future<void> addNotification(NotificationModel notificationModel) {
    return DbHelper.addNotification(notificationModel);
  }

  /*getUserInfo() {
    DbHelper.getUserInfo(AuthService.currentUser!.uid).listen((snapshot) {
      if (snapshot.exists) {
        userModel = UserModel.fromMap(snapshot.data()!);
        notifyListeners();
      }
    });
  }
*/

}
