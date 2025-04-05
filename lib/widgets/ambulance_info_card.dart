import 'package:flutter/material.dart';
import './../providers/location_provider.dart';

class AmbulanceInfoCard extends StatelessWidget {
  final Ambulance ambulance;
  final VoidCallback onClose;
  final VoidCallback onRequest;

  const AmbulanceInfoCard({
    super.key,
    required this.ambulance,
    required this.onClose,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ambulance.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.local_hospital, ambulance.vehicleType),
            _buildInfoRow(
              Icons.person,
              'Driver: ${ambulance.driverName}',
            ),
            _buildInfoRow(
              Icons.star,
              'Rating: ${ambulance.rating.toStringAsFixed(1)}',
            ),
            _buildInfoRow(
              Icons.location_on,
              '${ambulance.distanceInKm.toStringAsFixed(1)} km away',
            ),
            _buildInfoRow(
              Icons.access_time,
              'ETA: ${ambulance.estimatedTimeInMinutes} min',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'REQUEST AMBULANCE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}

