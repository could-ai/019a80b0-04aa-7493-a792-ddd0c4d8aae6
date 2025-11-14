import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:couldai_user_app/translation_screen.dart';
import 'package:couldai_user_app/history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      routes: {
        '/translation': (context) => const TranslationScreen(),
        '/history': (context) => const HistoryScreen(),
      },
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
  int _remainingMinutes = 60;
  DateTime? _trialStartTime;

  @override
  void initState() {
    super.initState();
    _checkTrialStatus();
  }

  Future<void> _checkTrialStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final trialStartMillis = prefs.getInt('trial_start_time');
      
      if (trialStartMillis == null) {
        // First time user - start trial
        _trialStartTime = DateTime.now();
        await prefs.setInt('trial_start_time', _trialStartTime!.millisecondsSinceEpoch);
      } else {
        _trialStartTime = DateTime.fromMillisecondsSinceEpoch(trialStartMillis);
      }
      
      final elapsed = DateTime.now().difference(_trialStartTime!);
      final remainingMinutes = 60 - elapsed.inMinutes;
      
      setState(() {
        _isTrialActive = remainingMinutes > 0;
        _remainingMinutes = remainingMinutes > 0 ? remainingMinutes : 0;
      });
      
      if (!_isTrialActive) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showPurchaseDialog();
        });
      }
    } catch (e) {
      print('Error checking trial status: $e');
    }
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
              _handlePurchase();
            },
            child: const Text('购买'),
          ),
        ],
      ),
    );
  }

  void _handlePurchase() {
    // TODO: Implement actual purchase logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('购买功能即将推出')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实时语音翻译'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.translate,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 30),
              Text(
                '英语 → 中文',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _isTrialActive ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isTrialActive ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Text(
                  _isTrialActive 
                    ? '试用中：剩余 $_remainingMinutes 分钟' 
                    : '试用已结束',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isTrialActive ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isTrialActive ? () {
                    Navigator.pushNamed(context, '/translation');
                  } : null,
                  icon: const Icon(Icons.mic, size: 28),
                  label: const Text(
                    '开始翻译',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/history');
                  },
                  icon: const Icon(Icons.history, size: 28),
                  label: const Text(
                    '翻译历史',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (!_isTrialActive) ..[
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _handlePurchase,
                    icon: const Icon(Icons.shopping_cart, size: 28),
                    label: const Text(
                      '购买订阅',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
