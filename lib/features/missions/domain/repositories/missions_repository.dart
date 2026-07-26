import '../entities/daily_mission.dart';

abstract class MissionsRepository {
  Future<DailyMission> fetchToday();

  Future<DailyMission> claim(int missionNumber);
}
