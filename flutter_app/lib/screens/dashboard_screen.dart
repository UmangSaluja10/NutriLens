import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/suggestion_service.dart';
import 'analyze_screen.dart';
import 'history_screen.dart';
import 'protein_goal_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String uid;
  const DashboardScreen({super.key, required this.uid});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await AuthService.getUserProfile(widget.uid);
    if (mounted) setState(() => _profile = p);
  }

  /// Called by ResultScreen after saving — resets nav to Dashboard tab
  void _switchToTab(int index) {
    if (mounted) setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7FBF8),
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFF2D6A4F))),
      );
    }

    final screens = [
      _HomeTab(profile: _profile!, onProfileUpdated: _loadProfile),
      // Pass switchToTab so AnalyzeScreen can hand it down to ResultScreen
      AnalyzeScreen(
          profile: _profile!, onMealSaved: () => _switchToTab(0)),
      HistoryScreen(profile: _profile!),
      ProfileScreen(profile: _profile!, onUpdated: _loadProfile),
    ];

    return Scaffold(
      body: screens[_navIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        backgroundColor: Colors.white,
        indicatorColor:
            const Color(0xFF2D6A4F).withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon:
                  Icon(Icons.dashboard, color: Color(0xFF2D6A4F)),
              label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon:
                  Icon(Icons.camera_alt, color: Color(0xFF2D6A4F)),
              label: 'Analyze'),
          NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon:
                  Icon(Icons.history, color: Color(0xFF2D6A4F)),
              label: 'History'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon:
                  Icon(Icons.person, color: Color(0xFF2D6A4F)),
              label: 'Profile'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME TAB
// ─────────────────────────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  final UserProfile profile;
  final VoidCallback onProfileUpdated;
  const _HomeTab(
      {required this.profile, required this.onProfileUpdated});
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  Map<String, Map<String, int>> _weekData = {};
  List<Meal> _todayMeals = [];
  bool _loading = true;

  String get _today =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final week =
        await FirestoreService.getLast7DaysTotals(widget.profile.uid);
    final meals = await FirestoreService.streamMealsForDate(
            widget.profile.uid, _today)
        .first;
    if (mounted) {
      setState(() {
        _weekData = week;
        _todayMeals = meals;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final todayProt =
        _todayMeals.fold(0, (s, m) => s + m.protein);
    final todayCarb =
        _todayMeals.fold(0, (s, m) => s + m.carbs);
    final todayFat = _todayMeals.fold(0, (s, m) => s + m.fat);
    final todayCal =
        _todayMeals.fold(0, (s, m) => s + m.calories);
    final suggestions =
        SuggestionService.getSuggestions(_todayMeals, p);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D6A4F),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${p.name.split(' ').first}! 👋',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            const Text(
              'Here\'s your nutrition today',
              style:
                  TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.track_changes,
                color: Colors.white),
            tooltip: 'Protein Goal',
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ProteinGoalScreen(
                          profile: p,
                          onUpdated: widget.onProfileUpdated)));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color(0xFF2D6A4F)))
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _TodaySummaryCard(
                      calories: todayCal,
                      protein: todayProt,
                      carbs: todayCarb,
                      fat: todayFat,
                      profile: p,
                    ),
                    const SizedBox(height: 16),
                    ...suggestions.map((s) =>
                        _SuggestionBanner(
                            message: s['msg'],
                            type: s['type'])),
                    const SizedBox(height: 16),
                    const Text('7-Day Overview',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B4332))),
                    const SizedBox(height: 10),
                    _WeekChart(
                        weekData: _weekData, profile: p),
                    const SizedBox(height: 16),
                    const Text('Today\'s Macros',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1B4332))),
                    const SizedBox(height: 10),
                    _MacroBar(
                        label: 'Protein',
                        value: todayProt,
                        limit: p.dailyProteinLimit,
                        color: Colors.blue.shade600),
                    _MacroBar(
                        label: 'Carbs',
                        value: todayCarb,
                        limit: p.dailyCarbLimit,
                        color: Colors.amber.shade700),
                    _MacroBar(
                        label: 'Fat',
                        value: todayFat,
                        limit: p.dailyFatLimit,
                        color: Colors.red.shade400),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Today summary card ────────────────────────────────────────────────────────
class _TodaySummaryCard extends StatelessWidget {
  final int calories, protein, carbs, fat;
  final UserProfile profile;
  const _TodaySummaryCard(
      {required this.calories,
      required this.protein,
      required this.carbs,
      required this.fat,
      required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D6A4F), Color(0xFF40916C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today\'s Intake',
              style:
                  TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text('$calories kcal',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              _Pill('Protein', '${protein}g',
                  Colors.blue.shade200),
              _Pill('Carbs', '${carbs}g',
                  Colors.amber.shade200),
              _Pill(
                  'Fat', '${fat}g', Colors.red.shade200),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Pill(this.label, this.value, this.color);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(label,
            style: const TextStyle(
                color: Colors.white60, fontSize: 11)),
      ]);
}

// ── 7-day chart ───────────────────────────────────────────────────────────────
class _WeekChart extends StatelessWidget {
  final Map<String, Map<String, int>> weekData;
  final UserProfile profile;
  const _WeekChart(
      {required this.weekData, required this.profile});

  @override
  Widget build(BuildContext context) {
    final entries = weekData.entries.toList();
    final maxCal = entries.isEmpty
        ? 2000
        : entries
            .map((e) => e.value['calories']!)
            .reduce((a, b) => a > b ? a : b)
            .clamp(200, 4000);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: entries.map((e) {
          final cal = e.value['calories']!;
          final prot = e.value['protein']!;
          final ratio =
              maxCal > 0 ? cal / maxCal : 0.0;
          final isToday = e.key ==
              DateFormat('yyyy-MM-dd')
                  .format(DateTime.now());
          final day = DateFormat('EEE').format(
              DateFormat('yyyy-MM-dd').parse(e.key));
          final protMet =
              prot >= profile.dailyProteinLimit;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              protMet
                  ? const Icon(Icons.star,
                      color: Colors.amber, size: 14)
                  : const SizedBox(height: 14),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration:
                    const Duration(milliseconds: 600),
                width: 26,
                height: (80 * ratio).clamp(4.0, 80.0),
                decoration: BoxDecoration(
                  color: isToday
                      ? const Color(0xFF2D6A4F)
                      : const Color(0xFF95D5B2),
                  borderRadius:
                      BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                day,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isToday
                      ? const Color(0xFF2D6A4F)
                      : Colors.grey,
                ),
              ),
              Text(
                cal > 0 ? '$cal' : '-',
                style: const TextStyle(
                    fontSize: 9, color: Colors.grey),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Macro progress bar ────────────────────────────────────────────────────────
class _MacroBar extends StatelessWidget {
  final String label;
  final int value, limit;
  final Color color;
  const _MacroBar(
      {required this.label,
      required this.value,
      required this.limit,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final ratio =
        limit > 0 ? (value / limit).clamp(0.0, 1.0) : 0.0;
    final exceeded = value > limit;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: exceeded
            ? Border.all(color: Colors.red.shade300)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600)),
              Text('${value}g / ${limit}g',
                  style: TextStyle(
                      fontSize: 13,
                      color: exceeded
                          ? Colors.red
                          : Colors.grey.shade600)),
            ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor:
                color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(
                exceeded ? Colors.red : color),
          ),
        ),
      ]),
    );
  }
}

// ── Suggestion banner ─────────────────────────────────────────────────────────
class _SuggestionBanner extends StatelessWidget {
  final String message, type;
  const _SuggestionBanner(
      {required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    Color bg, border, text;
    if (type == 'success') {
      bg = Colors.green.shade50;
      border = Colors.green.shade300;
      text = Colors.green.shade900;
    } else if (type == 'warning') {
      bg = Colors.orange.shade50;
      border = Colors.orange.shade300;
      text = Colors.orange.shade900;
    } else {
      bg = const Color(0xFFF0F7F4);
      border = const Color(0xFF95D5B2);
      text = const Color(0xFF1B4332);
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(message,
          style: TextStyle(fontSize: 13, color: text)),
    );
  }
}