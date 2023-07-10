import 'package:corider/models/user_model.dart';
import 'package:corider/utils/utils.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  final UserModel user;
  final bool isCurrentUser;

  const UserProfileScreen({super.key, required this.user, this.isCurrentUser = false});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isCurrentUser ? const Text('Profile') : Text(widget.user.fullName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Personal Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(widget.user.email),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Name'),
              subtitle: Text(widget.user.fullName),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Company'),
              subtitle: Text(widget.user.companyName),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Vehicle Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
            if (widget.user.vehicle != null) ...[
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Year'),
                subtitle: Text(widget.user.vehicle!.year?.toString() ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.car_rental),
                title: const Text('Make-Model'),
                subtitle: Text('${widget.user.vehicle!.make ?? 'N/A'} ${widget.user.vehicle!.model ?? 'N/A'}'),
              ),
              ListTile(
                leading: const Icon(Icons.color_lens),
                title: const Text('Color'),
                subtitle: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: Utils.getColorFromValue(widget.user.vehicle!.color ?? 'N/A'),
                      margin: const EdgeInsets.only(right: 8),
                    ),
                    Text(widget.user.vehicle!.color ?? 'N/A'),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('License Plate'),
                subtitle: Text(widget.user.vehicle!.licensePlate ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.event_seat),
                title: const Text('Available Seats'),
                subtitle: Text(widget.user.vehicle!.availableSeats?.toString() ?? 'N/A'),
              ),
            ] else
              const ListTile(
                leading: Icon(Icons.directions_car),
                title: Text('No vehicle information'),
              ),
          ],
        ),
      ),
    );
  }
}
