// models/transaction_model.dart
class TransactionResponse {
  final List<TransactionData> data;

  TransactionResponse({required this.data});

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      data: (json['data'] as List)
          .map((item) => TransactionData.fromJson(item))
          .toList(),
    );
  }
}

class TransactionData {
  final String username;
  final List<Pemesanan> pemesanans;

  TransactionData({required this.username, required this.pemesanans});

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      username: json['username'] ?? '',
      pemesanans: (json['pemesanans'] as List)
          .map((item) => Pemesanan.fromJson(item))
          .toList(),
    );
  }
}

class Pemesanan {
  final int idCustomer;
  final int idPesan;
  final List<DetailPemesanan> detailPemesanan;
  final List<Transaksi> transaksis;

  Pemesanan({
    required this.idCustomer,
    required this.idPesan,
    required this.detailPemesanan,
    required this.transaksis,
  });

  factory Pemesanan.fromJson(Map<String, dynamic> json) {
    return Pemesanan(
      idCustomer: json['id_customer'] ?? 0,
      idPesan: json['id_pesan'] ?? 0,
      detailPemesanan: (json['detailPemesanan'] as List)
          .map((item) => DetailPemesanan.fromJson(item))
          .toList(),
      transaksis: (json['transaksis'] as List)
          .map((item) => Transaksi.fromJson(item))
          .toList(),
    );
  }
}

class DetailPemesanan {
  final int quantity;
  final int total;
  final Tiket tiket;

  DetailPemesanan({
    required this.quantity,
    required this.total,
    required this.tiket,
  });

  factory DetailPemesanan.fromJson(Map<String, dynamic> json) {
    return DetailPemesanan(
      quantity: json['quantity'] ?? 0,
      total: json['total'] ?? 0,
      tiket: Tiket.fromJson(json['tiket'] ?? {}),
    );
  }
}

class Tiket {
  final int idCategory;
  final int idTiket;
  final Category category;
  final Event event;

  Tiket({
    required this.idCategory,
    required this.idTiket,
    required this.category,
    required this.event,
  });

  factory Tiket.fromJson(Map<String, dynamic> json) {
    return Tiket(
      idCategory: json['id_category'] ?? 0,
      idTiket: json['id_tiket'] ?? 0,
      category: Category.fromJson(json['category'] ?? {}),
      event: Event.fromJson(json['event'] ?? {}),
    );
  }
}

class Category {
  final String nama;
  final String posisi;

  Category({required this.nama, required this.posisi});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(nama: json['nama'] ?? '', posisi: json['posisi'] ?? '');
  }
}

class Event {
  final String namaEvent;
  final String image;
  final DateTime waktu;

  Event({required this.namaEvent, required this.image, required this.waktu});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      namaEvent: json['nama_event'] ?? '',
      image: json['image'] ?? '',
      waktu: DateTime.tryParse(json['waktu'] ?? '') ?? DateTime.now(),
    );
  }
}

class Transaksi {
  final int idTransaksi;
  final int idMetode;
  final String status;
  final MetodePembayaran metodePembayaran;

  Transaksi({
    required this.idTransaksi,
    required this.idMetode,
    required this.status,
    required this.metodePembayaran,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    return Transaksi(
      idTransaksi: json['id_transaksi'] ?? 0,
      idMetode: json['id_metode'] ?? 0,
      status: json['status'] ?? '',
      metodePembayaran: MetodePembayaran.fromJson(
        json['metodePembayaran'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_transaksi': idTransaksi,
      'id_metode': idMetode,
      'status': status,
      'metodePembayaran': metodePembayaran.toJson(),
    };
  }
}

class MetodePembayaran {
  final String nama;

  MetodePembayaran({required this.nama});

  factory MetodePembayaran.fromJson(Map<String, dynamic> json) {
    return MetodePembayaran(nama: json['nama'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'nama': nama};
  }
}
