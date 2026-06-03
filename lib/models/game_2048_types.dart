enum Direction2048 { up, down, left, right }

class Tile2048 {
  final int id;
  final int value;
  final int row;
  final int col;
  final bool isNew;
  final bool isMerged;

  const Tile2048({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.isNew = false,
    this.isMerged = false,
  });

  Tile2048 copyWith({
    int? value,
    int? row,
    int? col,
    bool? isNew,
    bool? isMerged,
  }) =>
      Tile2048(
        id: id,
        value: value ?? this.value,
        row: row ?? this.row,
        col: col ?? this.col,
        isNew: isNew ?? this.isNew,
        isMerged: isMerged ?? this.isMerged,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value,
        'row': row,
        'col': col,
      };

  factory Tile2048.fromJson(Map<String, dynamic> json) => Tile2048(
        id: json['id'] as int,
        value: json['value'] as int,
        row: json['row'] as int,
        col: json['col'] as int,
      );
}

// Tile colors tuned for PuzzleBox dark theme
const Map<int, int> tileColors = {
  2: 0xFF3D3D5C,
  4: 0xFF4A3D6B,
  8: 0xFF6B3D8A,
  16: 0xFF8B3DAF,
  32: 0xFFA0375C,
  64: 0xFFBF3030,
  128: 0xFFD4730A,
  256: 0xFFD4960A,
  512: 0xFFB8A800,
  1024: 0xFF7B8A00,
  2048: 0xFF4CAF50,
};

int tileColor(int value) => tileColors[value] ?? 0xFF2A2A3E;

bool tileUseLightText(int value) => value >= 8;
