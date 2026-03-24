class Machine {
  final String id;
  final String name;
  final String model;
  final double price;
  final String imageUrl;
  final String ownerName;
  final String ownerNumber;
  final String vehicleNo;
  final double rating;
  final int runningHrs;
  final int kms;

  Machine({
    required this.id,
    required this.name,
    required this.model,
    required this.price,
    required this.imageUrl,
    required this.ownerName,
    required this.ownerNumber,
    required this.vehicleNo,
    required this.rating,
    required this.runningHrs,
    required this.kms,
  });
}
