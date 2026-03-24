class CropPlanModel {
  final int id;
  final int subCategoryId;
  final int productId;
  final String cropDetails;

  final List<CostEstimate> costEstimate;
  final List<CultivationTip> cultivationTips;
  final List<PestDisease> pasteAndDiseases;
  final List<StageSelection> stagesSelection;

  final String createdAt;
  final String updatedAt;

  final String? subCategoryName;
  final String? productName;

  CropPlanModel({
    required this.id,
    required this.subCategoryId,
    required this.productId,
    required this.cropDetails,
    required this.costEstimate,
    required this.cultivationTips,
    required this.pasteAndDiseases,
    required this.stagesSelection,
    required this.createdAt,
    required this.updatedAt,
    this.subCategoryName,
    this.productName,
  });

  factory CropPlanModel.fromJson(Map<String, dynamic> json) {
    return CropPlanModel(
      id: json["id"] ?? 0,
      subCategoryId: json["sub_category_id"] ?? 0,
      productId: json["product_id"] ?? 0,
      cropDetails: json["crop_details"] ?? "",

      costEstimate: (json["cost_estimate"] as List?)
              ?.map((e) => CostEstimate.fromJson(e))
              .toList() ??
          [],

      cultivationTips: (json["cultivation_tips"] as List?)
              ?.map((e) => CultivationTip.fromJson(e))
              .toList() ??
          [],

      pasteAndDiseases: (json["paste_and_diseases"] as List?)
              ?.where((e) => e != null)
              .map((e) => PestDisease.fromJson(e))
              .toList() ??
          [],

      stagesSelection: (json["stages_selection"] as List?)
              ?.where((e) => e != null)
              .map((e) => StageSelection.fromJson(e))
              .toList() ??
          [],

      createdAt: json["created_at"] ?? "",
      updatedAt: json["updated_at"] ?? "",
      subCategoryName: json["sub_category_name"],
      productName: json["product_name"],
    );
  }
}
class CostEstimate {
  final String cost;
  final String description;

  CostEstimate({required this.cost, required this.description});

  factory CostEstimate.fromJson(Map<String, dynamic> json) {
    return CostEstimate(
      cost: json["cost"],
      description: json["description"],
    );
  }
}
class CultivationTip {
  final String name;
  final String dataUrl;
  final String logoUrl;
  final String imageUrl;

  final List<SubStage> subStages;
  final String youtubeUrl;

  CultivationTip({
    required this.name,
    required this.dataUrl,
    required this.logoUrl,
    required this.imageUrl,
    required this.subStages,
    required this.youtubeUrl,
  });

  factory CultivationTip.fromJson(Map<String, dynamic> json) {
    return CultivationTip(
      name: json["name"],
      dataUrl: json["data_url"],
      logoUrl: json["logo_url"],
      imageUrl: json["image_url"],
      subStages: (json["sub_stages"] as List?)
              ?.where((e) => e != null)
              .map((e) => SubStage.fromJson(e))
              .toList() ??
          [],
      youtubeUrl: json["youtube_url"],
    );
  }
}

class SubStage {
  final String name;
  final String numberOfDays;

  SubStage({required this.name, required this.numberOfDays});

  factory SubStage.fromJson(Map<String, dynamic> json) {
    return SubStage(
      name: json["name"],
      numberOfDays: json["number_of_days"],
    );
  }
}
class PestDisease {
  final String name;
  final String logoUrl;
  final String documentUrl;

  PestDisease({
    required this.name,
    required this.logoUrl,
    required this.documentUrl,
  });

  factory PestDisease.fromJson(Map<String, dynamic> json) {
    return PestDisease(
      name: json["name"],
      logoUrl: json["logo_url"],
      documentUrl: json["document_url"],
    );
  }
}
class StageSelection {
  final String stage;
  final List<StageProblem> problems;
  final String cultivationName;

  StageSelection({
    required this.stage,
    required this.problems,
    required this.cultivationName,
  });

  factory StageSelection.fromJson(Map<String, dynamic> json) {
    return StageSelection(
      stage: json["stage"],
      problems: (json["problems"] as List?)
              ?.where((e) => e != null)
              .map((e) => StageProblem.fromJson(e))
              .toList() ??
          [],
      cultivationName: json["cultivation_name"],
    );
  }
}

class StageProblem {
  final String name;
  final String logoUrl;
  final String documentUrl;

  StageProblem({
    required this.name,
    required this.logoUrl,
    required this.documentUrl,
  });

  factory StageProblem.fromJson(Map<String, dynamic> json) {
    return StageProblem(
      name: json["name"],
      logoUrl: json["logo_url"],
      documentUrl: json["document_url"],
    );
  }
}
