import 'package:medical_family_app/data/vo_models/item_detail_vo.dart';
import 'package:medical_family_app/data/vo_models/item_vo.dart';

class PostRelatedItemResponse {
  bool? error;
  String? message;
  List<ItemDetailVO>? items;
  int? itemTotal;
  int? page;
  int? rowPerPages;

  PostRelatedItemResponse(
      {this.error,
      this.message,
      this.items,
      this.itemTotal,
      this.page,
      this.rowPerPages});

  PostRelatedItemResponse.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    if (json['items'] != null) {
      items = <ItemDetailVO>[];
      json['items'].forEach((v) {
        items!.add(new ItemDetailVO.fromJson(v));
      });
    }
    itemTotal = json['item total'];
    page = json['page'];
    rowPerPages = json['rowPerPages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.message;
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['item total'] = this.itemTotal;
    data['page'] = this.page;
    data['rowPerPages'] = this.rowPerPages;
    return data;
  }
}
