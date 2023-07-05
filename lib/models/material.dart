import 'package:flutter/widgets.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

class TOTKMaterial {
  String name;
  Image  inventoryIcon;
  String caption;
  String heartsRecovered;
  String cookingEffect;
  String cookingEffectLevel;
  String cookingEffectDurationRaw;
  String cookingEffectTimeBoostDurationRaw;
  String cookingEffectTimeBoostSuccessRate;
  String sellPrice;
  String buyPriceRupees;
  String buyPricePoes;
  String dyeColor;
  String reuseCoolTime;
  String reuseInitCoolTime;
  String cookingTag1;
  String cookingTag2;
  String cookingTag3;
  String cookingTagCustom;
  String cookingTagCustom2;
  String actorName;
  String materialCategory;

  TOTKMaterial({
    required this.name,
    required this.inventoryIcon,
    required this.caption,
    required this.heartsRecovered,
    required this.cookingEffect,
    required this.cookingEffectLevel,
    required this.cookingEffectDurationRaw,
    required this.cookingEffectTimeBoostDurationRaw,
    required this.cookingEffectTimeBoostSuccessRate,
    required this.sellPrice,
    required this.buyPriceRupees,
    required this.buyPricePoes,
    required this.dyeColor,
    required this.reuseCoolTime,
    required this.reuseInitCoolTime,
    required this.cookingTag1,
    required this.cookingTag2,
    required this.cookingTag3,
    required this.cookingTagCustom,
    required this.cookingTagCustom2,
    required this.actorName,
    required this.materialCategory,
  });
}

// Parses the material csv file, and returns a list of TOTKMaterial objects
Future<List<TOTKMaterial>> parseMaterialCSV() async {
  final String csvString = await rootBundle.loadString('assets/csv/materials.csv');
  final List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

  final List<TOTKMaterial> materials = [];

  // Ignore the header row
  for (int i = 1; i < csvData.length; i++) {
    // Extract the row
    final List<dynamic> row = csvData[i];

    // Parse all of row data
    final String name = row[0];
    final String caption = row[2].replaceAll('\n', ' ');
    final String heartsRecovered = row[3].toString();
    final String cookingEffect = row[4];
    final String cookingEffectLevel = row[5].toString();
    final String cookingEffectDurationRaw = row[6].toString();
    final String cookingEffectTimeBoostDurationRaw = row[7].toString();
    final String cookingEffectTimeBoostSuccessRate = row[8].toString();
    final String sellPrice = row[9].toString();
    final String buyPriceRuppees = row[10].toString();
    final String buyPricePoes = row[11].toString();
    final String dyeColor = row[12].toString();
    final String reuseCoolTime = row[13].toString();
    final String reuseInitCoolTime = row[14].toString();
    final String cookingTag1 = row[15];
    final String cookingTag2 = row[16];
    final String cookingTag3 = row[17];
    final String cookingTagCustom = row[18];
    final String cookingTagCustom2 = row[19];
    final String actorName = row[20];
    final String materialCategory = row[21];


    // Get the image from the assets directory
    final Image inventoryIcon = Image.asset('assets/materials/$actorName.png');

    // Create material object
    final TOTKMaterial material = TOTKMaterial(
       name: name,
       inventoryIcon: inventoryIcon,
       caption: caption,
       heartsRecovered: heartsRecovered,
       cookingEffect: cookingEffect,
       cookingEffectLevel: cookingEffectLevel,
       cookingEffectDurationRaw:cookingEffectDurationRaw,
       cookingEffectTimeBoostDurationRaw: cookingEffectTimeBoostDurationRaw,
       cookingEffectTimeBoostSuccessRate: cookingEffectTimeBoostSuccessRate,
       sellPrice: sellPrice,
       buyPriceRupees: buyPriceRuppees,
       buyPricePoes: buyPricePoes,
       dyeColor: dyeColor,
       reuseCoolTime: reuseCoolTime,
       reuseInitCoolTime: reuseInitCoolTime,
       cookingTag1: cookingTag1,
       cookingTag2: cookingTag2,
       cookingTag3: cookingTag3,
       cookingTagCustom: cookingTagCustom,
       cookingTagCustom2: cookingTagCustom2,
       actorName: actorName,
       materialCategory: materialCategory
    );

    // Add to list
    materials.add(material);
  }

  return materials;
}