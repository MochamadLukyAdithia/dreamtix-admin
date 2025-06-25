// models/category.dart
class Category {
  final int idCategory;
  final String nama;
  final String posisi;

  Category({
    required this.idCategory,
    required this.nama,
    required this.posisi,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      idCategory: json['id_category'],
      nama: json['nama'],
      posisi: json['posisi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_category': idCategory,
      'nama': nama,
      'posisi': posisi,
    };
  }
}