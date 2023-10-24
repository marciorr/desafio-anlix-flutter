import '../database/results_database.dart';

class Result {
  Result(
      this.cpf,
      this.epoch,
      this.resultType,
      this.resultData,
      );

  Result.fromMap(final Map<String, dynamic> map) {
    id = map[ResultsDatabase.id] as int;
    cpf = map[ResultsDatabase.cpf] as String;
    epoch = map[ResultsDatabase.epoch] as String;
    resultType = map[ResultsDatabase.resultType] as String;
    resultData = map[ResultsDatabase.resultData] as String;
  }
  int? id;
  late String cpf;
  late String epoch;
  late String resultType;
  late String resultData;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ResultsDatabase.cpf: cpf,
      ResultsDatabase.epoch: epoch,
      ResultsDatabase.resultType: resultType,
      ResultsDatabase.resultData: resultData,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
