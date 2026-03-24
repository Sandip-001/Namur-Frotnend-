import 'package:flutter/material.dart';

class CalendarEvent {
  final String stage;
  final List<String> events;
  CalendarEvent({required this.stage, required this.events});
}

class RentalItem {
  final String imageUrl;
  final String rate;
  RentalItem({required this.imageUrl, required this.rate});
}

class CropCalendarProvider extends ChangeNotifier {
  List<CalendarEvent> events = [
    CalendarEvent(stage: "Stage-1", events: [
      "10 Mar 23: Onion Seeding",
      "20 Mar 23: Watering Field",
    ]),
    CalendarEvent(stage: "Stage-2", events: [
      "Today: Remove Weeds B/N Onion Lines",
      "Tomorrow: Spray Neem Oil for Pest Control",
    ]),
    CalendarEvent(stage: "Stage-3", events: [
      "30 Apr 23: Plan For Harvest",
      "30 Apr 23: Plan For Harvest",
    ]),
    CalendarEvent(stage: "Stage-4", events: [
      "05 May 23: 5 Labors Required for Harvesting",
    ]),
  ];

  List<RentalItem> rentals = [
    RentalItem(
        imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2FmanAndMcs%2F02_JCB.png?alt=media&token=c90db698-f547-47fa-b226-ee4866849b7e',
        rate: "@750/Hr"),
    RentalItem(
        imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2FmanAndMcs%2FTractor.png?alt=media&token=42e725b1-8142-4258-a1a4-caafd6cf9ee8',
        rate: "@500/Day"),
    RentalItem(
        imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2FmanAndMcs%2FShredder.png?alt=media&token=51013d9e-da12-441e-8878-86d23b1b0d42',
        rate: "@1000/Day"),
    RentalItem(
        imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2Fanimals%2F10_Others.png?alt=media&token=8955e742-55c2-4f92-9aa3-522f75f7bdb0',
        rate: "@750/Day"),
  ];
}
