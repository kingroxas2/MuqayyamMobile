// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'claim_page.dart';

// void main() {
//   runApp(MaterialApp(
//     home: RewardsPage(),
//   ));
// }

// class RewardsPage extends StatefulWidget {
//   @override
//   _RewardsPageState createState() => _RewardsPageState();
// }

// class _RewardsPageState extends State<RewardsPage> {
//   int totalPoints = 0; // Initialize totalPoints to 0

//   @override
//   void initState() {
//     super.initState();
//     fetchUserScore(); // Fetch the user's score when the page is initialized
//   }

//   Future<void> fetchUserScore() async {
//     final User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final DocumentSnapshot<Map<String, dynamic>> userDoc =
//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(user.uid)
//               .get();
//       final int? userScore = userDoc.get('score') as int?;
//       if (userScore != null) {
//         setState(() {
//           totalPoints = userScore;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF82618B),
//         title: const Text('Ganjaran'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           // Wrap the Column with SingleChildScrollView
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const Text(
//                 'Ganjaran Khas Untuk Anda!',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.5),
//                       spreadRadius: 2,
//                       blurRadius: 5,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Markah saya',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           totalPoints.toString(),
//                           style: const TextStyle(
//                             fontSize: 24,
//                             color: Color(0xFF82618B),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Ganjaran yang boleh ditebus',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ListView(
//                 shrinkWrap:
//                     true, // Allow the ListView to take the required space
//                 physics:
//                     const NeverScrollableScrollPhysics(), // Disable ListView scrolling
//                 children: [
//                   RewardItem(
//                     title: 'Koupon Guardian',
//                     description:
//                         'Dapatkan kupon diskaun 10% untuk pembelian di Guardian.',
//                     pointsRequired: 20,
//                     imageUrl:
//                         'https://upload.wikimedia.org/wikipedia/commons/c/c3/Guardian_Health_and_Beauty_Sdn_Bhd.png?20160714064721',
//                     userPoints: totalPoints,
//                   ),
//                   RewardItem(
//                     title: 'Penghantaran Grab Percuma',
//                     description:
//                         'Dapatkan penghantaran percuma untuk pembelian di Grab.',
//                     pointsRequired: 2000,
//                     imageUrl:
//                         'https://seeklogo.com/images/G/grab-logo-A2F4D23121-seeklogo.com.png', // Replace with your image URL
//                     userPoints: totalPoints,
//                   ),
//                   RewardItem(
//                     title: 'Keahlian Gym Percuma',
//                     description:
//                         'Dapatkan keahlian percuma selama 1 bulan di Titanium Fitness Kuantan.',
//                     pointsRequired: 500,
//                     imageUrl:
//                         'https://www.lookp.com/assets/logo/titanium-fitness-centre-profile.png', // Replace with your image URL
//                     userPoints: totalPoints,
//                   ),
//                   // Add more reward items here
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// //EDIT UI OF REWARDS HERE

// class RewardItem extends StatelessWidget {
//   final String title;
//   final String description;
//   final int pointsRequired;
//   final String imageUrl;
//   final int userPoints;

//   RewardItem({
//     required this.title,
//     required this.description,
//     required this.pointsRequired,
//     required this.imageUrl,
//     required this.userPoints,
//   });

//   double getProgress() {
//     if (pointsRequired <= 0) {
//       return 1.0; // Completed
//     }
//     return userPoints / pointsRequired;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.5),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Image.network(
//             imageUrl,
//             width: double.infinity,
//             height: 100,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(
//             description,
//             style: const TextStyle(
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 16),
//           LinearProgressIndicator(
//             value: getProgress(),
//             backgroundColor: Colors.grey[300],
//             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF82618B)),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Mata diperlukan: $pointsRequired',
//                 style: const TextStyle(
//                   fontSize: 16,
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: userPoints >= pointsRequired? () {
                  
//                   ScaffoldMessenger.of(context).showSnackBar(
                    
//                     const SnackBar(
//                       content: Text(
//                         'Anda telah berjaya menebus ganjaran ini!',
//                       ),
//                     ),
                    
//                   );

                  

//                   // Implement redemption logic here
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const ClaimPage(),
//                     ),
//                   );
//                 } 
                
//                 : () {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text(
//                         'Anda tidak mempunyai cukup mata untuk menebus ganjaran ini.',
//                       ),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: userPoints >= pointsRequired
//                       ? const Color(0xFF82618B)
//                       : Colors.grey,
//                 ),
//                 child: const Text('Tebus'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
