import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:medical_family_app/constants/texts/texts.dart';
import 'package:medical_family_app/data/repo_model/medical_world_repo_model.dart';
import 'package:medical_family_app/data/repo_model/medical_world_repo_model_impl.dart';
import 'package:medical_family_app/data/vo_models/brand_item_vo.dart';
import 'package:medical_family_app/data/vo_models/item_vo.dart';
import 'package:medical_family_app/data/vo_models/sub_category_vo.dart';

class ProductLinePageBloc extends ChangeNotifier {
  /// bloc state
  bool isDisposed = false;

  /// repo model
  MedicalWorldRepoModel model = MedicalWorldRepoModelImpl();

  /// App States
  bool isLoading = false;
  List<BrandItemVO?>? brandList = [];
  List<ItemVO?>? itemList = [];
  List<SubCategoryVO?>? subcategoryList = [];
  String? categoryId = "1";
  int selectedProductIndex = 0;
  String? hintText = SEARCH_TEXT;
  String currentSubCat = "-1";
  String page = "1";
  bool isScrollLoading = false;

  ///
  List<int>? brands;
  List<Widget>? tabs;
  List<dynamic>? subList;
  List<dynamic>? products;
  List<int?>? productIdList;
  List<int?>? originalIdList;

  ProductLinePageBloc(String? searchItem) {
    _showLoading();
    model.getBrandsWithoutLogo().then((brandList) {
      this.brandList = brandList;
      tabs =
          brandList.map((e) => _tabForBrandList(e.categoryName ?? "")).toList();
      brands = brandList.map((e) => e.id ?? 0).toList();
      _notifySafely();
    });

    model
        .getItemsAndSubCategoriesByCategory(categoryId ?? "1", page)
        .then((response) {
      subcategoryList = response.subs;
      subcategoryList?.sort(_customCompare);
      subList = subcategoryList?.map((e) => e?.name).toList();
      products = ["All"];
      products?.addAll(subList ?? []);
      productIdList = [-1];
      originalIdList = subcategoryList?.map((e) => e?.id).toList();
      productIdList?.addAll(originalIdList ?? []);
      _notifySafely();
      if (searchItem == null) {
        itemList = response.items;

        _notifySafely();
      } else {
        hintText = searchItem;
        _notifySafely();
        model.postSearchStringToGetItems(searchItem).then((value) {
          itemList = value;
          _notifySafely();
        });
      }
    }).whenComplete(() => _hideLoading());
  }

  int _customCompare(SubCategoryVO? a, SubCategoryVO? b) {
    List<String> frontItems = [
      'medicalscrubs3',
      'medicalscrub2',
      'medicalscrubs1',
    ];
    if (frontItems.contains(a?.name) && frontItems.contains(b?.name)) {
      return subcategoryList!.indexOf(a) - subcategoryList!.indexOf(b);
    } else if (frontItems.contains(a?.name)) {
      return -1;
    } else if (frontItems.contains(b?.name)) {
      return 1;
    } else {
      return 0;
    }
  }

  Widget _tabForBrandList(String text) {
    return Tab(text: text);
  }

  void onSearchItem(String? search) {
    if (!isLoading) {
      _showLoading();
      hintText = search;
      page = "1";
      _notifySafely();
      model.postSearchStringToGetItems(search ?? "").then((value) {
        itemList = value;

        _notifySafely();
      }).whenComplete(() => _hideLoading());
    }
  }

  void onTapCategory(String categoryId) {
    if (!isLoading) {
      _showLoading();
      this.categoryId = categoryId;
      selectedProductIndex = 0;
      currentSubCat = "-1";
      page = "1";
      _notifySafely();
      model
          .getItemsAndSubCategoriesByCategory(categoryId, page)
          .then((response) {
        subcategoryList = response.subs;
        if (categoryId == "1") {
          subcategoryList?.sort(_customCompare);
        }
        subList = subcategoryList?.map((e) => e?.name).toList();
        products = ["All"];
        products?.addAll(subList ?? []);
        productIdList = [-1];
        originalIdList = subcategoryList?.map((e) => e?.id).toList();
        productIdList?.addAll(originalIdList ?? []);
        itemList = response.items;

        _notifySafely();
      }).whenComplete(() => _hideLoading());
    }
  }

  void onTapSubCategory(String subCategoryId, int index) {
    if (!isLoading) {
      _showLoading();
      selectedProductIndex = index;
      currentSubCat = subCategoryId;
      page = "1";
      _notifySafely();
      if (currentSubCat == "-1") {
        model
            .getItemsAndSubCategoriesByCategory(categoryId ?? "2", page)
            .then((response) {
          itemList = response.items;
          _notifySafely();
        }).whenComplete(() => _hideLoading());
      } else {
        model
            .getItemsByCategoryAndSubCategory(
                categoryId ?? "2", currentSubCat, page)
            .then((response) {
          itemList = response.items;
          _notifySafely();
        }).whenComplete(() => _hideLoading());
      }
    }
  }

  void onTapNext() {
    if (!isScrollLoading) {
      isScrollLoading = true;
      var pageNo = int.tryParse(page) ?? 1;
      pageNo++;
      page = pageNo.toString();
      _notifySafely();
      if (currentSubCat == "-1") {
        model
            .getItemsAndSubCategoriesByCategory(categoryId ?? "2", page)
            .then((response) async {
          itemList = response.items;

          ///itemList?.addAll(response.items?.toList() ?? []);
          await Future.delayed(const Duration(seconds: 1));
          isScrollLoading = false;
          _notifySafely();
          // if (itemList!.length <= 12) {
          //   itemList = response.items;
          //
          //   ///itemList?.addAll(response.items?.toList() ?? []);
          //   await Future.delayed(const Duration(seconds: 2));
          //   isScrollLoading = false;
          //   _notifySafely();
          // } else {
          //   itemList?.removeRange(0, 12);
          //   itemList?.addAll(response.items?.toList() ?? []);
          //   await Future.delayed(const Duration(seconds: 2));
          //   isScrollLoading = false;
          //   _notifySafely();
          // }
        }).whenComplete(() => _hideLoading());
      } else {
        model
            .getItemsByCategoryAndSubCategory(
                categoryId ?? "2", currentSubCat, page)
            .then((response) async {
          itemList = response.items;

          ///itemList?.addAll(response.items?.toList() ?? []);
          await Future.delayed(const Duration(seconds: 1));
          isScrollLoading = false;
          _notifySafely();
          // if (itemList!.length <= 12) {
          //   itemList?.addAll(response.items?.toList() ?? []);
          //   await Future.delayed(const Duration(seconds: 2));
          //   isScrollLoading = false;
          //   _notifySafely();
          // } else {
          //   itemList?.removeRange(0, 12);
          //   itemList?.addAll(response.items?.toList() ?? []);
          //   await Future.delayed(const Duration(seconds: 2));
          //   isScrollLoading = false;
          //   _notifySafely();
          // }
        }).whenComplete(() => _hideLoading());
      }
    }
  }

  void onTapPrevious() {
    if (!isScrollLoading) {
      isScrollLoading = true;
      var pageNo = int.tryParse(page) ?? 1;
      pageNo--;
      page = pageNo.toString();
      _notifySafely();
      if (currentSubCat == "-1") {
        model
            .getItemsAndSubCategoriesByCategory(categoryId ?? "2", page)
            .then((response) async {
          itemList = response.items;

          ///itemList?.addAll(response.items?.toList() ?? []);
          await Future.delayed(const Duration(seconds: 1));
          isScrollLoading = false;
          _notifySafely();
          // if (itemList!.length <= 12) {
          //   itemList = response.items;
          //
          //   ///itemList?.addAll(response.items?.toList() ?? []);
          //   await Future.delayed(const Duration(seconds: 2));
          //   isScrollLoading = false;
          //   _notifySafely();
          // } else {
          //   itemList?.removeRange(0, 12);
          //   itemList?.addAll(response.items?.toList() ?? []);
          //   await Future.delayed(const Duration(seconds: 2));
          //   isScrollLoading = false;
          //   _notifySafely();
          // }
        }).whenComplete(() => _hideLoading());
      } else {
        model
            .getItemsByCategoryAndSubCategory(
                categoryId ?? "2", currentSubCat, page)
            .then((response) async {
          itemList = response.items;

          ///itemList?.addAll(response.items?.toList() ?? []);
          await Future.delayed(const Duration(seconds: 1));
          isScrollLoading = false;
          _notifySafely();
          // if (itemList!.length <= 12) {
          //   itemList?.addAll(response.items?.toList() ?? []);
          //   await Future.delayed(const Duration(seconds: 2));
          //   isScrollLoading = false;
          //   _notifySafely();
          // } else {
          //   itemList?.removeRange(0, 12);
          //   itemList?.addAll(response.items?.toList() ?? []);
          //   await Future.delayed(const Duration(seconds: 2));
          //   isScrollLoading = false;
          //   _notifySafely();
          // }
        }).whenComplete(() => _hideLoading());
      }
    }
  }

  void onListReachedEnd() {
    // if (!isScrollLoading) {
    //   isScrollLoading = true;
    //   var pageNo = int.tryParse(page) ?? 1;
    //   pageNo++;
    //   page = pageNo.toString();
    //   _notifySafely();
    //   if (currentSubCat == "-1") {
    //     model
    //         .getItemsAndSubCategoriesByCategory(categoryId ?? "2", page)
    //         .then((response) async {
    //       if (itemList!.length <= 12) {
    //         itemList?.addAll(response.items?.toList() ?? []);
    //         await Future.delayed(const Duration(seconds: 2));
    //         isScrollLoading = false;
    //         _notifySafely();
    //       } else {
    //         itemList?.removeRange(0, 12);
    //         itemList?.addAll(response.items?.toList() ?? []);
    //         await Future.delayed(const Duration(seconds: 2));
    //         isScrollLoading = false;
    //         _notifySafely();
    //       }
    //     }).whenComplete(() => _hideLoading());
    //   } else {
    //     model
    //         .getItemsByCategoryAndSubCategory(
    //             categoryId ?? "2", currentSubCat, page)
    //         .then((response) async {
    //       if (itemList!.length <= 12) {
    //         itemList?.addAll(response.items?.toList() ?? []);
    //         await Future.delayed(const Duration(seconds: 2));
    //         isScrollLoading = false;
    //         _notifySafely();
    //       } else {
    //         itemList?.removeRange(0, 12);
    //         itemList?.addAll(response.items?.toList() ?? []);
    //         await Future.delayed(const Duration(seconds: 2));
    //         isScrollLoading = false;
    //         _notifySafely();
    //       }
    //     }).whenComplete(() => _hideLoading());
    //   }
    // }
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
