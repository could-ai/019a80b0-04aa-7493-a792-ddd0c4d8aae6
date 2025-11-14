import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:couldai_user_app/translation_service.dart';
import 'package:couldai_user_app/local_storage_service.dart';
import 'dart:io';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String _originalText = '';
  String _translatedText = '';
  String _statusMessage = '点击按钮开始录音';

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      setState(() {
        _statusMessage = '需要麦克风权限';
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      final tempDir = Directory.systemTemp;
      final filePath = '${tempDir.path}/recording.m4a';

      await _audioRecorder.start(const RecordConfig(), path: filePath);
      setState(() {
        _isRecording = true;
        _statusMessage = '正在录音...';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '录音失败: $e';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _statusMessage = '处理中...';
      });

      if (path != null) {
        final result = await TranslationService.translateSpeech(path);
        setState(() {
          _originalText = result['original']!;
          _translatedText = result['translated']!;
          _statusMessage = '翻译完成';
        });

        // Save to local storage
        await LocalStorageService.saveTranslation(_originalText, _translatedText);
      }
    } catch (e) {
      setState(() {
        _statusMessage = '翻译失败: $e';
      });
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('实时翻译'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '原文 (English):',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(_originalText),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '译文 (中文):',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _translatedText,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? '停止录音' : '开始录音'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}