import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/ledger_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  bool _useAudioFeedback = false;
  bool _useDarkMode = false;
  String _language = 'ja';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _useAudioFeedback = prefs.getBool('useAudioFeedback') ?? false;
      _useDarkMode = prefs.getBool('useDarkMode') ?? false;
      _language = prefs.getString('language') ?? 'ja';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useAudioFeedback', _useAudioFeedback);
    await prefs.setBool('useDarkMode', _useDarkMode);
    await prefs.setString('language', _language);

    // Apply settings
    if (_useDarkMode) {
      // TODO: Implement dark mode
    }

    if (_useAudioFeedback) {
      // TODO: Initialize TTS
    }

    // TODO: Apply language change
  }

  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('キャッシュをクリアしました'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラーが発生しました: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('音声フィードバック'),
            subtitle: const Text('操作時に音声で案内します'),
            trailing: Switch(
              value: _useAudioFeedback,
              onChanged: (value) {
                setState(() {
                  _useAudioFeedback = value;
                });
                _saveSettings();
              },
            ),
          ),
          ListTile(
            title: const Text('ダークモード'),
            subtitle: const Text('画面を暗く表示します'),
            trailing: Switch(
              value: _useDarkMode,
              onChanged: (value) {
                setState(() {
                  _useDarkMode = value;
                });
                _saveSettings();
              },
            ),
          ),
          ListTile(
            title: const Text('言語'),
            subtitle: const Text('表示言語を選択します'),
            trailing: DropdownButton<String>(
              value: _language,
              items: const [
                DropdownMenuItem(value: 'ja', child: Text('日本語')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _language = value;
                  });
                  _saveSettings();
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('キャッシュをクリア'),
            subtitle: const Text('保存された画像を削除します'),
            trailing: const Icon(Icons.delete_outline),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('確認'),
                  content: const Text('キャッシュをクリアしますか？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearCache();
                      },
                      child: const Text('クリア'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
