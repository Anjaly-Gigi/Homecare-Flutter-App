import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class PaymentPage extends StatefulWidget {
  final int requestId; // Add requestId field
  final double amount;

  const PaymentPage({super.key, required this.requestId, required this.amount}); // Add constructor

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
   TextEditingController textEditingController = new TextEditingController();
  late Razorpay _razorpay;
 
    final supabase = Supabase.instance.client; // Initialize Supabase




  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
   
    
    // Event Listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_uRdap9XZkoyW3z', // Replace with your Razorpay key
      'amount': widget.amount*100, 
      'name': 'HomeCare',
      'description': 'Payment',
      'prefill': {
        'contact': '8888888888',
        'email': 'test@razorpay.com'
      },
      'theme': {'color': '#00245E'},
      'international': true,

    };

    try {
    _razorpay.open(options);
  } catch (e) {
    debugPrint(e.toString());
  }
}
    

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  try {
    final supabase = Supabase.instance.client;

    await supabase
        .from('tbl_request')
        .update({'status': 6})
        .match({'id': widget.requestId}); // Convert to string if id is UUID

    Fluttertoast.showToast(
      msg: 'Payment Successful! Status Updated.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );

    Navigator.pop(context); // Go back to MyBookings after success
  } catch (e) {
    Fluttertoast.showToast(
      msg: '❌ Error updating status in Supabase: $e',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }
}


  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: 'Payment Failed: ${response.message}',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: 'External Wallet Selected: ${response.walletName}',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 71, 132),
        title: Text("RazorPay",style: TextStyle(color: Colors.white),),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               
                ElevatedButton(
            onPressed: _openCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00245E),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: const Text('Pay Now', style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
              ],
            ),
        
        ),
      ),
    );
  }
}
 
// Removed invalid WebView widget. If needed, use a proper WebView implementation.

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payment Method'),
//         backgroundColor: const Color(0xFF00245E),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _openCheckout,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF00245E),
//             padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//           ),
//           child: const Text('Pay Now', style: TextStyle(fontSize: 20, color: Colors.white)),
//         ),
//       ),
//     );
//   }
// }