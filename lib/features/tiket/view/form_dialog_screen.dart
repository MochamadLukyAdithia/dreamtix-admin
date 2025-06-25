// widgets/ticket_form_dialog.dart
import 'package:dreamtix_admin/features/tiket/controller/CategoryController.dart';
import 'package:dreamtix_admin/features/tiket/controller/TiketController.dart';
import 'package:dreamtix_admin/features/tiket/model/Tiket.dart';
// import 'package:dreamtix_admin/features/transaksi/model/transaksi_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketFormDialog extends StatefulWidget {
  final Ticket? ticket;
  const TicketFormDialog({super.key, this.ticket});

  @override
  State<TicketFormDialog> createState() => _TicketFormDialogState();
}

class _TicketFormDialogState extends State<TicketFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _namaEventController = TextEditingController();
  final _artistController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  final _imageController = TextEditingController();
  final CategoryController categoryController = Get.put(CategoryController());

  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.ticket != null) {
      _namaEventController.text = widget.ticket!.event.namaEvent;
      _artistController.text = widget.ticket!.event.artis;
      _imageController.text = widget.ticket!.event.image;
      _hargaController.text = widget.ticket!.harga.toString();
      _stokController.text = widget.ticket!.stok.toString();
      _selectedDate = widget.ticket!.event.waktu;

      // Set selected category based on ticket data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final category = categoryController.categories.firstWhereOrNull(
          (cat) => cat.idCategory == widget.ticket!.idCategory,
        );
        if (category != null) {
          setState(() {
            _selectedCategory = category;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E3A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width * 1.5,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.ticket == null ? "Tambah Tiket Baru" : "Edit Tiket",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _namaEventController,
                  label: "Nama Event",
                  icon: Icons.event,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _artistController,
                  label: "Artis",
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _imageController,
                  label: "Masukkan Link Gambar",
                  icon: Icons.image,
                ),
                const SizedBox(height: 16),
                _buildCategoryDropdown(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _hargaController,
                        label: "Harga",
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _stokController,
                        label: "Stok",
                        icon: Icons.inventory,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDateTimePicker(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        "Batal",
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _saveTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        widget.ticket == null ? "Tambah" : "Update",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return Obx(() {
      if (categoryController.isLoading.value) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.category, color: Color(0xFF6C63FF)),
              const SizedBox(width: 12),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                strokeWidth: 2,
              ),
              const SizedBox(width: 12),
              Text(
                "Loading categories...",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            child: DropdownButtonFormField<Category>(
              isExpanded: true,
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: "Kategori",
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(
                  Icons.category,
                  color: Color(0xFF6C63FF),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6C63FF)),
                ),
              ),
              dropdownColor: const Color(0xFF1E1E3A),
              style: const TextStyle(color: Colors.white),
              items: categoryController.categories.map((Category category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(
                    "${category.nama} - ${category.posisi}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (Category? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Kategori tidak boleh kosong';
                }
                return null;
              },
            ),
          );
        },
      );  
    });
  }

  Widget _buildDateTimePicker() {
    return GestureDetector(
      onTap: _selectDateTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.schedule, color: Color(0xFF6C63FF)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Waktu Event",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} ${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              surface: Color(0xFF1E1E3A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF6C63FF),
                surface: Color(0xFF1E1E3A),
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _saveTicket() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        Get.snackbar(
          'Error',
          'Kategori harus dipilih',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final controller = Get.find<TicketController>();

      final ticketData = {
        'nama_event': _namaEventController.text.trim(),
        'artis': _artistController.text.trim(),
        'waktu': _selectedDate.toIso8601String(),
        'nama': _selectedCategory!.nama,
        'image': _imageController.text.trim(),
        'harga': int.parse(_hargaController.text),
        'stok': int.parse(_stokController.text),
        'id_category': _selectedCategory!.idCategory,
      };

      // Untuk update, gunakan ID yang sudah ada
      if (widget.ticket != null) {
        ticketData['id_event'] = widget.ticket!.idEvent;
        controller.updateTicket(widget.ticket!.idTiket, ticketData);
      } else {
        // Untuk create, biarkan backend menentukan ID event
        ticketData['id_event'] =
            1; // Default event ID atau sesuai logic backend
        controller.createTicket(ticketData);
      }

      Get.back();
    }
  }

  @override
  void dispose() {
    _namaEventController.dispose();
    _artistController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    super.dispose();
  }
}
