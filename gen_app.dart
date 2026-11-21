import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF38BDF8)),
      ),
      home: const GenHome(),
    ));

class GenHome extends StatefulWidget {
  const GenHome({super.key});
  @override
  State<GenHome> createState() => _GenHomeState();
}

class _GenHomeState extends State<GenHome> {
  static const owner = 'MDSHAKIL10', repo = 'SHAKILVIPVPN-CONFIG', file = 'servers.svip', key = 'SHAKILVIPVPN_2026_LOCK';
  int _tab = 1;
  bool _busy = false;
  final _tkCtrl = TextEditingController();

  List<Map<String, dynamic>> servers = [
    {"name": "🇩🇪 DE UDP (Hysteria)", "protocol": "hysteria1", "host": "91.107.175.87", "port": "20000-50000", "obfs": "kobe"},
    {"name": "🇸🇬 SG VLESS 443", "protocol": "v2ray", "host": "v2.skvps.xyz", "port": "443", "tls": true},
    {"name": "🇸🇬 SG VLESS 80", "protocol": "v2ray", "host": "v2.skvps.xyz", "port": "80", "tls": false},
  ];
  List<Map<String, dynamic>> payloads = [
    {"name": "⚡ UDP Auto-Mode", "mode": "udp", "path": "", "sni": "", "bugHost": ""},
    {"name": "🇸🇦 STC 443 Business", "mode": "443", "path": "/ws-kobe", "sni": "stc.com.sa", "bugHost": "dns2-448947328279.europe-west3.run.app"},
    {"name": "🇧🇩 Free Net 80 WS", "mode": "80", "path": "/ws-kobe", "sni": "", "bugHost": "://facebook.com"},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _tkCtrl.text = p.getString('gh_tk') ?? '';
    final saved = p.getString('gen_db');
    if (saved != null) {
      final d = jsonDecode(saved);
      setState(() {
        servers = List<Map<String, dynamic>>.from(d['servers'] ?? servers);
        payloads = List<Map<String, dynamic>>.from(d['payloads'] ?? payloads);
      });
    }
  }

  Future<void> _saveLocal() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('gen_db', jsonEncode({'servers': servers, 'payloads': payloads}));
  }

  String _encrypt(String raw) {
    final sb = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      sb.writeCharCode(raw.codeUnitAt(i) ^ key.codeUnitAt(i % key.length));
    }
    return 'SVIP1::${base64Encode(utf8.encode(sb.toString()))}';
  }

  Future<void> _pushGithub() async {
    final tk = _tkCtrl.text.trim();
    if (tk.isEmpty) {
      _msg('আগে HOME ট্যাবে GitHub Token দিন!');
      return;
    }
    setState(() => _busy = true);
    try {
            final api = Uri.https('api.' + 'github.com', '/repos/$owner/$repo/contents/$file');
      final hdr = {'Authorization': 'token $tk', 'Accept': 'application/vnd.github.v3+json', 'Content-Type': 'application/json'};
      String? sha;
      final g = await http.get(api, headers: hdr);
      if (g.statusCode == 200) sha = jsonDecode(g.body)['sha'];

      final encrypted = _encrypt(jsonEncode({'servers': servers, 'payloads': payloads}));
      final body = {'message': 'Auto Update', 'content': base64Encode(utf8.encode(encrypted)), 'branch': 'server_script', if (sha != null) 'sha': sha};
      final p = await http.put(api, headers: hdr, body: jsonEncode(body));
      if (p.statusCode == 200 || p.statusCode == 201) {
        _msg('✅ সফল! সব কাস্টমারের অ্যাপে আপডেট হয়ে গেছে।');
      } else {
        _msg('❌ Error ${p.statusCode}: ${p.body}');
      }
    } catch (e) {
      _msg('❌ Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  void _editDialog({int? idx}) {
    final isSrv = _tab == 1;
    final item = idx != null ? Map<String, dynamic>.from(isSrv ? servers[idx] : payloads[idx]) : <String, dynamic>{};
    final c1 = TextEditingController(text: item['name'] ?? '');
    final c2 = TextEditingController(text: isSrv ? (item['host'] ?? '') : (item['path'] ?? '/ws-kobe'));
    final c3 = TextEditingController(text: isSrv ? (item['port'] ?? '443') : (item['sni'] ?? ''));
    final c4 = TextEditingController(text: isSrv ? (item['obfs'] ?? 'kobe') : (item['bugHost'] ?? ''));
    String sel = isSrv ? (item['protocol'] ?? 'v2ray') : (item['mode'] ?? '443');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, st) => AlertDialog(
          title: Text(idx == null ? 'Add New' : 'Edit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: c1, decoration: const InputDecoration(labelText: 'Name')),
                DropdownButton<String>(
                  isExpanded: true,
                  value: sel,
                  items: (isSrv ? ['v2ray', 'hysteria1'] : ['udp', '443', '80'])
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase())))
                      .toList(),
                  onChanged: (v) => st(() => sel = v!),
                ),
                TextField(controller: c2, decoration: InputDecoration(labelText: isSrv ? 'Host / IP' : 'Path')),
                TextField(controller: c3, decoration: InputDecoration(labelText: isSrv ? 'Port' : 'SNI')),
                TextField(controller: c4, decoration: InputDecoration(labelText: isSrv ? 'Obfs' : 'Bug Host')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final map = isSrv
                    ? {'name': c1.text, 'protocol': sel, 'host': c2.text, 'port': c3.text.trim(), 'obfs': c4.text, 'tls': c3.text.trim() == '443'}
                    : {'name': c1.text, 'mode': sel, 'path': c2.text, 'sni': c3.text, 'bugHost': c4.text};
                setState(() {
                  if (isSrv) {
                    idx == null ? servers.add(map) : servers[idx] = map;
                  } else {
                    idx == null ? payloads.add(map) : payloads[idx] = map;
                  }
                });
                _saveLocal();
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _tab == 1 ? servers : payloads;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SHAKILVIPVPN Gen'),
        actions: [
          ElevatedButton.icon(
            onPressed: _busy ? null : _pushGithub,
            icon: const Icon(Icons.cloud_upload),
            label: Text(_busy ? '...' : 'UPDATE'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _tab == 0
          ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(controller: _tkCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'GitHub Token (ghp_...)')),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      (await SharedPreferences.getInstance()).setString('gh_tk', _tkCtrl.text.trim());
                      _msg('Token Saved!');
                    },
                    child: const Text('Save Token'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (_, i) => Card(
                child: ListTile(
                  title: Text(list[i]['name'] ?? ''),
                  subtitle: Text(_tab == 1 ? '${list[i]['protocol']} • ${list[i]['host']}:${list[i]['port']}' : 'Mode: ${list[i]['mode']} • SNI: ${list[i]['sni']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _editDialog(idx: i)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () { setState(() => list.removeAt(i)); _saveLocal(); }),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: _tab == 0 ? null : FloatingActionButton(onPressed: () => _editDialog(), child: const Icon(Icons.add)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (v) => setState(() => _tab = v),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.vpn_key), label: 'HOME'),
          BottomNavigationBarItem(icon: Icon(Icons.dns), label: 'SERVER'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'PAYLOAD'),
        ],
      ),
    );
  }
}
