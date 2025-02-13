import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:water_management_system/navigation/sidebar.dart';

import 'package:water_management_system/providers/auth_provider.dart';
import 'package:water_management_system/services/auth_service.dart';
import 'package:water_management_system/widgets/customer_widget/add_edit_customer_order_modal.dart';
import 'package:water_management_system/widgets/super_admin_widget/order_preview_modal.dart';




class CustomerOrderScreen extends StatefulWidget {
   final String? customerId;
  const CustomerOrderScreen({Key? key, this.customerId}) : super(key: key);

  static const routeName = '/customer-order-screen'; // Add a route name for navigation

 @override
  _CustomerOrderScreenState createState() =>
      _CustomerOrderScreenState();
}



class _CustomerOrderScreenState
    extends State<CustomerOrderScreen> {


  late Future<List<Map<String, dynamic>>> _ordersFuture;
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> orders = [];
  int _currentPage = 0; // Track the current page
  final int _itemsPerPage = 4; // Number of items per page
  String? _selectedStatus;
  String? _currentCustomer='';
  

  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Secure storage instance

final TextEditingController _searchController = TextEditingController();
String _searchQuery = '';
List<Map<String, dynamic>> filteredDeliveryboyOrders = [];


  @override
  void initState() {
    super.initState();
    _fetchCustomerOrder();
     _fetchCustomerId();
  }

  void _fetchCustomerOrder() {
    setState(() {
      _ordersFuture = _authService.fetchCustomerOrder(context);
    });
  }


  void _filterDeliveryBoyOrders(String query) {
  setState(() {
    _searchQuery = query.toLowerCase();
    filteredDeliveryboyOrders = orders.where((order) {
      final customer =order['CustomerID']?['Name']?.toString().toLowerCase() ?? '';
      final orderID = order['OrderID']?.toString().toLowerCase() ?? '';
      final status = order['Status']?.toString().toLowerCase() ?? '';
      return customer.contains(_searchQuery) ||
          orderID.contains(_searchQuery) ||
          status.contains(_searchQuery);
    }).toList();
    _currentPage = 0; // Reset to first page when search changes
  });
}
  

  //  List<Map<String, dynamic>> _getPaginatedOrders() {
  //   final startIndex = _currentPage * _itemsPerPage;
  //   final endIndex = startIndex + _itemsPerPage;
  //   return orders.sublist(
  //     startIndex,
  //     endIndex > orders.length ? orders.length : endIndex,
  //   );
  // }

  
  List<Map<String, dynamic>> _getPaginatedDeliveryboyOrders() {
  final listToUse = _searchQuery.isEmpty ? orders : filteredDeliveryboyOrders;
  final startIndex = _currentPage * _itemsPerPage;
  final endIndex = startIndex + _itemsPerPage;
  return listToUse.sublist(
    startIndex,
    endIndex > listToUse.length ? listToUse.length : endIndex,
  );
}

bool shouldShowEditButton(String status) {
  return status == "Processing" ;
  
}

Future<void> _fetchCustomerId() async {
  final customerId = await _storage.read(key: 'customerId');
  setState(() {
    _currentCustomer = customerId ?? ''; // Ensure it's never null
  });
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
    
final totalItems = _searchQuery.isEmpty 
    ? orders.length 
    : filteredDeliveryboyOrders.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Orders"),
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
              child: SingleChildScrollView(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Column(
                    children: List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
              ),
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
    decoration: InputDecoration(
      hintText: 'Search by name, order ID, or status...',
      prefixIcon: Icon(Icons.search),
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
      top: BorderSide(color: Colors.black, width: 1),  // Normal border on top
      left: BorderSide(color: Colors.black, width: 1), // Normal border on left
      right: BorderSide(color: Colors.black, width: 3), // Thicker border on the right for 3D effect
      bottom: BorderSide(color: Colors.black, width: 3), // Thicker border on the bottom for 3D effect
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
  child:Card(
  color:  Color(0xFFFCFCF7),
  margin: EdgeInsets.zero, // No additional margin here as we handle it in the outer container
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  ),
  elevation: 0, // We don't need the card's internal shadow since we are using BoxShadow
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
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
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),

        
        SizedBox(height: 8), // Space after profile section

        // Customer details with key-value pairs on the same line
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email
   
Padding(
  padding: const EdgeInsets.only(left: 15),
  child: Row(
    children: [
      Text(
        "Status: ",
        style: GoogleFonts.sourceCodePro(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
 
        // Show label if status is 'Processing'
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
                                                color: _getStatusColor(
                                                        customer['Status'])
                                                    .withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.0), // Apply rounded corners
          ),
          child: Text(
            customer['Status'], // Display the status as text
                                                  style:
                                                      GoogleFonts.sourceCodePro(
                                                    fontSize: 12,
                                                    color: _getStatusColor(customer[
                                                        'Status']), // Text color matches the status color
                                                  )
          ),
        )
  
      
    ],
  ),
),



            SizedBox(height: 4),


            

       
            // Price Per Liter
                  Padding(
                  padding: const EdgeInsets.only(left: 15),
                child:
            Row(
              children: [
                Text(
                  "TotalPrice: ",
                  style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    customer['"TotalPrice'].toString() ?? 'N/A',
                    style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            ),
           ),

  SizedBox(height: 4),


            

       
            // Price Per Liter
                  Padding(
                  padding: const EdgeInsets.only(left: 15),
                child:
            Row(
              children: [
                Text(
                  "Bottles: ",
                  style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    customer['Bottles'][0]['NumberOfBottles'].toString() ?? 'N/A',
                    style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            ),
           ),


                SizedBox(height: 4),


            

       
            // Price Per Liter
                  Padding(
                  padding: const EdgeInsets.only(left: 15),
                child:
            Row(
              children: [
                Text(
                  "Paid Amount: ",
                  style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    customer['"TotalCollectedAmount'].toString() ?? 'N/A',
                    style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            ),
           ),
           
                SizedBox(height: 4),


            

       
            // Price Per Liter
                  Padding(
                  padding: const EdgeInsets.only(left: 15),
                child:
            Row(
              children: [
                Text(
                  "Pending Amount: ",
                  style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    customer['TotalPendingAmount'].toString() ?? 'N/A',
                    style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            ),
           ),
            SizedBox(height: 4),


            //
            //// Price Per Liter
                  Padding(
                  padding: const EdgeInsets.only(left: 15),
                child: Row(
              children: [
                Text(
                  "Delivery Date: ",
                  style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    _formatDate(customer['DeliveryDate']) ?? 'N/A',
                    style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            ),
                  ),
            SizedBox(height: 4),

            
            // Price Per Liter
                  Padding(
                  padding: const EdgeInsets.only(left: 15),
                child:
            Row(
              children: [
                Text(
                  "Updated At: ",
                  style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                   
                     _formatDate(customer['updated_at']) ?? 'N/A',
                    style: GoogleFonts.sourceCodePro(fontSize: 14, color: Colors.black54),
                  ),
                ),
              ],
            ),
                  ),
            SizedBox(height: 18), // Add space before buttons
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
          primary: Colors.white, // Button background color
          onPrimary: Colors.green, // Text and icon color
          elevation: 5, // Add shadow
          shadowColor: Colors.greenAccent.withOpacity(1), // Shadow color with opacity
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          //side: BorderSide(color: Colors.redAccent, width: 1), // Border style
          padding: const EdgeInsets.symmetric(vertical: 12), // Padding inside the button
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
            _fetchCustomerOrder();
          }
         
        },
        icon: Icon(Icons.visibility, size: 18), // Icon for the button
        label: Text(
          'View',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
 SizedBox(width: 20),

    //    SizedBox(
    //   width: 80,
    //   height: 40, // Set width for the button
    //   child: ElevatedButton.icon(
    //     style: ElevatedButton.styleFrom(
    //       primary: Colors.white, // Button background color
    //       onPrimary: Colors.blue, // Text and icon color
          
    //       elevation: 5, // Add shadow
    //       shadowColor: Colors.blueAccent.withOpacity(1), // Shadow color with opacity
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(10), // Rounded corners
    //       ),
    //       //side: BorderSide(color: Colors.blueAccent, width: 1), // Border style
    //       padding: const EdgeInsets.symmetric(vertical: 12), // Padding inside the button
    //     ),
        
    //      onPressed: () async {
    //        final result = await showDialog(
    //          context: context,
    //          builder: (BuildContext context) {
    //             final customerId = _currentCustomer ?? '';
    //            return CustomerOrderModal(
    //              isEditing: true,
    //              order: customer,
    //              orderId: customer['OrderID'].toString(), customerId: customerId,
              
    //            );
    //         },
    //        );
    //        if (result == true) {
    //          _fetchCustomerOrder();
    //        }
    //      },
    //     icon: Icon(Icons.edit, size: 18), // Icon for the button
    //     label: Text(
    //       'Edit',
    //       style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
    //     ),
    //   ),
    // ),

    Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    if (shouldShowEditButton(customer['Status']))// Show button only if status is "Processing"
      SizedBox(
        width: 80,
        height: 40,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              primary: Colors.white, // Button background color
          onPrimary: Colors.blue, // Text and icon color
          
          elevation: 5, // Add shadow
          shadowColor: Colors.blueAccent.withOpacity(1), // Shadow color with opacity
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),
          //side: BorderSide(color: Colors.blueAccent, width: 1), // Border style
          padding: const EdgeInsets.symmetric(vertical: 12), // Padding inside the button
          ),
         
          onPressed: () async {
                 final result = await showDialog(
             context: context,
             builder: (BuildContext context) {
                final customerId = _currentCustomer ?? '';
               return CustomerOrderModal(
                 isEditing: true,
                 order: customer,
                 orderId: customer['OrderID'].toString(), customerId: customerId,
              
               );
            },
           );
           if (result == true) {
             _fetchCustomerOrder();
           }
          },
            icon: Icon(Icons.edit, size: 18), // Icon for the button
        label: Text(
          'Edit',
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        ),
      ),
  ],
),



  ],
),



      ],
    ),
  ),
)



);


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
              int totalPages = (((_searchQuery.isEmpty ? orders.length : filteredDeliveryboyOrders.length) - 1) / _itemsPerPage).ceil();
              
              // Calculate remaining pages
              int remainingPages = totalPages - _currentPage;

              // Determine the chunk size (5 pages at a time, but adjust for remaining pages)
              int chunkSize = remainingPages < 5 ? remainingPages : 5;

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
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentPage = pageToShow;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: _currentPage == pageToShow
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(
                                color: _currentPage == pageToShow
                                    ? Colors.blue
                                    : Colors.grey.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              (pageToShow + 1).toString(),
                              style: TextStyle(
                                color: _currentPage == pageToShow
                                    ? Colors.white
                                    : Colors.black,
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
              (((_searchQuery.isEmpty ? orders.length : filteredDeliveryboyOrders.length) - 1) / _itemsPerPage)
                  .ceil() - 1
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
    padding: const EdgeInsets.only(bottom: 30), // Adjust for upward movement
    child: FloatingActionButton(
      tooltip: 'Add New Order',
      onPressed: () async {

        
        final result = await showDialog(
          context: context,
          builder: (BuildContext context) {
            final customerId = _currentCustomer ?? '';
            return CustomerOrderModal(customerId: customerId,isEditing: false);
          },
        );
        if (result == true) {
          _fetchCustomerOrder();
        }
      },
      child: const Icon(Icons.add),
    ),
  ),
),
floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

    );
  }


    }










