import 'package:isar/isar.dart';
import 'package:my_teacher_wallet/data/models/payment_record.dart';
import 'package:my_teacher_wallet/data/models/student.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;
  //we define db that we want to use as late
  IsarService() {
    db = openDB();
    //open DB for use.
  }

  Future<Isar> openDB() async {
    var dir = await getApplicationDocumentsDirectory();

    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        //open isar
        [StudentSchema, PaymentRecordSchema],
        directory: dir.path,

      );
    }
    return Future.value(Isar.getInstance());
  }
}