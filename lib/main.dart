import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const PosParkingApp());
}

const Color kSlate800 = Color(0xFF1E293B);
const Color kSlate900 = Color(0xFF0F172A);
const Color kSlateGrey = Color(0xFF94A3B8);
const Color kBorderColor = Color(0xFF334155);
const Color kEmerald = Color(0xFF10B981);
const Color kBluePrimary = Color(0xFF3B82F6);

class PosParkingApp extends StatelessWidget {
  const PosParkingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Professional Parking POS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kSlate900,
        colorScheme: const ColorScheme.dark(
          primary: kBluePrimary,
          secondary: kEmerald,
          surface: kSlate800,
          error: Color(0xFFEF4444),
        ),
        cardTheme: CardThemeData(
          color: kSlate800,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: kBorderColor),
          ),
        ),
      ),
      home: const PosTerminalScreen(),
    );
  }
}

class PosTerminalScreen extends StatefulWidget {
  const PosTerminalScreen({super.key});

  @override
  State<PosTerminalScreen> createState() => _PosTerminalScreenState();
}

class _PosTerminalScreenState extends State<PosTerminalScreen> {
  final TextEditingController _ticketController = TextEditingController();
  final FocusNode _keyboardFocusNode = FocusNode();

  // System States
  bool _isGateOpen = false;
  String _ticketNo = 'TKT-884920';
  String _plateNo = 'B 1980 SAK';
  String _vehicleType = 'Mobil';
  final String _timeIn = '10:15 WIB';
  final String _timeOut = '14:30 WIB';
  final String _duration = '4 Jam 15 Mnt';
  int _baseTariff = 18000;
  int _penaltyFee = 0;
  bool _isPaid = false;
  bool _isLostTicket = false;

  // OCR & RFID Mock States
  bool _anprScanning = false;
  double _anprConfidence = 98.4;
  final String _rfidCardId = 'NFC-8839-2041';
  final bool _isRfidActive = true;

  // Shift Financial Summary (Mock Data Shift)
  int _shiftCashTotal = 450000;
  int _shiftQrisTotal = 620000;
  int _shiftRfidTotal = 180000;
  int _shiftTxCount = 42;
  // Report / Shift states
  int _shiftExpenseTotal = 150000;
  int _manualTicketCount = 0;
  final List<Map<String, dynamic>> _shiftExpenses = [
    {
      'category': 'Operasional',
      'amount': 100000,
      'note': 'Pembelian kebutuhan operasional',
    },
    {
      'category': 'Printer',
      'amount': 50000,
      'note': 'Kertas printer thermal',
    },
  ];

  final String _attendanceIn = '05:52 WIB';
  final String _attendanceOut = '-';
  final String _attendanceStatus = 'HADIR';

  int get _shiftGrandIncome =>
      _shiftCashTotal + _shiftQrisTotal + _shiftRfidTotal;
  int get _shiftNetIncome => _shiftGrandIncome - _shiftExpenseTotal;

  int get _totalAmount => _baseTariff + _penaltyFee;

  String _rupiah(int amount) {
    return amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ticketController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }
  Widget _buildSideNavigation() {
    return Container(
      width: 220,
      color: kSlate800,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: kBorderColor),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_parking, color: kBluePrimary, size: 28),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'PARKING POS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildSideNavItem(
                  icon: Icons.point_of_sale,
                  title: 'Terminal Transaksi',
                  subtitle: 'POS Out-Gate',
                  onTap: () {},
                  selected: true,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Text(
                    'LAPORAN',
                    style: TextStyle(
                      color: kSlateGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildSideNavItem(
                  icon: Icons.assessment_outlined,
                  title: 'Laporan Shift',
                  subtitle: 'Rekap lengkap shift',
                  onTap: _showFullShiftReportDialog,
                ),
                _buildSideNavItem(
                  icon: Icons.fact_check_outlined,
                  title: 'Laporan Absensi',
                  subtitle: 'Kehadiran operator',
                  onTap: _showAttendanceReportDialog,
                ),
                _buildSideNavItem(
                  icon: Icons.trending_up,
                  title: 'Pemasukan',
                  subtitle: 'Pendapatan per shift',
                  onTap: _showIncomeReportDialog,
                ),
                _buildSideNavItem(
                  icon: Icons.trending_down,
                  title: 'Pengeluaran',
                  subtitle: 'Biaya per shift',
                  onTap: _showExpenseReportDialog,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Text(
                    'OPERASIONAL',
                    style: TextStyle(
                      color: kSlateGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildSideNavItem(
                  icon: Icons.confirmation_num_outlined,
                  title: 'Tiket Manual',
                  subtitle: 'Jika tap kartu gagal',
                  onTap: _showManualTicketDialog,
                  accent: Colors.orange,
                ),
                _buildSideNavItem(
                  icon: Icons.door_front_door_outlined,
                  title: 'Palang Manual',
                  subtitle: 'Buka / tutup palang',
                  onTap: _toggleGate,
                  accent: kEmerald,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
                  child: Text(
                    'LAINNYA',
                    style: TextStyle(
                      color: kSlateGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildSideNavItem(
                  icon: Icons.warning_amber_rounded,
                  title: 'Tiket Hilang',
                  subtitle: 'Proses tiket hilang',
                  onTap: _showLostTicketDialog,
                  accent: Colors.redAccent,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: kBorderColor),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kEmerald,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Shift 1 • Aktif',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                  ),
                ),
                Text(
                  '$_shiftTxCount trx',
                  style: const TextStyle(
                    fontSize: 10,
                    color: kSlateGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool selected = false,
    Color? accent,
  }) {
    final itemColor =
        accent ?? (selected ? kBluePrimary : Colors.white70);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected ? kBluePrimary.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              border: selected
                  ? Border.all(color: kBluePrimary.withOpacity(0.35))
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, color: itemColor, size: 21),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kSlateGrey,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportMetric(
    IconData icon,
    String label,
    String value, {
    Color color = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSlate900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: kSlateGrey,
                fontSize: 11,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullShiftReportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kSlate800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: kBluePrimary),
          ),
          title: const Row(
            children: [
              Icon(Icons.assessment, color: kBluePrimary, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'LAPORAN LENGKAP SHIFT',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 620,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kSlate900,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kBorderColor),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.badge, color: kBluePrimary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shift 1 - Pagi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '06:00 - 14:00 • Operator: Budi Santoso',
                                style: TextStyle(
                                  color: kSlateGrey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Chip(
                          label: Text(
                            'AKTIF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: kBluePrimary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'ABSENSI OPERATOR',
                    style: TextStyle(
                      color: kSlateGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  _buildReportMetric(
                    Icons.login,
                    'Jam Masuk',
                    _attendanceIn,
                    color: kEmerald,
                  ),
                  const SizedBox(height: 6),
                  _buildReportMetric(
                    Icons.logout,
                    'Jam Keluar',
                    _attendanceOut,
                    color: kSlateGrey,
                  ),
                  const SizedBox(height: 6),
                  _buildReportMetric(
                    Icons.verified,
                    'Status Absensi',
                    _attendanceStatus,
                    color: kEmerald,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TRANSAKSI & PEMASUKAN',
                    style: TextStyle(
                      color: kSlateGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  _buildReportMetric(
                    Icons.directions_car,
                    'Total Kendaraan',
                    '$_shiftTxCount',
                    color: kBluePrimary,
                  ),
                  const SizedBox(height: 6),
                  _buildReportMetric(
                    Icons.payments,
                    'Cash',
                    'Rp ${_rupiah(_shiftCashTotal)}',
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 6),
                  _buildReportMetric(
                    Icons.qr_code_2,
                    'QRIS',
                    'Rp ${_rupiah(_shiftQrisTotal)}',
                    color: kEmerald,
                  ),
                  const SizedBox(height: 6),
                  _buildReportMetric(
                    Icons.nfc,
                    'RFID / Card',
                    'Rp ${_rupiah(_shiftRfidTotal)}',
                    color: kBluePrimary,
                  ),
                  const SizedBox(height: 6),
                  _buildReportMetric(
                    Icons.confirmation_num,
                    'Tiket Manual',
                    '$_manualTicketCount',
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kEmerald.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kEmerald),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL PEMASUKAN',
                          style: TextStyle(
                            color: kEmerald,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${_rupiah(_shiftGrandIncome)}',
                          style: const TextStyle(
                            color: kEmerald,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PENGELUARAN',
                    style: TextStyle(
                      color: kSlateGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  ..._shiftExpenses.map(
                    (expense) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _buildReportMetric(
                        Icons.receipt_long,
                        '${expense['category']} • ${expense['note']}',
                        'Rp ${_rupiah(expense['amount'] as int)}',
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'TOTAL PENGELUARAN',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${_rupiah(_shiftExpenseTotal)}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: kBluePrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: kBluePrimary.withOpacity(0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SALDO BERSIH SHIFT',
                          style: TextStyle(
                            color: kBluePrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${_rupiah(_shiftNetIncome)}',
                          style: const TextStyle(
                            color: kBluePrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'TUTUP',
                style: TextStyle(color: kSlateGrey),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mencetak laporan shift...'),
                    backgroundColor: kBluePrimary,
                  ),
                );
              },
              icon: const Icon(Icons.print, size: 18),
              label: const Text('CETAK LAPORAN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kBluePrimary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAttendanceReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSlate800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.fact_check, color: kBluePrimary),
            SizedBox(width: 8),
            Text(
              'LAPORAN ABSENSI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 430,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReportMetric(
                Icons.person,
                'Operator',
                'Budi Santoso',
                color: kBluePrimary,
              ),
              const SizedBox(height: 8),
              _buildReportMetric(
                Icons.wb_sunny,
                'Shift',
                'Shift 1 - Pagi',
                color: Colors.amber,
              ),
              const SizedBox(height: 8),
              _buildReportMetric(
                Icons.login,
                'Jam Masuk',
                _attendanceIn,
                color: kEmerald,
              ),
              const SizedBox(height: 8),
              _buildReportMetric(
                Icons.logout,
                'Jam Keluar',
                _attendanceOut,
                color: kSlateGrey,
              ),
              const SizedBox(height: 8),
              _buildReportMetric(
                Icons.check_circle,
                'Status',
                _attendanceStatus,
                color: kEmerald,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'TUTUP',
              style: TextStyle(color: kSlateGrey),
            ),
          ),
        ],
      ),
    );
  }

  void _showIncomeReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSlate800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: kEmerald),
        ),
        title: const Row(
          children: [
            Icon(Icons.trending_up, color: kEmerald),
            SizedBox(width: 8),
            Text(
              'LAPORAN PEMASUKAN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReportMetric(
                Icons.payments,
                'Cash',
                'Rp ${_rupiah(_shiftCashTotal)}',
                color: Colors.amber,
              ),
              const SizedBox(height: 7),
              _buildReportMetric(
                Icons.qr_code_2,
                'QRIS',
                'Rp ${_rupiah(_shiftQrisTotal)}',
                color: kEmerald,
              ),
              const SizedBox(height: 7),
              _buildReportMetric(
                Icons.nfc,
                'RFID / Card',
                'Rp ${_rupiah(_shiftRfidTotal)}',
                color: kBluePrimary,
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kEmerald.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kEmerald),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL PEMASUKAN SHIFT',
                      style: TextStyle(
                        color: kEmerald,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Rp ${_rupiah(_shiftGrandIncome)}',
                      style: const TextStyle(
                        color: kEmerald,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'TUTUP',
              style: TextStyle(color: kSlateGrey),
            ),
          ),
        ],
      ),
    );
  }

  void _showExpenseReportDialog() {
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: kSlate800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.orange),
              ),
              title: const Row(
                children: [
                  Icon(Icons.trending_down, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'PENGELUARAN SHIFT',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ..._shiftExpenses.map(
                        (expense) => Container(
                          margin: const EdgeInsets.only(bottom: 7),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: kSlate900,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kBorderColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.receipt_long,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense['category'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      expense['note'] as String,
                                      style: const TextStyle(
                                        color: kSlateGrey,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Rp ${_rupiah(expense['amount'] as int)}',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(color: kBorderColor, height: 22),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'TAMBAH PENGELUARAN',
                          style: TextStyle(
                            color: Colors.orange.shade300,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          hintText: 'Contoh: Operasional',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Nominal',
                          prefixIcon: Icon(Icons.payments),
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Keterangan',
                          hintText: 'Contoh: Beli kertas printer',
                          prefixIcon: Icon(Icons.notes),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Total pengeluaran: Rp ${_rupiah(_shiftExpenseTotal)}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'TUTUP',
                    style: TextStyle(color: kSlateGrey),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final amount =
                        int.tryParse(amountController.text.replaceAll('.', ''));
                    if (categoryController.text.trim().isEmpty ||
                        amount == null ||
                        amount <= 0 ||
                        noteController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Lengkapi kategori, nominal, dan keterangan.',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    setState(() {
                      _shiftExpenses.add({
                        'category': categoryController.text.trim(),
                        'amount': amount,
                        'note': noteController.text.trim(),
                      });
                      _shiftExpenseTotal += amount;
                    });
                    setModalState(() {});
                    categoryController.clear();
                    amountController.clear();
                    noteController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pengeluaran berhasil ditambahkan.'),
                        backgroundColor: kEmerald,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('TAMBAH'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showManualTicketDialog() {
    final plateController = TextEditingController();
    final rfidController = TextEditingController();
    final noteController = TextEditingController();

    String tempVehicle = 'Mobil';
    String tempReason = 'RFID / Kartu tidak terbaca';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: kSlate800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.orange),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.confirmation_num_outlined,
                    color: Colors.orange,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'BUAT TIKET MANUAL',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.5),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Gunakan fitur ini jika tap kartu, RFID, barcode, atau printer tiket mengalami error.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Alasan Manual',
                        style: TextStyle(
                          color: kSlateGrey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: tempReason,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.report_problem_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'RFID / Kartu tidak terbaca',
                            child: Text('RFID / Kartu tidak terbaca'),
                          ),
                          DropdownMenuItem(
                            value: 'Barcode tidak terbaca',
                            child: Text('Barcode tidak terbaca'),
                          ),
                          DropdownMenuItem(
                            value: 'Printer tiket error',
                            child: Text('Printer tiket error'),
                          ),
                          DropdownMenuItem(
                            value: 'Sistem / jaringan error',
                            child: Text('Sistem / jaringan error'),
                          ),
                          DropdownMenuItem(
                            value: 'Kendaraan masuk tanpa tiket',
                            child: Text('Kendaraan masuk tanpa tiket'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setModalState(() => tempReason = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: plateController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Nomor Polisi *',
                          hintText: 'Contoh: B 1234 XYZ',
                          prefixIcon: Icon(Icons.directions_car),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Jenis Kendaraan',
                        style: TextStyle(
                          color: kSlateGrey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Motor'),
                              selected: tempVehicle == 'Motor',
                              onSelected: (value) {
                                if (value) {
                                  setModalState(() => tempVehicle = 'Motor');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Mobil'),
                              selected: tempVehicle == 'Mobil',
                              onSelected: (value) {
                                if (value) {
                                  setModalState(() => tempVehicle = 'Mobil');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: rfidController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor RFID / Kartu (opsional)',
                          hintText: 'Contoh: NFC-8839-2041',
                          prefixIcon: Icon(Icons.nfc),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: noteController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Catatan Operator',
                          hintText: 'Contoh: kartu tidak terdeteksi',
                          prefixIcon: Icon(Icons.notes),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'BATAL',
                    style: TextStyle(color: kSlateGrey),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (plateController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Nomor polisi wajib diisi.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final now = DateTime.now();
                    final manualNo =
                        'TKT-MNL-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(_manualTicketCount + 1).toString().padLeft(3, '0')}';

                    setState(() {
                      _manualTicketCount++;
                      _shiftTxCount++;
                      _ticketNo = manualNo;
                      _plateNo =
                          plateController.text.trim().toUpperCase();
                      _vehicleType = tempVehicle;
                      _baseTariff = tempVehicle == 'Mobil' ? 18000 : 8000;
                      _penaltyFee = 0;
                      _isLostTicket = false;
                      _isPaid = false;
                      _isGateOpen = false;
                    });

                    Navigator.pop(context);

                    Future.delayed(
                      const Duration(milliseconds: 150),
                      () {
                        if (!mounted) return;
                        _showManualTicketSuccessDialog(
                          manualNo,
                          tempReason,
                          noteController.text.trim(),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('BUAT & CETAK TIKET'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showManualTicketSuccessDialog(
    String ticketNo,
    String reason,
    String note,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSlate800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: kEmerald),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: kEmerald, size: 28),
            SizedBox(width: 8),
            Text(
              'TIKET BERHASIL DIBUAT',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportMetric(
              Icons.confirmation_num,
              'No. Tiket',
              ticketNo,
              color: kBluePrimary,
            ),
            const SizedBox(height: 8),
            _buildReportMetric(
              Icons.report_problem,
              'Alasan',
              reason,
              color: Colors.orange,
            ),
            if (note.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildReportMetric(
                Icons.notes,
                'Catatan',
                note,
                color: kSlateGrey,
              ),
            ],
            const SizedBox(height: 12),
            const Text(
              'Tiket manual tercatat pada shift aktif dan siap diproses sebagai transaksi normal.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showReceiptDialog('MANUAL');
            },
            icon: const Icon(Icons.print),
            label: const Text('LIHAT / CETAK TIKET'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kBluePrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  void _searchTicket() {
    if (_ticketController.text.isNotEmpty) {
      setState(() {
        _ticketNo = _ticketController.text.toUpperCase();
        _plateNo = 'B ${(1000 + _ticketNo.hashCode % 8999).abs()} XYZ';
        _vehicleType = (_ticketNo.hashCode % 2 == 0) ? 'Mobil' : 'Motor';
        _baseTariff = (_ticketNo.hashCode % 2 == 0) ? 20000 : 8000;
        _penaltyFee = 0;
        _isLostTicket = false;
        _isPaid = false;
        _isGateOpen = false;
      });
      _ticketController.clear();
    }
  }

  void _triggerAnprScan() {
    setState(() => _anprScanning = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _anprScanning = false;
          _plateNo = 'B ${(1000 + DateTime.now().millisecond % 8999)} OCR';
          _anprConfidence = 95.0 + (DateTime.now().millisecond % 40) / 10;
        });
      }
    });
  }

  void _processPayment(String method) {
    if (_isPaid) return;

    setState(() {
      _isPaid = true;
      _isGateOpen = true;
      _shiftTxCount++;
      if (method == 'TUNAI') _shiftCashTotal += _totalAmount;
      if (method == 'QRIS') _shiftQrisTotal += _totalAmount;
      if (method == 'RFID/CARD') _shiftRfidTotal += _totalAmount;
    });

    _showReceiptDialog(method);
  }

  void _toggleGate() {
    setState(() {
      _isGateOpen = !_isGateOpen;
    });
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f1) {
        _processPayment('TUNAI');
      } else if (event.logicalKey == LogicalKeyboardKey.f2) {
        _processPayment('QRIS');
      } else if (event.logicalKey == LogicalKeyboardKey.f3) {
        _showShiftReportDialog();
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        _toggleGate();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        _showLostTicketDialog();
      }
    }
  }

  // Modal Laporan Shift & Rekonsiliasi Kasir
  void _showShiftReportDialog() {
    int grandTotal = _shiftCashTotal + _shiftQrisTotal + _shiftRfidTotal;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kSlate800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: kBluePrimary),
          ),
          title: const Row(
            children: [
              Icon(Icons.assessment, color: kBluePrimary, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text('REKAP SHIFT & REKONSILIASI KASIR',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kSlate900,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kBorderColor),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Shift 1 - Pagi (06:00 - 14:00)',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Kasir: Budi Santoso',
                              style: TextStyle(color: kSlateGrey, fontSize: 11)),
                        ],
                      ),
                      Chip(
                        label: Text('SHIFT AKTIF',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        backgroundColor: kBluePrimary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Rincian Transaksi per Metode Bayar:',
                    style: TextStyle(
                        color: kSlateGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildShiftSummaryRow(Icons.payments, 'Pembayaran Tunai (Cash)',
                    _shiftCashTotal, Colors.amber),
                _buildShiftSummaryRow(Icons.qr_code_2,
                    'Pembayaran Non-Tunai (QRIS)', _shiftQrisTotal, kEmerald),
                _buildShiftSummaryRow(Icons.nfc, 'Tap RFID / Smart Card',
                    _shiftRfidTotal, kBluePrimary),
                const Divider(color: kBorderColor, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Transaksi Selesai: $_shiftTxCount Kendaraan',
                        style:
                            const TextStyle(fontSize: 12, color: kSlateGrey)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kEmerald.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kEmerald),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL PENDAPATAN SHIFT',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: kEmerald)),
                      Text(
                        'Rp ${_rupiah(grandTotal)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: kEmerald),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('TUTUP', style: TextStyle(color: kSlateGrey)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.print, size: 18),
              label: const Text('CETAK REKAP SHIFT'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kBluePrimary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Mencetak Rekap Shift ke Printer Thermal...'),
                      backgroundColor: kBluePrimary),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildShiftSummaryRow(
      IconData icon, String label, int amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(
            'Rp ${_rupiah(amount)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Modal Tiket Hilang
  void _showLostTicketDialog() {
    final stnkController = TextEditingController();
    final ktpController = TextEditingController();
    String tempVehicle = _vehicleType;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            int denda = (tempVehicle == 'Mobil') ? 40000 : 30000;

            return AlertDialog(
              backgroundColor: kSlate800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.redAccent),
              ),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.redAccent, size: 28),
                  SizedBox(width: 8),
                  Text('PROSES TIKET HILANG',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ketentuan Tiket Hilang:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: kSlateGrey)),
                      const SizedBox(height: 4),
                      const Text('• Motor: Denda Rp 30.000 + Wajib STNK'),
                      const Text('• Mobil: Denda Rp 40.000 + Wajib STNK'),
                      const SizedBox(height: 16),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          const Text('Jenis Kendaraan: '),
                          ChoiceChip(
                            label: const Text('Motor (Denda 30rb)'),
                            selected: tempVehicle == 'Motor',
                            onSelected: (val) {
                              if (val) {
                                setModalState(() => tempVehicle = 'Motor');
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Mobil (Denda 40rb)'),
                            selected: tempVehicle == 'Mobil',
                            onSelected: (val) {
                              if (val) {
                                setModalState(() => tempVehicle = 'Mobil');
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: stnkController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor STNK / Nama Pemilik STNK *',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: ktpController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor KTP Pengemudi *',
                          prefixIcon: Icon(Icons.card_membership),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.redAccent.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Denda Tiket Hilang:'),
                            Text(
                              'Rp ${_rupiah(denda)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      const Text('BATAL', style: TextStyle(color: kSlateGrey)),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                    if (stnkController.text.isEmpty ||
                        ktpController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Harap lengkapi data STNK dan KTP!'),
                            backgroundColor: Colors.orange),
                      );
                      return;
                    }
                    setState(() {
                      _vehicleType = tempVehicle;
                      _penaltyFee = denda;
                      _isLostTicket = true;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('TERAPKAN DENDA',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Modal Struk Thermal
  void _showReceiptDialog(String paymentMethod) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_parking, color: Colors.black, size: 40),
                const Text('PARKING GATEWAY',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black)),
                const Text('Struk Pembayaran Parkir',
                    style: TextStyle(fontSize: 12, color: Colors.black54)),
                const Divider(color: Colors.black45, thickness: 1),
                _buildReceiptRow('No. Tiket', _ticketNo),
                _buildReceiptRow('Plat Nomor', _plateNo),
                _buildReceiptRow('Jenis', _vehicleType),
                _buildReceiptRow('Masuk', _timeIn),
                _buildReceiptRow('Keluar', _timeOut),
                _buildReceiptRow('Durasi', _duration),
                if (_isLostTicket)
                  _buildReceiptRow('Denda Tiket', 'Rp ${_rupiah(_penaltyFee)}',
                      isBold: true),
                const Divider(color: Colors.black45),
                _buildReceiptRow('TOTAL', 'Rp ${_rupiah(_totalAmount)}',
                    isBold: true),
                _buildReceiptRow('METODE', paymentMethod, isBold: true),
                const SizedBox(height: 12),
                const Text('*** TERIMA KASIH ***',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black54)),
              ],
            ),
          ),
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('CETAK STRUK'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kBluePrimary, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.black87, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      onKey: _handleKeyEvent,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // 1. TOP STATUS BAR
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: kSlate900,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kBluePrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_parking,
                          color: kBluePrimary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'POS OUT-GATE TERMINAL 01',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1),
                        ),
                        Text(
                          'Operator: Budi Santoso • Shift 1 (Pagi)',
                          style: TextStyle(color: kSlateGrey, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // RFID Reader Status Widget
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kSlate800,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kBorderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.nfc,
                              color: _isRfidActive ? kEmerald : Colors.grey,
                              size: 18),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('RFID READER',
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: kSlateGrey,
                                      fontWeight: FontWeight.bold)),
                              Text(_rfidCardId,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Shift Report Quick Action Button
                    ElevatedButton.icon(
                      onPressed: _showShiftReportDialog,
                      icon: const Icon(Icons.assessment, size: 16),
                      label: const Text('REKAP SHIFT (F3)',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSlate800,
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: kBluePrimary),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Barrier Gate Status Badge
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _isGateOpen
                            ? kEmerald.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        border: Border.all(
                            color: _isGateOpen ? kEmerald : Colors.red),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isGateOpen ? Icons.sensor_door : Icons.lock,
                            color: _isGateOpen ? kEmerald : Colors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isGateOpen ? 'PALANG TERBUKA' : 'PALANG TERTUTUP',
                            style: TextStyle(
                              color: _isGateOpen ? kEmerald : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: kBorderColor),

              // 2. MAIN WORKSPACE
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT: BARCODE & CAMERA FEEDS WITH ANPR OCR
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _ticketController,
                                        onSubmitted: (_) => _searchTicket(),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          hintText:
                                              'Scan Barcode / Input No. Tiket disini...',
                                          hintStyle: const TextStyle(
                                              color: kSlateGrey, fontSize: 14),
                                          prefixIcon: const Icon(
                                              Icons.qr_code_scanner,
                                              color: kBluePrimary),
                                          filled: true,
                                          fillColor: kSlate900,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 14),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      onPressed: _searchTicket,
                                      icon: const Icon(Icons.search),
                                      label: const Text('PROSES'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kBluePrimary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 18),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Expanded(
                              child: Row(
                                children: [
                                  // Kamera In-Gate
                                  Expanded(
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Container(
                                              color: Colors.black,
                                              child: const Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                        Icons
                                                            .directions_car_filled,
                                                        size: 64,
                                                        color: kSlateGrey),
                                                    SizedBox(height: 8),
                                                    Text('FOTO MASUK (IN-GATE)',
                                                        style: TextStyle(
                                                            color: kSlateGrey,
                                                            fontSize: 12)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 12,
                                            left: 12,
                                            child: _buildCameraBadge(
                                                'CAM 01 - IN GATE',
                                                kBluePrimary),
                                          ),
                                          Positioned(
                                            bottom: 12,
                                            left: 12,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              child: Text(
                                                  'Plat Terdeteksi: $_plateNo',
                                                  style: const TextStyle(
                                                      color: Colors.amber,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 11)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Kamera Out-Gate dengan OCR ANPR
                                  Expanded(
                                    child: Card(
                                      clipBehavior: Clip.antiAlias,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Container(
                                              color: Colors.black,
                                              child: Center(
                                                child: _anprScanning
                                                    ? const Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          CircularProgressIndicator(
                                                              color: kEmerald),
                                                          SizedBox(height: 12),
                                                          Text(
                                                              'MEMINDAI PLAT NOMOR (ANPR)...',
                                                              style: TextStyle(
                                                                  color:
                                                                      kEmerald,
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                        ],
                                                      )
                                                    : const Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons.camera_alt,
                                                              size: 64,
                                                              color:
                                                                  kSlateGrey),
                                                          SizedBox(height: 8),
                                                          Text(
                                                              'LIVE CAMERA (OUT-GATE)',
                                                              style: TextStyle(
                                                                  color:
                                                                      kSlateGrey,
                                                                  fontSize:
                                                                      12)),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 12,
                                            left: 12,
                                            child: _buildCameraBadge(
                                                'CAM 02 - ANPR OCR', kEmerald),
                                          ),
                                          // ANPR Live OCR Info Box
                                          Positioned(
                                            bottom: 12,
                                            left: 12,
                                            right: 12,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: kSlate900
                                                    .withOpacity(0.85),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                    color: kEmerald
                                                        .withOpacity(0.5)),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                          'OCR ANPR Auto-Detect:',
                                                          style: TextStyle(
                                                              fontSize: 10,
                                                              color:
                                                                  kSlateGrey)),
                                                      Text(_plateNo,
                                                          style:
                                                              const TextStyle(
                                                                  color:
                                                                      kEmerald,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      13)),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                          'Akurasi: ${_anprConfidence.toStringAsFixed(1)}%',
                                                          style: const TextStyle(
                                                              fontSize: 10,
                                                              color: Colors
                                                                  .white70)),
                                                      InkWell(
                                                        onTap: _triggerAnprScan,
                                                        child: const Text(
                                                            'Scan Ulang',
                                                            style: TextStyle(
                                                                fontSize: 10,
                                                                color:
                                                                    kBluePrimary,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // RIGHT: PAYMENT PANEL
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          height: double.infinity,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('RINCIAN TIKET',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: kSlateGrey)),
                                      Chip(
                                        label: Text(
                                            _isPaid ? 'LUNAS' : 'BELUM BAYAR',
                                            style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold)),
                                        backgroundColor: _isPaid
                                            ? kEmerald.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2),
                                        side: BorderSide(
                                            color:
                                                _isPaid ? kEmerald : Colors.red),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                      height: 20, color: kBorderColor),
                                  _buildDetailRow('No. Tiket', _ticketNo,
                                      isHighlight: true),
                                  _buildDetailRow('Plat Nomor', _plateNo,
                                      isHighlight: true,
                                      valueColor: Colors.amber),
                                  _buildDetailRow(
                                      'Jenis Kendaraan', _vehicleType),
                                  _buildDetailRow('Waktu Masuk', _timeIn),
                                  _buildDetailRow('Waktu Keluar', _timeOut),
                                  _buildDetailRow('Total Durasi', _duration),
                                  if (_isLostTicket) ...[
                                    const SizedBox(height: 4),
                                    _buildDetailRow('Denda Tiket Hilang',
                                        'Rp ${_rupiah(_penaltyFee)}',
                                        valueColor: Colors.redAccent,
                                        isHighlight: true),
                                  ],
                                  const Spacer(),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: kSlate900,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: kBluePrimary.withOpacity(0.5)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('TOTAL TARIF PARKIR',
                                            style: TextStyle(
                                                color: kSlateGrey,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        FittedBox(
                                          child: Text(
                                            'Rp ${_rupiah(_totalAmount)}',
                                            style: const TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: kEmerald,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              _processPayment('TUNAI'),
                                          style: OutlinedButton.styleFrom(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 16),
                                            side: const BorderSide(
                                                color: kBluePrimary),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          child: const Text('CASH (F1)',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: kBluePrimary)),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              _processPayment('QRIS'),
                                          style: OutlinedButton.styleFrom(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 16),
                                            side: const BorderSide(
                                                color: kEmerald),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          child: const Text('QRIS (F2)',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: kEmerald)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _toggleGate,
                                      icon: Icon(_isGateOpen
                                          ? Icons.lock
                                          : Icons.sensor_door),
                                      label: Text(_isGateOpen
                                          ? 'TUTUP PALANG'
                                          : 'BUKA PALANG MANUAL [SPACE]'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isGateOpen
                                            ? Colors.amber[800]
                                            : kEmerald,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. FOOTER & SHORTCUTS INFO
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          color: kSlate800,
          child: Row(
            children: [
              const Icon(Icons.keyboard, size: 16, color: kSlateGrey),
              const SizedBox(width: 8),
              const Text('Shortcuts: ',
                  style: TextStyle(
                      color: kSlateGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              const Text(
                  '[F1] Cash  •  [F2] QRIS  •  [F3] Rekap Shift  •  [SPACE] Buka Palang',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(width: 12),
              InkWell(
                onTap: _showLostTicketDialog,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('[ESC] Tiket Hilang',
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const Spacer(),
              const Text(
                  'Thermal Printer: ONLINE  •  ANPR Camera: ACTIVE  •  Barrier: READY',
                  style: TextStyle(
                      color: kEmerald,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlight = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kSlateGrey, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 15 : 13,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}