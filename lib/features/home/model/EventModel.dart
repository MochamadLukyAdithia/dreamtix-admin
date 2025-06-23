class EventModel {
  final int idEvent;
  final int idAdmin;
  final String namaEvent;
  final DateTime waktu;
  final String artis;
  final String image;

  EventModel({
    required this.idEvent,
    required this.idAdmin,
    required this.namaEvent,
    required this.waktu,
    required this.artis,
    required this.image,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      idEvent: json['id_event'],
      idAdmin: json['id_admin'],
      namaEvent: json['nama_event'],
      waktu: DateTime.parse(json['waktu']),
      artis: json['artis'],
      image: json['image'],
    );
  }
}
