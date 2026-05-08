import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../dashboard_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name   = TextEditingController();
  final _email  = TextEditingController();
  final _pass   = TextEditingController();
  final _height = TextEditingController(text: '170');
  final _weight = TextEditingController(text: '70');

  String _gender    = 'male';
  String _bodyType  = 'skinny';
  String _activity  = 'sedentary';
  bool _loading     = false;
  bool _obscure     = true;
  String? _error;
  int _step         = 0;

  static const _bodyTypes = [
    {'value': 'skinny',     'label': 'Skinny',     'icon': Icons.accessibility_new, 'desc': 'Low body fat, low muscle'},
    {'value': 'skinny_fat', 'label': 'Skinny Fat', 'icon': Icons.person_outline,    'desc': 'Normal weight, low muscle, higher fat'},
    {'value': 'fat',        'label': 'Overweight', 'icon': Icons.monitor_weight,    'desc': 'High body fat'},
    {'value': 'athletic',   'label': 'Athletic',   'icon': Icons.fitness_center,    'desc': 'Good muscle, low-moderate fat'},
  ];

  static const _activities = [
    {'value': 'sedentary', 'label': 'Sedentary', 'icon': Icons.chair_outlined,  'desc': 'Desk job / light daily tasks'},
    {'value': 'active',    'label': 'Active',    'icon': Icons.directions_run,  'desc': 'Gym / sports / physical work'},
  ];

  Future<void> _signup() async {
    setState(() { _loading = true; _error = null; });
    try {
      final profile = await AuthService.signUp(
        email: _email.text.trim(),
        password: _pass.text,
        name: _name.text.trim(),
        gender: _gender,
        heightCm: double.tryParse(_height.text) ?? 170,
        weightKg: double.tryParse(_weight.text) ?? 70,
        bodyType: _bodyType,
        activityLevel: _activity,
      );
      if (!mounted) return;
      // Clear entire nav stack and go to Dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => DashboardScreen(uid: profile.uid)),
        (route) => false,
      );
    } on Exception catch (e) {
      String msg = e.toString().replaceAll('Exception: ', '');
      if (msg.contains('email-already-in-use')) {
        msg = 'An account with this email already exists. Please sign in instead.';
      } else if (msg.contains('weak-password')) {
        msg = 'Password is too weak. Use at least 6 characters.';
      } else if (msg.contains('invalid-email')) {
        msg = 'Please enter a valid email address.';
      }
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D6A4F)),
        title: Text(
          _step == 0 ? 'Create Account' : 'About You',
          style: const TextStyle(
              color: Color(0xFF1B4332),
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: 24, vertical: 16),
          child: _step == 0 ? _buildStep0() : _buildStep1(),
        ),
      ),
    );
  }

  // ── Step 0: name / email / password ───────────────────────────────────────
  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepIndicator(current: 0, total: 2),
        const SizedBox(height: 24),
        const Text('Let\'s get started',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B4332))),
        const SizedBox(height: 4),
        const Text('Enter your account details',
            style: TextStyle(color: Colors.black45)),
        const SizedBox(height: 28),

        _field(_name, 'Full Name', Icons.person_outline),
        const SizedBox(height: 14),
        _field(_email, 'Email', Icons.email_outlined,
            type: TextInputType.emailAddress),
        const SizedBox(height: 14),
        TextField(
          controller: _pass,
          obscureText: _obscure,
          decoration: _deco('Password', Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                    _obscure
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey),
                onPressed: () =>
                    setState(() => _obscure = !_obscure),
              )),
        ),
        const SizedBox(height: 28),

        if (_error != null) ...[
          _errorBox(_error!),
          const SizedBox(height: 14)
        ],

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              if (_name.text.trim().isEmpty ||
                  _email.text.trim().isEmpty ||
                  _pass.text.isEmpty) {
                setState(
                    () => _error = 'Please fill all fields.');
                return;
              }
              if (_pass.text.length < 6) {
                setState(() => _error =
                    'Password must be at least 6 characters.');
                return;
              }
              setState(() {
                _step = 1;
                _error = null;
              });
            },
            style: _btnStyle(),
            child: const Text('Continue',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // ── Step 1: gender / height / weight / body type / activity ──────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepIndicator(current: 1, total: 2),
        const SizedBox(height: 24),
        const Text('Your body profile',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B4332))),
        const SizedBox(height: 4),
        const Text('Used to personalise your protein goal',
            style: TextStyle(color: Colors.black45)),
        const SizedBox(height: 24),

        // ── Gender ──────────────────────────────────────────
        const Text('Gender',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1B4332))),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _GenderBtn(
            label: 'Male',
            icon: Icons.male,
            value: 'male',
            selected: _gender == 'male',
            onTap: () => setState(() => _gender = 'male'),
          )),
          const SizedBox(width: 12),
          Expanded(
              child: _GenderBtn(
            label: 'Female',
            icon: Icons.female,
            value: 'female',
            selected: _gender == 'female',
            onTap: () => setState(() => _gender = 'female'),
          )),
        ]),

        const SizedBox(height: 20),

        // ── Height & Weight ────────────────────────────────
        Row(children: [
          Expanded(
              child: _field(_height, 'Height (cm)',
                  Icons.height,
                  type: TextInputType.number)),
          const SizedBox(width: 14),
          Expanded(
              child: _field(_weight, 'Weight (kg)',
                  Icons.monitor_weight_outlined,
                  type: TextInputType.number)),
        ]),
        const SizedBox(height: 20),

        // ── Body Type ─────────────────────────────────────
        const Text('Body Type',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1B4332))),
        const SizedBox(height: 10),
        ...(_bodyTypes.map((b) => _SelectTile(
              value: b['value'] as String,
              label: b['label'] as String,
              icon: b['icon'] as IconData,
              desc: b['desc'] as String,
              selected: _bodyType == b['value'],
              onTap: () => setState(
                  () => _bodyType = b['value'] as String),
            ))),

        const SizedBox(height: 20),

        // ── Activity Level ────────────────────────────────
        const Text('Activity Level',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1B4332))),
        const SizedBox(height: 10),
        ...(_activities.map((a) => _SelectTile(
              value: a['value'] as String,
              label: a['label'] as String,
              icon: a['icon'] as IconData,
              desc: a['desc'] as String,
              selected: _activity == a['value'],
              onTap: () => setState(
                  () => _activity = a['value'] as String),
            ))),

        const SizedBox(height: 28),

        if (_error != null) ...[
          _errorBox(_error!),
          const SizedBox(height: 14)
        ],

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _signup,
            style: _btnStyle(),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Create Account',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  TextField _field(
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType? type,
  }) =>
      TextField(
          controller: c,
          keyboardType: type,
          decoration: _deco(label, icon));

  InputDecoration _deco(String label, IconData icon,
          {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        prefixIcon:
            Icon(icon, color: const Color(0xFF2D6A4F)),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF2D6A4F), width: 2)),
      );

  ButtonStyle _btnStyle() => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      );

  Widget _errorBox(String msg) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(msg,
            style: TextStyle(
                color: Colors.red.shade700, fontSize: 13)),
      );
}

// ── Step indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int current, total;
  const _StepIndicator(
      {required this.current, required this.total});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        total,
        (i) => Expanded(
          child: Container(
            height: 4,
            margin:
                EdgeInsets.only(right: i < total - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: i <= current
                  ? const Color(0xFF2D6A4F)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Gender button ─────────────────────────────────────────────────────────────
class _GenderBtn extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _GenderBtn({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2D6A4F)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF2D6A4F)
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(children: [
          Icon(icon,
              size: 28,
              color:
                  selected ? Colors.white : Colors.grey.shade600),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : Colors.black87)),
        ]),
      ),
    );
  }
}

// ── Selectable tile ───────────────────────────────────────────────────────────
class _SelectTile extends StatelessWidget {
  final String value, label, desc;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SelectTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.desc,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2D6A4F).withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF2D6A4F)
                : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Icon(icon,
              color: selected
                  ? const Color(0xFF2D6A4F)
                  : Colors.grey.shade600,
              size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? const Color(0xFF2D6A4F)
                              : Colors.black87)),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45)),
                ]),
          ),
          if (selected)
            const Icon(Icons.check_circle,
                color: Color(0xFF2D6A4F), size: 20),
        ]),
      ),
    );
  }
}