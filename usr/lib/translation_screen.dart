import 'package:flutter/material.dart';
import 'package:couldai_user_app/local_storage_service.dart';
import 'dart:async';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  String _originalText = '';
  String _translatedText = '';
  String _statusMessage = '点击麦克风按钮开始录音';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  Future<void> _startRecording() async {
    try {
      setState(() {
        _isRecording = true;
        _statusMessage = '正在录音中... 请说英语';
        _originalText = '';
        _translatedText = '';
      });
      _animationController.repeat();
      
      // TODO: Implement actual audio recording with Aliyun SDK
      // For now, simulate recording
    } catch (e) {
      setState(() {
        _statusMessage = '录音失败: $e';
        _isRecording = false;
      });
      _animationController.stop();
    }
  }

  Future<void> _stopRecording() async {
    try {
      setState(() {
        _isRecording = false;
        _statusMessage = '处理中，请稍候...';
      });
      _animationController.stop();

      // TODO: Implement actual translation with Aliyun SDK
      // For now, simulate processing and show mock result
      await Future.delayed(const Duration(seconds: 1));
      
      final mockOriginal = 'Hello, how are you today?';
      final mockTranslated = '你好，你今天怎么样？';
      
      setState(() {
        _originalText = mockOriginal;
        _translatedText = mockTranslated;
        _statusMessage = '翻译完成';
      });

      // Save to local storage
      await LocalStorageService.init();
      await LocalStorageService.saveTranslation(_originalText, _translatedText);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('翻译已保存'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = '翻译失败: $e';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实时翻译'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isRecording ? Colors.red : Colors.blue,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    if (_isRecording)
                      RotationTransition(
                        turns: _animationController,
                        child: const Icon(
                          Icons.circle,
                          color: Colors.red,
                          size: 16,
                        ),
                      )
                    else
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _isRecording ? Colors.red.shade800 : Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Translation result display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Original text section
                      Row(
                        children: [
                          Icon(
                            Icons.record_voice_over,
                            size: 20,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '原文 (English)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _originalText.isEmpty ? '识别的英文将显示在这里...' : _originalText,
                              style: TextStyle(
                                fontSize: 16,
                                color: _originalText.isEmpty ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Translated text section
                      Row(
                        children: [
                          Icon(
                            Icons.translate,
                            size: 20,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '译文 (中文)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _translatedText.isEmpty ? '中文翻译将显示在这里...' : _translatedText,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: _translatedText.isEmpty ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Record button
              SizedBox(
                height: 80,
                child: ElevatedButton(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 36,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isRecording ? '停止录音' : '开始录音',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
