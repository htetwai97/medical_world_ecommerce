// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:medical_family_app/bloc/product_line_page_bloc.dart';
import 'package:medical_family_app/constants/colors/colors.dart';
import 'package:medical_family_app/constants/scale/font_sizes.dart';
import 'package:medical_family_app/constants/scale/scale_dimension.dart';
import 'package:medical_family_app/constants/texts/texts.dart';
import 'package:medical_family_app/data/vo_models/brand_item_vo.dart';
import 'package:medical_family_app/data/vo_models/item_vo.dart';
import 'package:medical_family_app/network/api_constants.dart';
import 'package:medical_family_app/pages/home_page.dart';
import 'package:medical_family_app/pages/item_detail_new_version_page.dart';
import 'package:provider/provider.dart';

class ProductLineNewVersionPageRoot extends StatelessWidget {
  bool comeFromHomePage;
  String? searchItem;
  ProductLineNewVersionPageRoot({
    Key? key,
    this.comeFromHomePage = false,
    this.searchItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProductLinePageBloc(searchItem),
      child: Scaffold(
        body: Selector<ProductLinePageBloc, bool>(
          selector: (context, bloc) => bloc.isScrollLoading,
          builder: (context, isScrollLoading, child) =>
              ProductLineNewVersionPage(
            comeFromHomePage: comeFromHomePage,
            searchItem: searchItem ?? "",
            onListReachEnd: () {
              var bloc =
                  Provider.of<ProductLinePageBloc>(context, listen: false);
              bloc.onListReachedEnd();
            },
          ),
        ),
      ),
    );
  }
}

class ProductLineNewVersionPage extends StatefulWidget {
  bool comeFromHomePage;
  String searchItem;
  Function onListReachEnd;
  ProductLineNewVersionPage({
    Key? key,
    required this.comeFromHomePage,
    required this.searchItem,
    required this.onListReachEnd,
  }) : super(key: key);

  @override
  State<ProductLineNewVersionPage> createState() =>
      _ProductLineNewVersionPageState();
}

class _ProductLineNewVersionPageState extends State<ProductLineNewVersionPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
          print("Start of the List reached");
        } else {
          print("End of the List reached");
          widget.onListReachEnd();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Selector<ProductLinePageBloc, List<BrandItemVO?>?>(
      selector: (context, bloc) => bloc.brandList,
      builder: (context, brandList, child) =>
          Selector<ProductLinePageBloc, bool>(
        selector: (context, bloc) => bloc.isLoading,
        builder: (context, isLoading, child) => DefaultTabController(
          length: brandList?.length ?? 0,
          initialIndex: 0,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: APP_THEME_COLOR,
              elevation: 5,
              leading: Visibility(
                visible: widget.comeFromHomePage,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: FONT_XLARGE,
                    color: Colors.white,
                  ),
                ),
              ),
              title: const Text(
                "Product Line",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: FONT_LARGE - 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: scaleWidth(context) / 30,
                ),
                child: Column(
                  children: [
                    SizedBox(height: scaleWidth(context) / 30),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: scaleWidth(context) / 40),
                      child: TitleAndSeeMoreView(
                        title: "Brands",
                      ),
                    ),
                    SizedBox(height: scaleWidth(context) / 60),
                    Consumer<ProductLinePageBloc>(
                      builder: (context, bloc, child) => TabListForBrandList(
                        tabs: bloc.tabs,
                        categoryIds: bloc.brands ?? [],
                        onTab: (categoryId) {
                          if (!isLoading) {
                            bloc.onTapCategory(categoryId.toString());
                          }
                        },
                      ),
                    ),
                    SizedBox(height: scaleWidth(context) / 16),
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 1),
                            spreadRadius: 10,
                            blurRadius: 10,
                            blurStyle: BlurStyle.outer,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: scaleWidth(context) / 40),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: scaleWidth(context) / 40,
                            ),
                            child: TitleAndSeeMoreView(
                              title: "Products",
                              //textDecoration: TextDecoration.underline,
                            ),
                          ),
                          SizedBox(height: scaleWidth(context) / 20),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: scaleWidth(context) / 40,
                            ),
                            child: Consumer<ProductLinePageBloc>(
                              builder: (context, bloc, child) =>
                                  ItemPropertyListView(
                                onListReachEnd: () {},
                                properties: bloc.products ?? [],
                                onTapProperty: (product) {},
                                onTap: (index) {
                                  if (!isLoading) {
                                    bloc.onTapSubCategory(
                                        "${bloc.productIdList?[index] ?? 0}",
                                        index);
                                  }
                                },
                                isSelectedSomething: true,
                                selectedIndex: bloc.selectedProductIndex,
                              ),
                            ),
                          ),
                          SizedBox(height: scaleWidth(context) / 16),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: scaleWidth(context) / 40,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "Items",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: FONT_LARGE - 5,
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  height: scaleWidth(context) / 10,
                                  width: scaleWidth(context) / 2.3,
                                  child: Consumer<ProductLinePageBloc>(
                                    builder: (context, bloc, child) =>
                                        SearchTextFieldView(
                                      hintText: bloc.hintText ?? SEARCH_TEXT,
                                      readOnly: false,
                                      onSearchDone: (text) {
                                        bloc.onSearchItem(text);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: scaleWidth(context) / 20),
                          Selector<ProductLinePageBloc, bool>(
                            selector: (context, bloc) => bloc.isScrollLoading,
                            builder: (context, isScrolling, child) =>
                                Selector<ProductLinePageBloc, bool>(
                              selector: (context, bloc) => bloc.isLoading,
                              builder: (context, isLoading, child) =>
                                  Selector<ProductLinePageBloc, String>(
                                selector: (context, bloc) => bloc.page,
                                builder: (context, page, child) => Selector<
                                    ProductLinePageBloc, List<ItemVO?>?>(
                                  selector: (context, bloc) => bloc.itemList,
                                  builder: (context, itemList, child) => Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Visibility(
                                        visible: !isLoading && !isScrolling,
                                        child: Column(
                                          children: [
                                            PaginationSectionView(
                                              page: page,
                                              visiblePrevious: (page != "1"),
                                              onTapNext: () {
                                                if (!isLoading &&
                                                    !isScrolling) {
                                                  var bloc = Provider.of<
                                                          ProductLinePageBloc>(
                                                      context,
                                                      listen: false);
                                                  bloc.onTapNext();
                                                }
                                              },
                                              onTapPrevious: () {
                                                if (!isLoading &&
                                                    !isScrolling) {
                                                  var bloc = Provider.of<
                                                          ProductLinePageBloc>(
                                                      context,
                                                      listen: false);
                                                  bloc.onTapPrevious();
                                                }
                                              },
                                            ),
                                            ItemListGridView(
                                              itemList: itemList,
                                            ),
                                            PaginationSectionView(
                                              page: page,
                                              visiblePrevious: (page != "1"),
                                              onTapNext: () {
                                                if (!isLoading &&
                                                    !isScrolling) {
                                                  var bloc = Provider.of<
                                                          ProductLinePageBloc>(
                                                      context,
                                                      listen: false);
                                                  bloc.onTapNext();
                                                }
                                              },
                                              onTapPrevious: () {
                                                if (!isLoading &&
                                                    !isScrolling) {
                                                  var bloc = Provider.of<
                                                          ProductLinePageBloc>(
                                                      context,
                                                      listen: false);
                                                  bloc.onTapPrevious();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: isLoading || isScrolling,
                                        child: Center(
                                          child: SpinKitDoubleBounce(
                                            size: 250,
                                            itemBuilder: (context, index) =>
                                                const Column(
                                              children: [
                                                CircleAvatar(
                                                  backgroundImage: AssetImage(
                                                    "assets/images/search_elephant.png",
                                                  ),
                                                  radius: 34,
                                                ),
                                                Text("Searching"),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PaginationSectionView extends StatelessWidget {
  final bool visiblePrevious;
  final Function onTapNext;
  final String page;
  final Function onTapPrevious;
  const PaginationSectionView({
    super.key,
    required this.onTapNext,
    required this.page,
    required this.onTapPrevious,
    this.visiblePrevious = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (visiblePrevious)
          IconButton(
            onPressed: () {
              onTapPrevious();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 28,
            ),
          )
        else
          const SizedBox(
            width: 70,
            height: 1,
          ),
        if (visiblePrevious) const Text("Previous") else const Text(""),
        const Spacer(),
        Text("Page $page"),
        const Spacer(),
        const Text("Next"),
        IconButton(
          onPressed: () {
            onTapNext();
          },
          icon: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
            size: 28,
          ),
        ),
      ],
    );
  }
}

class ItemListGridView extends StatefulWidget {
  final List<ItemVO?>? itemList;
  const ItemListGridView({
    super.key,
    required this.itemList,
  });

  @override
  State<ItemListGridView> createState() => _ItemListGridViewState();
}

class _ItemListGridViewState extends State<ItemListGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      addAutomaticKeepAlives: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.itemList?.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisExtent: scaleWidth(context) / 1.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) {
        return Selector<ProductLinePageBloc, bool>(
          selector: (context, bloc) => bloc.isLoading,
          builder: (context, isLoading, child) =>
              Selector<ProductLinePageBloc, bool>(
            selector: (context, bloc) => bloc.isScrollLoading,
            builder: (context, isScrollLoading, child) => ItemDetailView(
              height: scaleWidth(context) / 2.5,
              width: scaleWidth(context) / 2.5,
              itemName: widget.itemList?[index]?.itemName ?? "error",
              itemImage:
                  "$ITEM_IMAGE_BASE_URL${widget.itemList?[index]?.photoPath ?? ""}",
              onTap: () {
                if (!isLoading && !isScrollLoading) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailNewVersionRoot(
                        itemId: widget.itemList?[index]?.id?.toString() ?? "",
                        catId:
                            widget.itemList?[index]?.categoryId?.toString() ??
                                "",
                        subCatId: widget.itemList?[index]?.subCategoryId
                                ?.toString() ??
                            "",
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class CommonAppButton extends StatelessWidget {
  String text;
  Function onTap;
  Color buttonColor;
  Color textColor;
  double textFont;
  CommonAppButton({
    super.key,
    required this.text,
    required this.onTap,
    this.buttonColor = APP_THEME_COLOR,
    this.textColor = Colors.white,
    this.textFont = FONT_LARGE - 6,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(buttonColor),
      ),
      onPressed: () {
        onTap();
      },
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: textFont,
        ),
      ),
    );
  }
}

class TabListForBrandList extends StatelessWidget {
  TabListForBrandList({
    super.key,
    required this.tabs,
    required this.onTab,
    required this.categoryIds,
  });

  List<Widget>? tabs;
  Function(int categoryId) onTab;
  List<int> categoryIds;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      onTap: (tabIndex) {
        onTab(categoryIds[tabIndex]);
      },
      isScrollable: true,
      indicatorWeight: 3,
      labelStyle: const TextStyle(
        fontSize: FONT_LARGE - 6,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: FONT_LARGE - 8,
      ),
      labelColor: APP_THEME_COLOR,
      unselectedLabelColor: Colors.black54,
      indicatorColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.label,
      tabs: tabs ?? [],
    );
  }
}

// class SearchButtonView extends StatelessWidget {
//   const SearchButtonView({
//     super.key,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.black12,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: const Row(
//         children:  [
//           Icon(
//             Icons.search,
//             color: Colors.black54,
//             size: FONT_LARGE,
//           ),
//           Text(
//             "Search",
//             style: TextStyle(
//               color: Colors.black54,
//               fontSize: FONT_LARGE - 4,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
