import 'package:uuid/uuid.dart';

class UidGenerator {
  static const Uuid _uid = Uuid();

  static generateUID() => _uid.v4();
}
