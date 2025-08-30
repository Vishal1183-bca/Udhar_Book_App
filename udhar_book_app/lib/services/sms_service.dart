import '../models/customer.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SmsService {
  static Future<void> sendTransactionSms(Customer customer, Transaction transaction) async {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    final date = formatter.format(transaction.date);
    
    String message;
    String balanceText = customer.balance > 0 ? 'Pending: ₹${customer.balance.toStringAsFixed(2)}' : 'All Clear';
    
    switch (transaction.type) {
      case TransactionType.credit:
        message = "Purchase: ${transaction.itemName}\nAmount: ₹${transaction.amount}\nDate: $date\n$balanceText";
        break;
      case TransactionType.debit:
        message = "Payment: ₹${transaction.amount}\nDate: $date\n$balanceText";
        break;
      case TransactionType.payment:
        message = "Balance Cleared: ₹${transaction.amount}\nDate: $date\nAll Clear!";
        break;
    }

    try {
      final String encodedMessage = Uri.encodeComponent(message);
      final Uri smsUri = Uri.parse('sms:${customer.mobile}?body=$encodedMessage');
      
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (e) {
      print('SMS error: $e');
    }
  }
}