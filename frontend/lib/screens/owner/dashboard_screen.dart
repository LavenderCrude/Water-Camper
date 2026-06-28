import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/daily_report_provider.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DailyReportProvider>();

    if (provider.isLoading && provider.summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final s = provider.summary;
    if (s == null) {
      return Center(child: Text(provider.error ?? 'Failed to load dashboard'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchDashboard(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Today: ${s.date}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              StatCard(title: 'Total Customers', value: '${s.totalCustomers}', icon: Icons.people),
              StatCard(title: "Today's Deliveries", value: '${s.todayDeliveries}', icon: Icons.local_shipping),
              StatCard(title: 'Undelivered', value: '${s.undeliveredCount}', icon: Icons.cancel),
              StatCard(title: 'Empty Received', value: '${s.emptyCampersReceived}', icon: Icons.inbox),
              StatCard(title: 'Extra Campers', value: '${s.extraCampers}', icon: Icons.add_box),
              StatCard(title: 'Not Received', value: '${s.notReceivedCampers}', icon: Icons.remove_circle),
              StatCard(title: "Today's Collection", value: '₹${s.todayCollection.toStringAsFixed(0)}', icon: Icons.payments),
              StatCard(title: 'Total Pending', value: '₹${s.totalPendingAmount.toStringAsFixed(0)}', icon: Icons.account_balance_wallet),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Daily Deliveries (7 days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: provider.deliveryChart.isEmpty
                ? const Center(child: Text('No delivery data yet'))
                : _BarChart(data: provider.deliveryChart, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 24),
          const Text('Revenue Trend (7 days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: provider.revenueChart.isEmpty
                ? const Center(child: Text('No revenue data yet'))
                : _LineChart(data: provider.revenueChart, color: Colors.green),
          ),
        ],
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<dynamic> data;
  final Color color;

  const _BarChart({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (data.isEmpty ? 10 : data.map((e) => e.value).reduce((a, b) => a > b ? a : b)) + 5,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length) return const SizedBox.shrink();
                final date = data[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(date.substring(5), style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(toY: data[i].value, color: color, width: 16, borderRadius: BorderRadius.circular(4)),
            ],
          );
        }),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<dynamic> data;
  final Color color;

  const _LineChart({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length) return const SizedBox.shrink();
                return Text(data[value.toInt()].date.substring(5), style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i].value)),
            isCurved: true,
            color: color,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
