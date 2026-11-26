import 'package:flutter/material.dart';
import '../model/tugas.dart';

class PanelTugas extends StatefulWidget {
  const PanelTugas({
    super.key,
    required this.judul,
    required this.daftar,
    required this.totalTugas,
    required this.jumlahSelesai,
    required this.galat,
    required this.hanyaBelumSelesai,
    required this.onTambah,
    required this.onUbahStatus,
    required this.onUbahFilter,
  });

  final String judul;
  final List<Tugas> daftar;
  final int totalTugas;
  final int jumlahSelesai;
  final String? galat;
  final bool hanyaBelumSelesai;
  final bool Function(String) onTambah;
  final ValueChanged<int> onUbahStatus;
  final ValueChanged<bool> onUbahFilter;

  @override
  State<PanelTugas> createState() => _PanelTugasState();
}

class _PanelTugasState extends State<PanelTugas> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _simpan() {
    if (widget.onTambah(_controller.text)) {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String pesanKosong = widget.totalTugas == 0
        ? 'Belum ada tugas.'
        : 'Tidak ada tugas yang belum selesai.';

    return Scaffold(
      appBar: AppBar(title: Text(widget.judul)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const ValueKey('judul-tugas'),
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Judul tugas',
              hintText: 'Contoh: Rancang UI Flutter',
              border: const OutlineInputBorder(),
              errorText: widget.galat,
            ),
            onSubmitted: (_) => _simpan(),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _simpan,
            child: const Text('Tambah tugas'),
          ),
          const SizedBox(height: 16),
          Text(
            '${widget.jumlahSelesai} dari${widget.totalTugas} selesai',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilterChip(
              key: const ValueKey('filter-belum-selesai'),
              label: const Text('Belum selesai'),
              selected: widget.hanyaBelumSelesai,
              onSelected: widget.onUbahFilter,
            ),
          ),
          const Divider(height: 24),
          if (widget.daftar.isEmpty)
            Text(pesanKosong)
          else
            ...widget.daftar.map(
              (tugas) => CheckboxListTile(
                key: ValueKey('tugas-${tugas.id}'),
                title: Text(tugas.judul),
                value: tugas.selesai,
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (_) => widget.onUbahStatus(tugas.id),
              ),
            ),
        ],
      ),
    );
  }
}