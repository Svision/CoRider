import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/chat/chat_list.dart';
import 'package:corider/screens/home/upcoming_rides.dart';
import 'package:corider/screens/home/my_offers.dart';
import 'package:corider/widgets/notification_badge.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) changePageIndex;
  final UserState userState;
  const HomeScreen({Key? key, required this.userState, required this.changePageIndex}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoadingOffers = false;

  Future<void> fetchAllOffers() async {
    setState(() {
      isLoadingOffers = true;
    });
    await widget.userState.fetchAllOffers();
    setState(() {
      isLoadingOffers = false;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.userState.storedOffers.isEmpty) fetchAllOffers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoRider'),
        actions: [
          Stack(alignment: Alignment.center, children: [
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ChatListScreen(userState: widget.userState);
                }));
              },
            ),
            if (widget.userState.totalNotificationsCount != 0)
              Positioned(
                top: 7,
                right: widget.userState.totalNotificationsCount > 9 ? 0 : 5,
                child: NotificationBadge(
                  totalNotifications: widget.userState.totalNotificationsCount,
                  forTotal: true,
                ),
              ),
          ]),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Upcoming Rides',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Expanded(
            child: isLoadingOffers
                ? const Center(child: CircularProgressIndicator())
                : UpcomingRides(
                    userState: widget.userState,
                    fetchAllOffers: fetchAllOffers,
                    changePageIndex: widget.changePageIndex),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'My Ride Offers',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Expanded(
              child: isLoadingOffers
                  ? const Center(child: CircularProgressIndicator())
                  : MyOffers(userState: widget.userState, fetchAllOffers: fetchAllOffers)),
        ],
      ),
    );
  }
}
