import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Parkir Enterprise',
      theme: ThemeData.dark(),
      home: const HeadParkingDashboard(),
    );
  }
}

// ==========================================
// PALETTE WARNA ENTERPRISE DARK THEME
// ==========================================
const Color kSlate900 = Color(0xFF0F172A);
const Color kSlate800 = Color(0xFF1E293B);
const Color kSlateGrey = Color(0xFF94A3B8);
const Color kBorderColor = Color(0xFF334155);
const Color kEmerald = Color(0xFF10B981);
const Color kBluePrimary = Color(0xFF3B82F6);
const Color kRoseAccent = Color(0xFFF43F5E);

// ==========================================
// MAIN DASHBOARD WITH TAB CONTROLLER
// ==========================================
class HeadParkingDashboard extends StatefulWidget {
  const HeadParkingDashboard({Key? key}) : super(key: key);

  @override
  State<HeadParkingDashboard> createState() => _HeadParkingDashboardState();
}

class _HeadParkingDashboardState extends State<HeadParkingDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSlate900,
      appBar: AppBar(
        backgroundColor: kSlate800,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: kBluePrimary),
            SizedBox(width: 10),
            Text(
              'Dashboard Operasional Parkir',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: kSlate900,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBorderColor),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: kBluePrimary,
                  child: Text(
                    'KP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Kepala Parkir: Supriadi',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: kBluePrimary,
          labelColor: kBluePrimary,
          unselectedLabelColor: kSlateGrey,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'Ringkasan'),
            Tab(icon: Icon(Icons.receipt_long_rounded), text: 'Pengeluaran'),
            Tab(icon: Icon(Icons.badge_rounded), text: 'Absensi Staff'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Riwayat Transaksi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildExpenseTab(),
          _buildAttendanceTab(),
          _buildTransactionHistoryTab(),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: RINGKASAN EKSEKUTIF
  // ==========================================
  Widget _buildSummaryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildMetricCard(
                'Total Pemasukan',
                'Rp 4.250.000',
                Icons.arrow_downward,
                kEmerald,
                '+12% dibanding kemarin',
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'Total Pengeluaran',
                'Rp 350.000',
                Icons.arrow_upward,
                kRoseAccent,
                'Bensin & Cetak Struk',
              ),
              const SizedBox(width: 12),
              _buildMetricCard(
                'Pendapatan Bersih',
                'Rp 3.900.000',
                Icons.account_balance_wallet,
                kBluePrimary,
                'Tunai + QRIS',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            color: kSlate800,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Breakdown Pembayaran',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildChannelRow('KASIR TUNAI', 'Rp 2.450.000', 0.58, kEmerald),
                  const SizedBox(height: 12),
                  _buildChannelRow('QRIS DINAMIS', 'Rp 1.500.000', 0.35, kBluePrimary),
                  const SizedBox(height: 12),
                  _buildChannelRow('MEMBER / E-MONEY', 'Rp 300.000', 0.07, Colors.amber),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: PENGELUARAN OPERASIONAL
  // ==========================================
  Widget _buildExpenseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: kSlate800,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Catatan Pengeluaran Operasional',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddExpenseDialog(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Input Pengeluaran', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: kBluePrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildExpenseRow(
                '15/09/2026 10:30',
                'Beli Kertas Thermal POS (5 Roll)',
                'Rp 75.000',
                'Kasir 01',
                'Disetujui',
              ),
              const Divider(color: kBorderColor),
              _buildExpenseRow(
                '15/09/2026 12:15',
                'Bensin Genset Out-Gate 2',
                'Rp 100.000',
                'Staff Teknisi',
                'Disetujui',
              ),
              const Divider(color: kBorderColor),
              _buildExpenseRow(
                '15/09/2026 14:00',
                'Perbaikan Barrier Gate Motor',
                'Rp 175.000',
                'Kepala Parkir',
                'Pending',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: ABSENSI STAFF
  // ==========================================
  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: kSlate800,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Absensi Staff Parkir Hari Ini',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Staff Aktif: 4 / 5 Personel',
                    style: TextStyle(color: kSlateGrey, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStaffRow(
                'Rifqi Taufiq',
                'Kasir POS Out-Gate 01',
                'Shift Pagi (07:00 - 15:00)',
                '06:48 WIB',
                'Hadir',
                kEmerald,
              ),
              _buildStaffRow(
                'Azis Saputra',
                'Kasir POS Out-Gate 02',
                'Shift Pagi (07:00 - 15:00)',
                '06:55 WIB',
                'Hadir',
                kEmerald,
              ),
              _buildStaffRow(
                'Yulistiani',
                'Petugas In-Gate 01',
                'Shift Pagi (07:00 - 15:00)',
                '07:10 WIB',
                'Terlambat',
                Colors.amber,
              ),
              _buildStaffRow(
                'Budi Santoso',
                'Petugas Patroli Area',
                'Shift Pagi (07:00 - 15:00)',
                '06:45 WIB',
                'Hadir',
                kEmerald,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 4: RIWAYAT TRANSAKSI
  // ==========================================
  Widget _buildTransactionHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: kSlate800,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Transaksi Masuk & Keluar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 14),
                    label: const Text('Export Excel', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: kEmerald),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(color: kBorderColor),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: kSlate900),
                    children: [
                      _buildTableHeader('No. Tiket'),
                      _buildTableHeader('Plat Nomor'),
                      _buildTableHeader('Jenis'),
                      _buildTableHeader('Durasi'),
                      _buildTableHeader('Total Biaya'),
                      _buildTableHeader('Metode'),
                      _buildTableHeader('Operator'),
                    ],
                  ),
                  _buildTableDataRow('T-20260915-0892', 'B 1234 CD', 'Mobil',
                      '3 Jam', 'Rp 15.000', 'QRIS', 'Kasir 01'),
                  _buildTableDataRow('T-20260915-0891', 'D 9981 AB', 'Motor',
                      '1 Jam', 'Rp 3.000', 'TUNAI', 'Kasir 02'),
                  _buildTableDataRow('T-20260915-0890', 'B 5541 WA', 'Mobil',
                      '5 Jam', 'Rp 25.000', 'TUNAI', 'Kasir 01'),
                  _buildTableDataRow('T-20260915-0889', 'F 3321 YZ', 'Mobil',
                      '2 Hari', 'Rp 85.000', 'TUNAI', 'Kasir 01'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DIALOG INPUT PENGELUARAN
  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSlate800,
        title: const Text(
          'Input Pengeluaran Operasional',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Keterangan Pengeluaran',
                labelStyle: TextStyle(color: kSlateGrey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kBorderColor),
                ),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Jumlah Nominal (Rp)',
                labelStyle: TextStyle(color: kSlateGrey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: kBorderColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: kSlateGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: kBluePrimary),
            child: const Text('SIMPAN'),
          ),
        ],
      ),
    );
  }

  // WIDGET HELPERS
  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Expanded(
      child: Card(
        color: kSlate800,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: kSlateGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(icon, color: color, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: color, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseRow(
      String time, String desc, String amount, String staff, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                desc,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$time • Oleh: $staff',
                style: const TextStyle(color: kSlateGrey, fontSize: 11),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: kRoseAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  color: status == 'Disetujui' ? kEmerald : Colors.amber,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelRow(
      String name, String amount, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: kSlate900,
          color: color,
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildStaffRow(String name, String role, String shift, String time,
      String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSlate900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: kSlate800,
                child: Icon(Icons.person, color: kSlateGrey, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '$role ($shift)',
                    style: const TextStyle(color: kSlateGrey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Absen: $time',
                style: const TextStyle(color: kSlateGrey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableDataRow(String ticket, String plate, String type,
      String duration, String amount, String method, String op) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(ticket,
              style: const TextStyle(color: kBluePrimary, fontSize: 11)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(plate,
              style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(type,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(duration,
              style: const TextStyle(color: kSlateGrey, fontSize: 11)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(amount,
              style: const TextStyle(
                  color: kEmerald,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(method,
              style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(op,
              style: const TextStyle(color: kSlateGrey, fontSize: 11)),
        ),
      ],
    );
  }
}