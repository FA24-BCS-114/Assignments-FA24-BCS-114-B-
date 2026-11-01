import 'package:flutter/material.dart';

class DigitalPassScreen extends StatefulWidget {
  final bool initialQrMode;

  const DigitalPassScreen({super.key, this.initialQrMode = false});

  @override
  State<DigitalPassScreen> createState() => _DigitalPassScreenState();
}

class _DigitalPassScreenState extends State<DigitalPassScreen> {
  late bool _qrMode;

  @override
  void initState() {
    super.initState();
    _qrMode = widget.initialQrMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.55),
            radius: 1.25,
            colors: [Color(0xFF112236), Color(0xFF090E1A), Color(0xFF050811)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderSwitch(),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    child: _qrMode
                        ? _buildVerificationBack(const ValueKey('qr'))
                        : _buildExecutiveFront(const ValueKey('id')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSwitch() {
    return Container(
      width: 376,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _qrMode = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_qrMode ? const Color(0xFF10B981) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.credit_card_rounded,
                      size: 16,
                      color: !_qrMode ? const Color(0xFF052E16) : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Smart Student ID',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: !_qrMode ? const Color(0xFF052E16) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _qrMode = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _qrMode ? const Color(0xFFF59E0B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      size: 17,
                      color: _qrMode ? const Color(0xFF1C1917) : const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Gate Barcode & QR',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: _qrMode ? const Color(0xFF1C1917) : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveFront(Key key) {
    return Container(
      key: key,
      width: 376,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.14),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Obsidian & Gold Banner
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(27)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withOpacity(0.5),
                            ),
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: Color(0xFFFBBF24),
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'COMSATS UNIVERSITY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'VEHARI CAMPUS • DIGITAL PASS',
                              style: TextStyle(
                                color: Color(0xFF6EE7B7),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.wifi_tethering_rounded,
                      color: Color(0xFF34D399),
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Horizontal Profile Hero inside Card
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFFF59E0B)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.35),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 46,
                        backgroundColor: Color(0xFF0F172A),
                        backgroundImage: AssetImage(
                          'assets/images/harry_avatar.jpg',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF10B981).withOpacity(0.45),
                              ),
                            ),
                            child: const Text(
                              'UNDERGRADUATE SCHOLAR',
                              style: TextStyle(
                                color: Color(0xFF6EE7B7),
                                fontSize: 9.2,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.9,
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'Harry',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'FA24-BCS-114',
                            style: TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Metallic Smart Chip Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              border: Border(
                top: BorderSide(color: Color(0xFF334155)),
                bottom: BorderSide(color: Color(0xFF334155)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(
                        Icons.sim_card_outlined,
                        size: 16,
                        color: Color(0xFF451A03),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'RFID SMART CHIP ENABLED',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                      ),
                    ),
                  ],
                ),
                const Text(
                  'SEC - B',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // Bento Info Grid
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildBentoBox(
                        Icons.terminal_rounded,
                        'DEPARTMENT',
                        'Computer Science',
                        const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildBentoBox(
                        Icons.layers_rounded,
                        'SEMESTER',
                        '4th Semester',
                        const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildBentoBox(
                        Icons.class_rounded,
                        'PROGRAM & SECTION',
                        'BSCS • Section B',
                        const Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildBentoBox(
                        Icons.event_available_rounded,
                        'SESSION',
                        '2024 – 2028',
                        const Color(0xFFA78BFA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildFullDarkTile(
                  Icons.alternate_email_rounded,
                  'OFFICIAL EMAIL',
                  'harry114@gmail.com',
                ),
                const SizedBox(height: 10),
                _buildFullDarkTile(
                  Icons.verified_rounded,
                  'ENROLLMENT STATUS',
                  'Active Full-Time Student • Good Standing',
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          GestureDetector(
            onTap: () => setState(() => _qrMode = true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF047857)],
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(27)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'OPEN SECURITY BARCODE & QR VERIFICATION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBack(Key key) {
    return Container(
      key: key,
      width: 376,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFF59E0B).withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.12),
            blurRadius: 34,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(27)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SECURITY CLEARANCE & GATE PASS',
                      style: TextStyle(
                        color: Color(0xFFFBBF24),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Holder: Harry (FA24-BCS-114 • Sec B)',
                      style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5),
                    ),
                  ],
                ),
                Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 26),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      CustomPaint(
                        size: const Size(140, 140),
                        painter: _DarkPassQrPainter(),
                      ),
                      const SizedBox(height: 12),
                      CustomPaint(
                        size: const Size(220, 34),
                        painter: _BarcodeStripesPainter(),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '*FA24-BCS-114-SEC-B*',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _buildFullDarkTile(
                  Icons.bloodtype_rounded,
                  'BLOOD GROUP & EMERGENCY',
                  'O+ Positive • Campus Clinic Ext. 112',
                ),
                const SizedBox(height: 10),
                _buildFullDarkTile(
                  Icons.domain_verification_rounded,
                  'ISSUING AUTHORITY',
                  'Registrar Office, CUI Vehari Campus',
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _qrMode = false),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(27)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_back_rounded, color: Color(0xFFFBBF24), size: 17),
                  SizedBox(width: 8),
                  Text(
                    'BACK TO STUDENT IDENTITY DETAILS',
                    style: TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoBox(
    IconData icon,
    String title,
    String val,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 19),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullDarkTile(IconData icon, String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF34D399), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  val,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkPassQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const n = 15;
    final cell = size.width / n;
    final p = Paint()..color = const Color(0xFF0F172A);

    bool corner(int r, int c, int sr, int sc) {
      final dr = r - sr;
      final dc = c - sc;
      if (dr < 0 || dr > 4 || dc < 0 || dc > 4) return false;
      if (dr == 0 || dr == 4 || dc == 0 || dc == 4) return true;
      return dr == 2 && dc == 2;
    }

    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        final isCorner = corner(r, c, 0, 0) ||
            corner(r, c, 0, n - 5) ||
            corner(r, c, n - 5, 0);
        final margin = (r < 6 && c < 6) ||
            (r < 6 && c >= n - 6) ||
            (r >= n - 6 && c < 6);
        final bit = ((r * 11 + c * 5 + (r ^ c)) % 3 == 0);
        if (isCorner || (!margin && bit)) {
          canvas.drawRect(
            Rect.fromLTWH(c * cell + 1, r * cell + 1, cell - 1.8, cell - 1.8),
            p,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarcodeStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF0F172A);
    double x = 4;
    int i = 0;
    while (x < size.width - 6) {
      final w = (i % 3 == 0) ? 3.5 : ((i % 2 == 0) ? 1.6 : 2.4);
      canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), p);
      x += w + ((i % 4 == 0) ? 3.2 : 2.0);
      i++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
