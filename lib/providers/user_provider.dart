
import 'package:flutter/material.dart';

import '../db/db_helper.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  Future<void> addUser(UserModel userModel) {
    return DbHelper.addUser(userModel);
  }

  Future<bool> doesUserExist(String uid) => DbHelper.doesUserExist(uid);
}
