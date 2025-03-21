import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/deliveryboy_widget/Canceled_status_modal.dart';
import 'package:water_management_system/widgets/deliveryboy_widget/delivered_status_modal.dart';
import 'package:water_management_system/widgets/deliveryboy_widget/add_order_modal.dart';
import 'package:water_management_system/widgets/super_admin_widget/order_preview_modal.dart';

import '../navigation/sidebar.dart';
import 'package:water_management_system/providers/auth_provider.dart';

class DeliveryboyOrderScreen extends StatefulWidget {
  const DeliveryboyOrderScreen({Key? key}) : super(key: key);

  static const routeName =
      '/delivery-boy-order-screen'; // Add a route name for navigation

  @override
  _DeliveryboyOrderScreenState createState() => _DeliveryboyOrderScreenState();
}

class _DeliveryboyOrderScreenState extends State<DeliveryboyOrderScreen> {
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> orders = [];
  int _currentPage = 0; // Track the current page
  final int _itemsPerPage = 4; // Number of items per page
  String? _selectedStatus;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> filteredDeliveryboyOrders = [];

  @override
  void initState() {
    super.initState();
    _fetchDeliveryboyOrder();
  }

  void _fetchDeliveryboyOrder() {
    setState(() {
      _ordersFuture = _authService.fetchDeliveryboyOrder(context);
    });
  }

  void _filterDeliveryBoyOrders(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      filteredDeliveryboyOrders = orders.where((order) {
        final customer =
            order['CustomerID']?['Name']?.toString().toLowerCase() ?? '';
        final orderID = order['OrderID']?.toString().toLowerCase() ?? '';
        final status = order['Status']?.toString().toLowerCase() ?? '';
        return customer.contains(_searchQuery) ||
            orderID.contains(_searchQuery) ||
            status.contains(_searchQuery);
      }).toList();
      _currentPage = 0; // Reset to first page when search changes
    });
  }

  List<Map<String, dynamic>> _getPaginatedDeliveryboyOrders() {
    final listToUse = _searchQuery.isEmpty ? orders : filteredDeliveryboyOrders;
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return listToUse.sublist(
      startIndex,
      endIndex > listToUse.length ? listToUse.length : endIndex,
    );
  }

// Method to get the color based on the status
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Processing':
        return Colors.orange;
      case 'Out For Delivery':
        return Colors.lightBlueAccent;
      case 'Delivered':
        return Colors.green;
      case 'Canceled':
        return Colors.red;
      default:
        return Colors.black; // Default color for unknown status
    }
  }

  String? _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return null;
    }
    try {
      // Parse the date string
      DateTime date = DateTime.parse(dateStr);
      // Format the date as "dd/MM/yyyy" or any format you prefer
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      // Return null if parsing fails
      return null;
    }
  }


  int get totalPages {
    final listToUse = _searchQuery.isEmpty ? orders : filteredDeliveryboyOrders;
    return (listToUse.length / _itemsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch role from the AuthProvider
    final role = Provider.of<AuthProvider>(context).role;

    final totalItems =
        _searchQuery.isEmpty ? orders.length : filteredDeliveryboyOrders.length;
    return Scaffold(
      appBar: AppBar(
        title: Text("Deliveryboy Orders",
            style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      drawer: Sidebar(
        role: role, // Pass the role to the Sidebar
        onMenuItemClicked: (route) {
          Navigator.pushNamed(context, route);
        },
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search by name, order ID, or status...',
                    hintStyle:
                        GoogleFonts.lato(fontSize: 16, color: Colors.black54),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _filterDeliveryBoyOrders,
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: SingleChildScrollView(
                child: Shimmer.fromColors(
                      baseColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]! // Dark grey for dark mode
                          : Colors.grey[300]!, // Light grey for light mode
                      highlightColor: Theme.of(context).brightness ==
                              Brightness.dark
                          ? Colors.grey[
                              700]! // Slightly lighter dark grey for dark mode
                          : Colors.grey[
                              100]!, // Slightly lighter grey for light mode
                  child: Column(
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: double.infinity,
                              height: 230,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[
                                        900]! // Dark background for dark mode
                                    : Colors.white,
                              ),
                              // White background for light mode
                        ),
                      );
                    }),
                  ),
                ),
                  ),
                )
              ]),
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('No orders found.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          } else {
            orders = snapshot.data!;
            final paginatedDeliveryboys = _getPaginatedDeliveryboyOrders();
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search by name, order ID, or status...',
                      hintStyle:
                          GoogleFonts.lato(fontSize: 16, color: Colors.black54),
      
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: _filterDeliveryBoyOrders,
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: paginatedDeliveryboys.length,
                    itemBuilder: (context, index) {
                      final customer = paginatedDeliveryboys[index];

                      return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border(
                              top: BorderSide(
                                  color: Colors.grey, width: 1), // Top border
                              left: BorderSide(
                                  color: Colors
                                      .grey, // Uses the theme's default border color

                                  width: 1), // Left border
                              right: BorderSide(
                                  color: Colors.grey, width: 2), // Right border
                              bottom: BorderSide(
                                  color: Colors.grey,
                                  width:
                                      2), // Thicker border on the bottom for 3D effect // Thicker border on the bottom for 3D effect
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(3, 3), // Shadow on bottom right
                              ),
                            ],
                          ),
                          child: Card(
                            
                            margin: EdgeInsets
                                .zero, // No additional margin here as we handle it in the outer container
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation:
                                0, // We don't need the card's internal shadow since we are using BoxShadow
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile icon and Name
                                  Row(
                                    children: [
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          customer['OrderID'] ?? 'N/A',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                           
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(
                                      height: 8), // Space after profile section

                                  // Customer details with key-value pairs on the same line
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Email

                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Status: ",
                                              style: GoogleFonts.sourceCodePro(
                                                fontSize: 14,
                                               
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if ([
                                              'Processing',
                                              'Delivered',
                                              'Canceled'
                                            ].contains(customer['Status']))
                                              //  (customer['Status'] == 'Processing')
                                              // Show label if status is 'Processing'
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                          customer['Status'])
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0), // Apply rounded corners
                                                ),
                                                child: Text(
                                                    customer[
                                                        'Status'], // Display the status as text
                                                    style: GoogleFonts
                                                        .sourceCodePro(
                                                      fontSize: 12,
                                                      color: _getStatusColor(
                                                          customer[
                                                              'Status']), // Text color matches the status color
                                                    )),
                                              )
                                            else
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: 200),
                                                child: DropdownButton<String>(
                                                  value: customer['Status'],
                                                  items: [
                                                    'Out For Delivery',
                                                    'Delivered',
                                                    'Canceled'
                                                  ]
                                                      .map((status) =>
                                                          DropdownMenuItem(
                                                            value: status,
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          4),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: _getStatusColor(
                                                                        status)
                                                                    .withOpacity(
                                                                        0.2), // Set background color
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0), // Apply rounded corners
                                                              ),
                                                              child: Text(
                                                                status,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: _getStatusColor(
                                                                      status), // White text for better contrast
                                                                ),
                                                              ),
                                                            ),
                                                          ))
                                                      .toList(),
                                                  onChanged: (newValue) async {
                                                    if (newValue == null ||
                                                        newValue ==
                                                            customer['Status'])
                                                      return; // No change

                                                    String originalStatus =
                                                        customer[
                                                            'Status']; // Store original status
                                                    bool? result;

                                                    if (newValue ==
                                                        "Canceled") {
                                                      result = await showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return CanceledStatusModal(
                                                              order: customer);
                                                        },
                                                      );
                                                    } else if (newValue ==
                                                        "Delivered") {
                                                      result = await showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return DeliveredStatusModal(
                                                              order: customer);
                                                        },
                                                      );
                                                    } else {
                                                      result =
                                                          true; // Directly allow change for "Out For Delivery"
                                                    }

                                                    if (result == true) {
                                                      _fetchDeliveryboyOrder();
                                                      setState(() {
                                                        customer['Status'] =
                                                            newValue;
                                                      });
                                                    } else {
                                                      // If the user closes the dialog, revert to original status
                                                      setState(() {
                                                        customer['Status'] =
                                                            originalStatus;
                                                      });
                                                    }
                                                  },
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 4),

                                      // Phone
                                      // Price Per Liter
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Name: ",
                                              style: GoogleFonts.sourceCodePro(
                                                  fontSize: 14,
                                                 
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Expanded(
                                              child: Text(
                                                customer['CustomerID']
                                                        ?['Name'] ??
                                                    'N/A',
                                                style:
                                                    GoogleFonts.sourceCodePro(
                                                        fontSize: 14,
                                                        color: Color.fromARGB(
                                                            255,
                                                            196,
                                                            196,
                                                            191)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4),

                                      //
                                      //// Price Per Liter
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Delivery Date: ",
                                              style: GoogleFonts.sourceCodePro(
                                                  fontSize: 14,
                                                 
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Expanded(
                                              child: Text(
                                                _formatDate(customer[
                                                        'DeliveryDate']) ??
                                                    'N/A',
                                                style:
                                                    GoogleFonts.sourceCodePro(
                                                        fontSize: 14,
                                                        color: Color.fromARGB(
                                                            255,
                                                            196,
                                                            196,
                                                            191)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4),

                                      // Price Per Liter
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Updated At: ",
                                              style: GoogleFonts.sourceCodePro(
                                                  fontSize: 14,
                                                 
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Expanded(
                                              child: Text(
                                                _formatDate(customer[
                                                        'updated_at']) ??
                                                    'N/A',
                                                style:
                                                    GoogleFonts.sourceCodePro(
                                                        fontSize: 14,
                                                        color: Color.fromARGB(
                                                            255,
                                                            196,
                                                            196,
                                                            191)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          height:
                                              4), // Add space before buttons
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Order Comment: ",
                                              style: GoogleFonts.sourceCodePro(
                                                fontSize: 14,
                                               
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                customer['OrderComment'] ??
                                                    'N/A', // Check if OrderComment exists
                                                style:
                                                    GoogleFonts.sourceCodePro(
                                                  fontSize: 14,
                                                  color: Color.fromARGB(
                                                      255, 196, 196, 191),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow
                                                    .ellipsis, // Handle long text gracefully
                                              ),
                                            ),
                                          ],
                                        ),
),
                                      SizedBox(height: 10), //

                                    ],
                                  ),

                                  // Action Buttons (Edit and Delete)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Edit Button

                                      // Space between buttons

                                      // Delete Button

                                      const SizedBox(width: 20),

                                      SizedBox(
                                        width: 80,
                                        height: 40, // Set width for the button
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            primary: Colors
                                                .white, // Button background color
                                            onPrimary: Colors
                                                .green, // Text and icon color
                                            elevation: 3, // Add shadow
                                            shadowColor: Colors.greenAccent
                                                .withOpacity(
                                                    1), // Shadow color with opacity
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      10), // Rounded corners
                                            ),
                                            //side: BorderSide(color: Colors.redAccent, width: 1), // Border style
                                            padding: const EdgeInsets.symmetric(
                                                vertical:
                                                    12), // Padding inside the button
                                          ),
                                          onPressed: () async {
                                            final result = await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return OrderPreviewModal(
                                                  order: customer,
                                                );
                                              },
                                            );
                                            if (result == true) {
                                              _fetchDeliveryboyOrder();
                                            }
                                          },
                                          icon: Icon(Icons.visibility,
                                              size: 18), // Icon for the button
                                          label: Text(
                                            'View',
                                            style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ));
                    },
                  ),
                ),
                // Pagination Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: _currentPage > 0
                          ? () {
                              setState(() {
                                // Move to the previous chunk of pages (e.g., 0-4 to 5-9)
                                if (_currentPage % 5 == 0) {
                                  _currentPage -= 5;
                                } else {
                                  _currentPage--;
                                }
                              });
                            }
                          : null, // Disable if on the first page
                    ),

                    // Scrollable List of Page Numbers
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Calculate the total pages based on filtered or all data
                          Builder(
                            builder: (context) {
                              int totalPages = (((_searchQuery.isEmpty
                                              ? orders.length
                                              : filteredDeliveryboyOrders
                                                  .length) -
                                          1) /
                                      _itemsPerPage)
                                  .ceil();

                              // Calculate remaining pages
                              int remainingPages = totalPages - _currentPage;

                              // Determine the chunk size (5 pages at a time, but adjust for remaining pages)
                              int chunkSize =
                                  remainingPages < 5 ? remainingPages : 5;

                              // Generate the visible pages (show pages in chunks of 5 or remaining pages)
                              return Row(
                                children: List.generate(
                                  chunkSize,
                                  (index) {
                                    // Determine which page to show based on the current chunk
                                    int pageToShow = _currentPage + index;

                                    // Ensure the page number is within the valid range
                                    if (pageToShow < totalPages) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _currentPage = pageToShow;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 8.0),
                                            decoration: BoxDecoration(
                                              color: _currentPage == pageToShow
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color:
                                                    _currentPage == pageToShow
                                                        ? Theme.of(context)
                                                            .primaryColor
                                                        : Theme.of(context)
                                                            .dividerColor,
                                              ),
                                            ),
                                            child: Text(
                                              (pageToShow + 1).toString(),
                                              style: TextStyle(
                                                color:
                                                    _currentPage == pageToShow
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(); // Skip out-of-range pages
                                  },
                                ).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Forward Button
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _currentPage <
                              (((_searchQuery.isEmpty
                                                  ? orders.length
                                                  : filteredDeliveryboyOrders
                                                      .length) -
                                              1) /
                                          _itemsPerPage)
                                      .ceil() -
                                  1
                          ? () {
                              setState(() {
                                // Move to the next chunk of pages (e.g., 5-9 to 10-14)
                                if ((_currentPage + 1) % 5 == 0) {
                                  _currentPage += 5;
                                } else {
                                  _currentPage++;
                                }
                              });
                            }
                          : null, // Disable if on the last page
                    ),
                  ],
                )
              ],
            );
          }
        },
      ),
      floatingActionButton: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 30), // Adjust for upward movement
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            tooltip: 'Add New Order',
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DeliveryboyOrderModal();
                },
              );
              if (result == true) {
                _fetchDeliveryboyOrder();
              }
            },
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
