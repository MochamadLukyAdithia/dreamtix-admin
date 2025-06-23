class Event {
  final String namaEvent;
  final String artis;
  final DateTime waktu;

  Event({
    required this.namaEvent,
    required this.artis,
    required this.waktu,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      namaEvent: json['nama_event'],
      artis: json['artis'],
      waktu: DateTime.parse(json['waktu']),
    );
  }
}

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
}

class Ticket {
  final int idTiket;
  final int idCategory;
  final int idEvent;
  final int harga;
  final int stok;
  final Event event;
  final Category category;

  Ticket({
    required this.idTiket,
    required this.idCategory,
    required this.idEvent,
    required this.harga,
    required this.stok,
    required this.event,
    required this.category,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      idTiket: json['id_tiket'],
      idCategory: json['id_category'],
      idEvent: json['id_event'],
      harga: json['harga'],
      stok: json['stok'],
      event: Event.fromJson(json['event']),
      category: Category.fromJson(json['category']),
    );
  }
}
