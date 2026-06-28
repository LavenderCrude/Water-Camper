import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report_provider.dart';
import '../../widgets/counter_button.dart';

class FilledOutScreen extends StatefulWidget {
  const FilledOutScreen({super.key});

  @override
  State<FilledOutScreen> createState() => _FilledOutScreenState();
}

class _FilledOutScreenState extends State<FilledOutScreen> {
  late int _count;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _count = context.read<DailyReportProvider>().report?.filledOut ?? 0;
    _controller = TextEditingController(text: _count.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final provider = context.read<DailyReportProvider>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await provider.setFilledOut(_count);

    if (!mounted) return;

    Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Filled out count saved successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? "Something went wrong"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Filled Out"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 140,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.local_shipping_rounded,
                  size: 70,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  "Filled Campers Today",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Select the number of campers filled today",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 20,
                    ),
                    child: BigCounter(
                      value: _count,
                      onIncrement: () => setState(() => _count++),
                      onDecrement: () => setState(() {
                        if (_count > 0) _count--;
                      }),
                      onValueChanged: (value) {
                        setState(() {
                          _count = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text(
                      "Save",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
