import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://awbbcyahdusjhmlryvef.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3YmJjeWFoZHVzamhtbHJ5dmVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzkxODgyNDEsImV4cCI6MjA1NDc2NDI0MX0.6Uf3OQIgz466L-14CuUTiGQYxVdgu2ZliCnNcoNDh5I',
  );
  runApp(const MaterialApp(home: Dashboard()));
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final supabase = Supabase.instance.client;
  int totalClients = 0;
  int serviceProviders = 0;
  int totalBookings = 0;
  int pendingRequests = 0;
  int completedRequests = 0;
  int cancelledRequests = 0;

  Map<int, int> skillCounts = {};


  @override
  void initState() {
    super.initState();
    _fetchCounts();
     _fetchRequestStatusCounts();
       _fetchSkillCounts();
  }

  bool isLoading = true;


  Future<void> _fetchCounts() async {
    final clientCountResponse = await supabase.from('tbl_client').select().count();
    final spCountResponse = await supabase.from('tbl_sp').select().count();
    final bookingCountResponse = await supabase.from('tbl_request').select().count();

    setState(() {
      totalClients = clientCountResponse.count ?? 0;
      serviceProviders = spCountResponse.count ?? 0;
      totalBookings = bookingCountResponse.count ?? 0;
    });
  }

 Future<void> _fetchRequestStatusCounts() async {
  final completedResponse = await supabase
      .from('tbl_request')
      .select('id')
      .eq('status', 6);

  final cancelledResponse = await supabase
      .from('tbl_request')
      .select('id')
      .eq('status', 2);

  final pendingResponse = await supabase
      .from('tbl_request')
      .select('id')
      .eq('status', 5);

  setState(() {
    completedRequests = completedResponse.length;
    cancelledRequests = cancelledResponse.length;
    pendingRequests = pendingResponse.length;
    isLoading = false;
  });
}


Future<void> _fetchSkillCounts() async {

    try {
    // Fetch all skill data in one query
    final response = await supabase
        .from('tbl_spskills')
        .select('skill_id');

    // Group by skill_id and count
  Map<int, int> counts = {};
    for (var row in response) {
      int skillId = row['skill_id'];
      counts[skillId] = (counts[skillId] ?? 0) + 1;
    }

    setState(() {
      skillCounts = counts;
      isLoading = false;
    });
  } catch (error) {
    print('Error fetching skill counts: $error');
    setState(() {
      isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard('Total Clients', totalClients.toString(), Colors.blue),
                _buildStatCard('Service Providers', serviceProviders.toString(), Colors.orange),
                _buildStatCard('Total Bookings', totalBookings.toString(), Colors.green),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                   flex: 4,
                  child: Container( 
                    child: _buildChartCard('Request Status', _buildStatusList()),
                    
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,  
                  child: _buildChartCard('Service Provider Skills', _buildPieChart()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget child) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(height: 350, child: child),
          ],
        ),
      ),
    );
  }
Widget _buildStatusList() {
  if (isLoading) {
    return Center(child: CircularProgressIndicator());
  }
  
  return Column(
    children: [
      _buildStatusTile('Completed Requests', completedRequests, Icons.check_circle, Colors.green),
      _buildStatusTile('Pending Requests', pendingRequests, Icons.pending, Colors.orange),
      _buildStatusTile('Cancelled Requests', cancelledRequests, Icons.cancel, Colors.red),
    ],
  );
}

  Widget _buildStatusTile(String title, int count, IconData icon, Color color) {
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildPieChart() {
  if (isLoading) {
    return Center(child: CircularProgressIndicator());
  }

  // Mapping skill IDs to their display names
  Map<int, String> skillNames = {
    1: 'Plumbers',
    2: 'Electricians',
    3: 'Carpenters',
    4: 'Painters',
  };

  // Mapping skill IDs to colors
  Map<int, Color> skillColors = {
    1: Colors.blue,      // Plumbers
    2: Colors.orange,    // Electricians
    3: Colors.green,     // Carpenters
    4: Colors.red,       // Painters
  };

  print("Fetched Skill Counts: $skillCounts"); // Debugging

  return PieChart(
    PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: skillCounts.entries.map((entry) {
        int skillId = entry.key;
        double count = entry.value.toDouble();

        return PieChartSectionData(
          color: skillColors.containsKey(skillId) ? skillColors[skillId]! : Colors.purple, // Default color
          value: count,
          title: '${skillNames[skillId] ?? 'Unknown'}\n(${entry.value})',
          radius: 50,
          titleStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList(),
    ),
  );
}
}