import 'package:flutter/foundation.dart';
import '../features/profile/data/user_repository.dart';
import '../features/profile/data/user_profile_model.dart';

class PointsProvider extends ChangeNotifier {
  final _userRepo = UserRepository();

  UserProfile? _profile;

  UserProfile? get profile => _profile;
  int get points => _profile?.totalPoints ?? 0;
  int get level => _profile?.level ?? 1;
  double get levelProgress => _profile?.levelProgress ?? 0.0;

  Future<void> load() async {
    _profile = await _userRepo.getProfile();
    notifyListeners();
  }

  Future<void> addPoints(int pts) async {
    _profile = await _userRepo.addPoints(pts);
    notifyListeners();
  }

  Future<bool> spendPoints(int pts) async {
    final success = await _userRepo.spendPoints(pts);
    if (success) {
      _profile = await _userRepo.getProfile();
      notifyListeners();
    }
    return success;
  }

  Future<void> refresh() async {
    _profile = await _userRepo.getProfile();
    notifyListeners();
  }
}