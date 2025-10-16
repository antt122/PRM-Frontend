import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prm2/models/my_subscription.dart';
import '../models/api_result.dart';
import '../services/api_service.dart';

class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> {
  late Future<ApiResult<MySubscription>> _subscriptionFuture;

  @override
  void initState() {
    super.initState();
    _subscriptionFuture = ApiService.getMySubscription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gói cước của tôi'),
      ),
      body: FutureBuilder<ApiResult<MySubscription>>(
        future: _subscriptionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.isSuccess || snapshot.data!.data == null) {
            return Center(
              child: Text(snapshot.data?.message ?? 'Bạn chưa đăng ký gói cước nào.'),
            );
          }

          final sub = snapshot.data!.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(sub.planDisplayName, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text(sub.subscriptionStatusName),
                      backgroundColor: sub.subscriptionStatusName == 'Active' ? Colors.green.shade100 : Colors.orange.shade100,
                    ),
                    const Divider(height: 32),
                    _buildInfoRow('Ngày bắt đầu:', DateFormat('dd/MM/yyyy').format(sub.currentPeriodStart)),
                    _buildInfoRow('Ngày kết thúc:', DateFormat('dd/MM/yyyy').format(sub.currentPeriodEnd)),
                    _buildInfoRow('Gia hạn:', sub.renewalBehaviorName),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
