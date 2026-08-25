import 'package:isar/isar.dart';
import 'package:my_teacher_wallet/data/datasources/local/payment_local_datasource.dart';
import 'package:my_teacher_wallet/data/models/payment_record.dart';
import 'package:my_teacher_wallet/data/models/student.dart';

class PaymentLocalDatasourceImpl extends PaymentLocalDatasource {
  final Isar isar;
  PaymentLocalDatasourceImpl(this.isar);

  @override
  Future<PaymentRecord> insert(PaymentRecord record, {required Student student}) async {
    await isar.writeTxn(() async {
      await isar.paymentRecords.put(record);
      record.student.value = student;
      await record.student.save();
    });
    return record;
  }

  @override
  Future<void> update(PaymentRecord record) async {
    await isar.writeTxn(() => isar.paymentRecords.put(record));
  }

  @override
  Future<PaymentRecord?> softDelete(int id) async {
    PaymentRecord? record;
    await isar.writeTxn(() async {
      record = await isar.paymentRecords.get(id);
      if (record == null) return;
      record!.isDeleted = true;
      record!.updatedAt = DateTime.now();
      await isar.paymentRecords.put(record!);
    });
    return record;
  }

  @override
  Future<PaymentRecord?> getById(int id) => isar.paymentRecords.get(id);

  @override
  Future<PaymentRecord?> getByUuid(String uuid) =>
      isar.paymentRecords.filter().uuidEqualTo(uuid).findFirst();

  @override
  Future<List<PaymentRecord>> getAllActive() {
    return isar.paymentRecords.filter().isDeletedEqualTo(false).findAll();
  }

  @override
  Future<List<PaymentRecord>> getByMonthRange(DateTime start, DateTime end) {
    return isar.paymentRecords
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .monthGreaterThan(start, include: true)
        .monthLessThan(end, include: true)
        .findAll();
  }

  @override
  Future<List<PaymentRecord>> getUpdatedSince(DateTime? since) {
    if (since == null) return isar.paymentRecords.where().findAll();
    return isar.paymentRecords.filter().updatedAtGreaterThan(since).findAll();
  }

  @override
  Future<void> upsertFromRemote(PaymentRecord incoming, {required Student parent}) async {
    await isar.writeTxn(() async {
      final existing = await isar.paymentRecords
          .filter()
          .uuidEqualTo(incoming.uuid)
          .findFirst();

      if (existing == null) {
        await isar.paymentRecords.put(incoming);
        incoming.student.value = parent;
        await incoming.student.save();
      } else if (incoming.updatedAt!.isAfter(existing.updatedAt!)) {
        existing
          ..month = incoming.month
          ..isPaid = incoming.isPaid
          ..amountPaid = incoming.amountPaid
          ..isExcluded = incoming.isExcluded
          ..updatedAt = incoming.updatedAt
          ..isDeleted = incoming.isDeleted;
        await isar.paymentRecords.put(existing);
      }
    });
  }
}