import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/daily_report_provider.dart';

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
          //=========================
// HEADER
//=========================

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Good Morning 👋",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Water Camper",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xff345CFF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

//=========================
// HERO CARD
//=========================

          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xff345CFF),
                  Color(0xff6C63FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                /// LEFT SIDE

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Today's Collection",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "₹${s.todayCollection.toStringAsFixed(0)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 34,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${s.todayDeliveries} Deliveries Today",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 15),

                /// RIGHT SIDE

                SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator(
                          value: s.totalCustomers == 0
                              ? 0
                              : s.todayDeliveries / s.totalCustomers,
                          strokeWidth: 10,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${s.todayDeliveries}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                          ),
                          const Text(
                            "Delivered",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: _ModernStatCard(
                  title: "Customers",
                  value: "${s.totalCustomers}",
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xff345CFF),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _ModernStatCard(
                  title: "Deliveries",
                  value: "${s.todayDeliveries}",
                  icon: Icons.local_shipping_rounded,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: _ModernStatCard(
                  title: "Pending",
                  value: "₹${s.totalPendingAmount.toStringAsFixed(0)}",
                  icon: Icons.account_balance_wallet_rounded,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _ModernStatCard(
                  title: "Empty",
                  value: "${s.emptyCampersReceived}",
                  icon: Icons.inventory_2_rounded,
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          //==================================
// WEEKLY DELIVERY CHART
//==================================

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Weekly Deliveries",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Last 7 Days",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Delivery",
                        style: TextStyle(
                          color: Color(0xff345CFF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 220,
                  child: provider.deliveryChart.isEmpty
                      ? const Center(
                          child: Text("No delivery data"),
                        )
                      : _BarChart(
                          data: provider.deliveryChart,
                          color: const Color(0xff345CFF),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          //==================================
// REVENUE CHART
//==================================

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Revenue Trend",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Last 7 Days",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Revenue",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                SizedBox(
                  height: 220,
                  child: provider.revenueChart.isEmpty
                      ? const Center(
                          child: Text("No revenue data"),
                        )
                      : _LineChart(
                          data: provider.revenueChart,
                          color: Colors.green,
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 1.15,
            children: [
              _QuickActionCard(
                title: "Add Customer",
                icon: Icons.person_add_alt_1,
                color: const Color(0xff345CFF),
                onTap: () {
                  // TODO
                },
              ),
              _QuickActionCard(
                title: "Add Labour",
                icon: Icons.engineering,
                color: Colors.orange,
                onTap: () {
                  // TODO
                },
              ),
              _QuickActionCard(
                title: "Daily Report",
                icon: Icons.assignment_rounded,
                color: Colors.green,
                onTap: () {
                  // TODO
                },
              ),
              _QuickActionCard(
                title: "Payments",
                icon: Icons.payments_rounded,
                color: Colors.purple,
                onTap: () {
                  // TODO
                },
              ),
            ],
          ),

          const SizedBox(height: 30),

          const SizedBox(height: 30),

          const Text(
            "Recent Activity",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _ActivityTile(
                  color: Colors.green,
                  icon: Icons.check_circle,
                  title: "125 Deliveries Completed",
                  subtitle: "Today's successful deliveries",
                ),
                const Divider(height: 28),
                _ActivityTile(
                  color: Colors.blue,
                  icon: Icons.payments,
                  title: "₹${s.todayCollection.toStringAsFixed(0)} Collected",
                  subtitle: "Today's payment collection",
                ),
                const Divider(height: 28),
                _ActivityTile(
                  color: Colors.orange,
                  icon: Icons.inventory_2,
                  title: "${s.emptyCampersReceived} Empty Campers Returned",
                  subtitle: "Received from customers",
                ),
                const Divider(height: 28),
                _ActivityTile(
                  color: Colors.red,
                  icon: Icons.warning_amber_rounded,
                  title: "${s.undeliveredCount} Deliveries Pending",
                  subtitle: "Need attention",
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
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
        maxY: (data.isEmpty
                ? 10
                : data.map((e) => e.value).reduce((a, b) => a > b ? a : b)) +
            5,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= data.length)
                  return const SizedBox.shrink();
                final date = data[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(date.substring(5),
                      style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 32)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                  toY: data[i].value,
                  color: color,
                  width: 16,
                  borderRadius: BorderRadius.circular(4)),
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
                if (value.toInt() >= data.length)
                  return const SizedBox.shrink();
                return Text(data[value.toInt()].date.substring(5),
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
                data.length, (i) => FlSpot(i.toDouble(), data[i].value)),
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

class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActivityTile({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
