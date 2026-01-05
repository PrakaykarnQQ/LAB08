import 'package:flutter/material.dart';

void main() {
  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Home UI',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const DashboardScreen(),
    );
  }
}

class SmartDevice {
  final String id;
  final String name;
  final String type;
  final String imageUrl;
  bool isActive;

  SmartDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.imageUrl,
    this.isActive = false,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<SmartDevice> _devices = [
    SmartDevice(id: '1', name: 'Living Room Light', type: 'Lighting', imageUrl: 'https://rnb.scene7.com/is/image/roomandboard/metro_505736_25e?size=2400,2400&scl=1', isActive: true),
    SmartDevice(id: '2', name: 'Bedroom AC', type: 'Climate', imageUrl: 'https://bedthreads.com/cdn/shop/articles/079a72c72055f50897137e3ae36e87c7934ae857-2000x2800_a91f1530-2df0-41ca-8f2e-ed022adaa4d2.jpg?v=1657004118'),
    SmartDevice(id: '3', name: 'Front Door Camera', type: 'Security', imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-ndexy5Z0_VsG8RKzmrsfEk2uV_VLUbSchQ&s'),
    SmartDevice(id: '4', name: 'Smart TV', type: 'Entertainment', imageUrl: 'https://cdn.mos.cms.futurecdn.net/9nAad5zR5FnLHeyxwEfECJ.jpg'),
    SmartDevice(id: '5', name: 'Kitchen Purifier', type: 'Appliance', imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRgWUrT_27vDtIkPV7CpO94PslKNaYcmx6WmA&s'),
  ];

  // ฟังก์ชันสลับลำดับ (Drag & Drop)
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _devices.removeAt(oldIndex);
      _devices.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Smart Home', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _devices.length,
        onReorder: _onReorder,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return _buildDeviceItem(device, index);
        },
      ),
    );
  }

  Widget _buildDeviceItem(SmartDevice device, int index) {
    return Padding(
      key: ValueKey(device.id), 
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Dismissible(
        key: ValueKey('dismiss_${device.id}'),
        // ปัดขวาเพื่อเปิด (สีเขียว)
        background: _buildSwipeBg(Alignment.centerLeft, Colors.green, Icons.power_settings_new, "Turn ON"),
        // ปัดซ้ายเพื่อตั้งเวลา (สีน้ำเงิน)
        secondaryBackground: _buildSwipeBg(Alignment.centerRight, Colors.blue, Icons.timer, "Schedule"),
        onDismissed: (direction) {
          setState(() {
            if (direction == DismissDirection.startToEnd) {
              device.isActive = true;
            }
            final item = _devices.removeAt(index);
            _devices.insert(index, item);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${device.name}: Action Executed"), duration: const Duration(seconds: 1)),
          );
        },
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(device: device))),
              child: Hero(
                tag: device.id, 
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(device.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                ),
              ),
            ),
            title: Text(device.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.type),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: device.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(device.isActive ? "Online" : "Offline", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.drag_handle, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBg(Alignment align, Color color, IconData icon, String label) {
    return Container(
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (align == Alignment.centerLeft) Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          if (align == Alignment.centerRight) Icon(icon, color: Colors.white),
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final SmartDevice device;
  const DetailScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(device.name)),
      body: Column(
        children: [
          Hero(
            tag: device.id,
            child: Image.network(device.imageUrl, width: double.infinity, height: 300, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                Text(device.type, style: const TextStyle(fontSize: 18, color: Colors.blue)),
                const Divider(height: 40),
                const Text("Quick Controls", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(Icons.power_settings_new, "Power"),
                    _buildActionButton(Icons.settings, "Settings"),
                    _buildActionButton(Icons.history, "Logs"),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(radius: 30, child: Icon(icon, size: 30)),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}

