import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class LabourAccountsScreen extends StatefulWidget {
  const LabourAccountsScreen({super.key});

  @override
  State<LabourAccountsScreen> createState() => _LabourAccountsScreenState();
}

class _LabourAccountsScreenState extends State<LabourAccountsScreen> {
  List<UserModel> _labourAccounts = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchLabour();
  }

  Future<void> _fetchLabour() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<AuthProvider>().api;
      final res = await api.get('/users/labour');
      _labourAccounts = (res['data'] as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
    }
    setState(() => _loading = false);
  }

  Future<void> _addLabour() async {
    final nameController = TextEditingController();
    final mobileController = TextEditingController();
    final passwordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Labour Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: mobileController, decoration: const InputDecoration(labelText: 'Mobile'), keyboardType: TextInputType.phone),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      ),
    );

    if (result != true || !mounted) return;

    try {
      final api = context.read<AuthProvider>().api;
      await api.post('/users/labour', body: {
        'name': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'password': passwordController.text,
      });
      await _fetchLabour();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Labour account created')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('ApiException: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _addLabour,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Labour Account'),
          ),
        ),
        Expanded(
          child: _labourAccounts.isEmpty
              ? const Center(child: Text('No labour accounts yet'))
              : ListView.builder(
                  itemCount: _labourAccounts.length,
                  itemBuilder: (context, index) {
                    final labour = _labourAccounts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(labour.name[0].toUpperCase()),
                        ),
                        title: Text(labour.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(labour.mobile),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
