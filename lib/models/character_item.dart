enum ItemCategory { hair, eyes, mouth, outfit, accessory }

enum ItemRarity { common, rare, epic, legendary }

extension ItemRarityLabel on ItemRarity {
  String get label {
    switch (this) {
      case ItemRarity.common: return '일반';
      case ItemRarity.rare: return '레어';
      case ItemRarity.epic: return '에픽';
      case ItemRarity.legendary: return '전설';
    }
  }

  int get color {
    switch (this) {
      case ItemRarity.common: return 0xFF9E9E9E;
      case ItemRarity.rare: return 0xFF42A5F5;
      case ItemRarity.epic: return 0xFFAB47BC;
      case ItemRarity.legendary: return 0xFFFFB300;
    }
  }
}

extension ItemCategoryLabel on ItemCategory {
  String get label {
    switch (this) {
      case ItemCategory.hair: return '헤어';
      case ItemCategory.eyes: return '눈';
      case ItemCategory.mouth: return '입';
      case ItemCategory.outfit: return '아우터';
      case ItemCategory.accessory: return '악세사리';
    }
  }

  String get emoji {
    switch (this) {
      case ItemCategory.hair: return '💇';
      case ItemCategory.eyes: return '👁';
      case ItemCategory.mouth: return '👄';
      case ItemCategory.outfit: return '👕';
      case ItemCategory.accessory: return '💍';
    }
  }
}

class CharacterItem {
  final String id;
  final String name;
  final ItemCategory category;
  final ItemRarity rarity;
  final int price;
  // null until pixellab assets arrive — shows placeholder emoji in UI
  final String? assetPath;

  const CharacterItem({
    required this.id,
    required this.name,
    required this.category,
    required this.rarity,
    required this.price,
    this.assetPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'rarity': rarity.name,
        'price': price,
        'asset_path': assetPath,
      };

  factory CharacterItem.fromJson(Map<String, dynamic> json) => CharacterItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: ItemCategory.values.byName(json['category'] as String),
        rarity: ItemRarity.values.byName(json['rarity'] as String),
        price: (json['price'] as num).toInt(),
        assetPath: json['asset_path'] as String?,
      );
}

// Placeholder catalog — replace asset_path once pixellab assets arrive
const List<CharacterItem> defaultItemCatalog = [
  // Hair
  CharacterItem(id: 'hair_001', name: '기본 헤어', category: ItemCategory.hair, rarity: ItemRarity.common, price: 0),
  CharacterItem(id: 'hair_002', name: '포니테일', category: ItemCategory.hair, rarity: ItemRarity.rare, price: 300),
  CharacterItem(id: 'hair_003', name: '왕관 헤어', category: ItemCategory.hair, rarity: ItemRarity.epic, price: 800),
  // Eyes
  CharacterItem(id: 'eyes_001', name: '기본 눈', category: ItemCategory.eyes, rarity: ItemRarity.common, price: 0),
  CharacterItem(id: 'eyes_002', name: '별빛 눈', category: ItemCategory.eyes, rarity: ItemRarity.rare, price: 300),
  CharacterItem(id: 'eyes_003', name: '보석 눈', category: ItemCategory.eyes, rarity: ItemRarity.legendary, price: 1500),
  // Mouth
  CharacterItem(id: 'mouth_001', name: '기본 입', category: ItemCategory.mouth, rarity: ItemRarity.common, price: 0),
  CharacterItem(id: 'mouth_002', name: '미소', category: ItemCategory.mouth, rarity: ItemRarity.rare, price: 200),
  // Outfit
  CharacterItem(id: 'outfit_001', name: '기본 옷', category: ItemCategory.outfit, rarity: ItemRarity.common, price: 0),
  CharacterItem(id: 'outfit_002', name: '후드티', category: ItemCategory.outfit, rarity: ItemRarity.rare, price: 500),
  CharacterItem(id: 'outfit_003', name: '마법사 로브', category: ItemCategory.outfit, rarity: ItemRarity.epic, price: 1000),
  CharacterItem(id: 'outfit_004', name: '천상 드레스', category: ItemCategory.outfit, rarity: ItemRarity.legendary, price: 2000),
  // Accessory
  CharacterItem(id: 'acc_001', name: '기본', category: ItemCategory.accessory, rarity: ItemRarity.common, price: 0),
  CharacterItem(id: 'acc_002', name: '안경', category: ItemCategory.accessory, rarity: ItemRarity.rare, price: 400),
  CharacterItem(id: 'acc_003', name: '날개', category: ItemCategory.accessory, rarity: ItemRarity.epic, price: 900),
];
