import 'package:hive/hive.dart';
import 'pending_ad.dart';

class PendingAdAdapter extends TypeAdapter<PendingAd> {
  @override
  final int typeId = 1;

  @override
  PendingAd read(BinaryReader reader) {
    return PendingAd(
      title: reader.readString(),
      categoryId: reader.readString(),
      subCategoryId: reader.readString(),
      productId: reader.readString(),
      productName: reader.readString(),
      quantity: reader.readString(),
      price: reader.readString(),
      description: reader.readString(),
      brand: reader.read(),
      model: reader.read(),
      manufactureYear: reader.read(),
      registrationNo: reader.read(),
      prevOwners: reader.read(),
      drivenHours: reader.read(),
      kmsCovered: reader.read(),
      images: (reader.read() as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PendingAd obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.categoryId);
    writer.writeString(obj.subCategoryId);
    writer.writeString(obj.productId);
    writer.writeString(obj.productName);
    writer.writeString(obj.quantity);
    writer.writeString(obj.price);
    writer.writeString(obj.description);
    writer.write(obj.brand);
    writer.write(obj.model);
    writer.write(obj.manufactureYear);
    writer.write(obj.registrationNo);
    writer.write(obj.prevOwners);
    writer.write(obj.drivenHours);
    writer.write(obj.kmsCovered);
    writer.write(obj.images);
  }
}
