import 'package:flutter/foundation.dart';
import 'package:medical_family_app/data/repo_model/medical_world_repo_model.dart';
import 'package:medical_family_app/data/repo_model/medical_world_repo_model_impl.dart';
import 'package:medical_family_app/network/responses/get_order_detail_and_invoice_response.dart';

class InvoicePageBloc extends ChangeNotifier {
  /// Bloc state
  bool isDisposed = false;

  /// repo model
  MedicalWorldRepoModel model = MedicalWorldRepoModelImpl();

  /// App State
  bool isLoading = false;

  GetOrderDetailAndInVoiceResponse? response;

  InvoicePageBloc(String? orderId) {
    _showLoading();
    model.getOrderDetailAndInvoiceResponse(orderId ?? "").then((response) {
      this.response = response;
      _notifySafely();
      _hideLoading();
    });
  }

  void _showLoading() {
    isLoading = true;
    _notifySafely();
  }

  void _hideLoading() {
    isLoading = false;
    _notifySafely();
  }

  void _notifySafely() {
    if (!isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    super.dispose();
    isDisposed = true;
  }
}
