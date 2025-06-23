
  String formatDate(String dateString) {
    try {
      // Bersihkan string dari karakter yang tidak diperlukan
      String cleanedDate = dateString.replaceAll(RegExp(r'[^\d\s:-]'), '');

      // Coba berbagai format parsing
      DateTime? dateTime;

      // Format 1: 2025-08-12 19:00:00
      if (cleanedDate.contains('-') && cleanedDate.contains(':')) {
        try {
          dateTime = DateTime.parse(cleanedDate);
        } catch (e) {
          // Format 2: Manual parsing jika DateTime.parse gagal
          final parts = cleanedDate.split(' ');
          if (parts.length >= 2) {
            final datePart = parts[0].split('-');
            final timePart = parts[1].split(':');

            if (datePart.length == 3 && timePart.length >= 2) {
              dateTime = DateTime(
                int.parse(datePart[0]), // year
                int.parse(datePart[1]), // month
                int.parse(datePart[2]), // day
                int.parse(timePart[0]), // hour
                int.parse(timePart[1]), // minute
                timePart.length > 2 ? int.parse(timePart[2]) : 0, // second
              );
            }
          }
        }
      }

      if (dateTime != null) {
        // Format ke bahasa Indonesia
        final localDate = dateTime.toLocal();

        // Hari dalam bahasa Indonesia
        final days = [
          'Minggu',
          'Senin',
          'Selasa',
          'Rabu',
          'Kamis',
          'Jumat',
          'Sabtu'
        ];
        final months = [
          '',
          'Januari',
          'Februari',
          'Maret',
          'April',
          'Mei',
          'Juni',
          'Juli',
          'Agustus',
          'September',
          'Oktober',
          'November',
          'Desember'
        ];

        final dayName = days[localDate.weekday % 7];
        final monthName = months[localDate.month];

        return '$dayName, ${localDate.day.toString().padLeft(2, '0')} $monthName ${localDate.year} - ${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
      }

      // Jika parsing gagal, kembalikan string yang sudah dibersihkan
      return cleanedDate.isNotEmpty ? cleanedDate : dateString;
    } catch (e) {
      // Fallback: tampilkan string original yang sudah dibersihkan
      return dateString.replaceAll(RegExp(r'[^\d\s:-]'), '').trim();
    }
  }