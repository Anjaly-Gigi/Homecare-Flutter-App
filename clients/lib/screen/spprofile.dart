import 'package:clients/screen/bookingpage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ServiceProviderProfile extends StatefulWidget {
  const ServiceProviderProfile({Key? key, required this.spId})
      : super(key: key);

  final String? spId;

  @override
  State<ServiceProviderProfile> createState() => _ServiceProviderProfileState();
}

class _ServiceProviderProfileState extends State<ServiceProviderProfile> {
  final supabase = Supabase.instance.client;
  bool isLoading = true;
  Map<String, dynamic> spData = {};
  List<Map<String, dynamic>> reviews = [];
  Map<String, dynamic> userNames = {};
  double averageRating = 0.0;
  int reviewCount = 0;

  Future<void> fetchReviews() async {
    try {
      final response =
          await supabase.from('tbl_review').select().eq('sp_id', widget.spId!);

      final reviewsList = List<Map<String, dynamic>>.from(response);

      // Calculate average rating
      double totalRating = 0;
      for (var review in reviewsList) {
        totalRating += double.parse(review['review_rating'].toString());
      }

      double avgRating =
          reviewsList.isNotEmpty ? totalRating / reviewsList.length : 0;

      setState(() {
        reviews = reviewsList;
        averageRating = avgRating;
        reviewCount = reviewsList.length;
      });

      // Fetch user names for each review
      for (var review in reviews) {
        final userId = review['client_id'];
        if (userId != null) {
          final userResponse = await supabase
              .from('tbl_client')
              .select('client_name')
              .eq('id', userId)
              .single();

          setState(() {
            userNames[userId] = userResponse['client_name'] ?? 'Anonymous';
          });
        }
      }
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.spId != null && widget.spId!.isNotEmpty) {
      fetchSPData();
    } else {
      setState(() {
        isLoading = false;
      });
      print("Invalid spId: ${widget.spId}");
    }
    fetchReviews();
  }

  Future<void> fetchSPData() async {
    try {
      final response = await supabase
          .from('tbl_sp')
          .select("*,tbl_place(*, tbl_district(*))")
          .eq('id', widget.spId!)
          .single();
      setState(() {
        spData = response ?? {};
        isLoading = false;
      });
      print("Data Fetched Successfully");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color.fromARGB(255, 233, 235, 252),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 36, 94),
        title: Text(
          'Service Provider Details',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(color:Colors.white,fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : spData.isNotEmpty
              ? SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display Profile Picture
                        spData['sp_photo'] != null
                            ? Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    spData['sp_photo'],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.person,
                                          size: 120, color: Colors.grey);
                                    },
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(Icons.person,
                                    size: 120, color: Colors.grey),
                              ),
                        SizedBox(height: 10),
                        Text(
                          spData['sp_name'] ?? 'Name not available',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          spData['sp_email'] ?? 'Email not available',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          spData['sp_phone'] ?? 'Phone not available',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          spData['tbl_place']?['place_name'] ??
                              'Place not available',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          spData['tbl_place']?['tbl_district']
                                  ?['district_name'] ??
                              'District not available',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Average Rating
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: averageRating,
                              itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Color(0xFFFFD700),
                              ),
                              itemCount: 5,
                              itemSize: 20.0,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${averageRating.toStringAsFixed(1)} (${reviewCount} ${reviewCount == 1 ? 'review' : 'reviews'})',
                              style: TextStyle(
                                color: Color(0xFF666666),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Reviews Section
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Customer Reviews",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              SizedBox(height: 16),
                
                              // Reviews List
                              reviews.isEmpty
                                  ? Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 10,
                                            offset: Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'No reviews yet. Be the first to review!',
                                          style: TextStyle(
                                            color: Color(0xFF999999),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: reviews.map((review) {
                                        final userId = review['client_id'];
                                        final userName =
                                            userNames[userId] ?? 'Anonymous';
                                        final rating = double.parse(
                                            review['review_rating'].toString());
                
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 16),
                                          padding: EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 10,
                                                offset: Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Color(0xFF64B5F6)
                                                            .withOpacity(0.2),
                                                    child: Text(
                                                      userName
                                                          .substring(0, 1)
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: Color(0xFF64B5F6),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        userName,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        '${DateTime.parse(review['created_at']).toLocal().toString().split(' ')[0]}',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFF999999),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF64B5F6)
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.star,
                                                          size: 16,
                                                          color:
                                                              Color(0xFFFFD700),
                                                        ),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          rating.toString(),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Color(0xFF333333),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 12),
                                              Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF8F9FA),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  review['review_content'] ??
                                                      'No comment',
                                                  style: TextStyle(
                                                    color: Color(0xFF666666),
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Booking(id: widget.spId ?? ''),
                                ),
                              );
                            },
                            child: Text('Book Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              )
              : const Center(child: Text('No Data Found')),
    );
  }
}
