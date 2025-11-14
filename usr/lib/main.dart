import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:couldai_user_app/translation_service.dart';
import 'package:couldai_user_app/local_storage_service.dart';
import 'package:couldai_user_app/purchase_service.dart';
import 'package:couldai_user_app/translation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await PurchaseService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '实时语音翻译',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isTrialActive = true;
  DateTime? _trialStartTime;

  @override
  void initState() {
    super.initState();
    _checkTrialStatus();
  }

  Future<void> _checkTrialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _trialStartTime = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt('trial_start_time') ?? DateTime.now().millisecondsSinceEpoch);
    final elapsed = DateTime.now().difference(_trialStartTime!);
    setState(() {
      _isTrialActive = elapsed.inHours < 1; // 1 hour free trial
    });
    if (!_isTrialActive) {
      // Show purchase prompt
      _showPurchaseDialog();
    }
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('试用结束'),
        content: const Text('您的1小时免费试用已结束，请购买以继续使用。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              PurchaseService.purchaseSubscription();
            },
            child: const Text('购买'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实时语音翻译'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isTrialActive ? '试用中：剩余${60 - DateTime.now().difference(_trialStartTime!).inMinutes}分钟' : '试用结束',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isTrialActive ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TranslationScreen()),
                );
              } : null,
              child: const Text('开始翻译'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
              child: const Text('翻译历史'),
            ),
            if (!_isTrialActive) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => PurchaseService.purchaseSubscription(),
                child: const Text('购买订阅'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await LocalStorageService.getTranslationHistory();
    setState(() {
      _history = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('翻译历史'),
      ),
      body: ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return ListTile(
            title: Text(item['original']),
            subtitle: Text(item['translated']),
            trailing: Text(item['timestamp']),
          );
        },
      ),
    );
  }
}