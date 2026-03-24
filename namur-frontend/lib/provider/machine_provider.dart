import 'package:flutter/material.dart';
import '../models/machine_model.dart';

class MachineProvider extends ChangeNotifier {
  final Machine _machine = Machine(
    id: '1',
    name: 'JCB 3DX',
    model: '2018 Model',
    price: 36.6,
    imageUrl: 'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2FmanAndMcs%2F02_JCB.png?alt=media&token=c90db698-f547-47fa-b226-ee4866849b7e',
    ownerName: 'Kumar Swamy',
    ownerNumber: 'KA 05 MB 8578',
    vehicleNo: 'KA 05 MB 8578',
    rating: 4.5,
    runningHrs: 250,
    kms: 40000,
  );

  Machine get machine => _machine;
}
