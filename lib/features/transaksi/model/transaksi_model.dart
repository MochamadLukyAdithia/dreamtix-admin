// models/transaction_model.dart
class TransactionResponse {
  final List<Transaction> data;

  TransactionResponse({required this.data});

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      data: (json['data'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList(),
    );
  }
}

class Transaction {
  final int idCustomer;
  final int idPesan;
  final DateTime tanggal;
  final List<DetailPemesanan> detailPemesanan;
  final List<TransaksiDetail> transaksis;

  Transaction({
    required this.idCustomer,
    required this.idPesan,
    required this.tanggal,
    required this.detailPemesanan,
    required this.transaksis,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      idCustomer: json['id_customer'],
      idPesan: json['id_pesan'],
      tanggal: DateTime.parse(json['tanggal']),
      detailPemesanan: (json['detailPemesanan'] as List)
          .map((item) => DetailPemesanan.fromJson(item))
          .toList(),
      transaksis: (json['transaksis'] as List)
          .map((item) => TransaksiDetail.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_customer': idCustomer,
      'id_pesan': idPesan,
      'tanggal': tanggal.toIso8601String(),
      'detailPemesanan': detailPemesanan.map((item) => item.toJson()).toList(),
      'transaksis': transaksis.map((item) => item.toJson()).toList(),
    };
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
      quantity: json['quantity'],
      total: json['total'],
      tiket: Tiket.fromJson(json['tiket']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'total': total,
      'tiket': tiket.toJson(),
    };
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
      idCategory: json['id_category'],
      idTiket: json['id_tiket'],
      category: Category.fromJson(json['category']),
      event: Event.fromJson(json['event']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_category': idCategory,
      'id_tiket': idTiket,
      'category': category.toJson(),
      'event': event.toJson(),
    };
  }
}

class Category {
  final String nama;
  final String posisi;

  Category({
    required this.nama,
    required this.posisi,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      nama: json['nama'],
      posisi: json['posisi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'posisi': posisi,
    };
  }
}

class Event {
  final String namaEvent;
  final String image;
  final DateTime waktu;

  Event({
    required this.namaEvent,
    required this.image,
    required this.waktu,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      namaEvent: json['nama_event'],
      image: json['image'],
      waktu: DateTime.parse(json['waktu']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_event': namaEvent,
      'image': image,
      'waktu': waktu.toIso8601String(),
    };
  }
}

class TransaksiDetail {
  final int idMetode;
  final String status;
  final MetodePembayaran metodePembayaran;

  TransaksiDetail({
    required this.idMetode,
    required this.status,
    required this.metodePembayaran,
  });

  factory TransaksiDetail.fromJson(Map<String, dynamic> json) {
    return TransaksiDetail(
      idMetode: json['id_metode'],
      status: json['status'],
      metodePembayaran: MetodePembayaran.fromJson(json['metodePembayaran']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
    return MetodePembayaran(
      nama: json['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
    };
  }
}

// Enum untuk status transaksi
enum PaymentStatus {
  lunas('LUNAS'),
  belumLunas('BELUM LUNAS'),
  dibatalkan('DIBATALKAN');

  const PaymentStatus(this.value);
  final String value;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.belumLunas,
    );
  }
}

// Response model untuk update status
class UpdateStatusResponse {
  final bool success;
  final String message;
  final dynamic data;

  UpdateStatusResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UpdateStatusResponse.fromJson(Map<String, dynamic> json) {
    return UpdateStatusResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}