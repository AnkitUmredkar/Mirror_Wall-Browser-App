import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gap/gap.dart';
import 'package:government_service_app/provider/search_provider.dart';
import 'package:government_service_app/view/components/my_radio_tile.dart';
import 'package:provider/provider.dart';

InAppWebViewController? webViewController;
TextEditingController txtSearch = TextEditingController();

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    SearchProvider searchProviderFalse =
        Provider.of<SearchProvider>(context, listen: false);
    SearchProvider searchProviderTrue =
        Provider.of<SearchProvider>(context, listen: true);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 100,
          backgroundColor: Colors.blue.shade800,
          leading: IconButton(
            onPressed: () {
              refreshWeb(searchProviderTrue);
            },
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          title: const Text(
            'My Browser',
            style: TextStyle(color: Colors.white),
          ),
          //todo -------------------> Popup menu
          actions: [
            PopupMenuButton(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              itemBuilder: (context) {
                return [
                  buildPopupMenuItem(width, "History", 0),
                  buildPopupMenuItem(width, "Search Engine", 1)
                ];
              },
              onSelected: (item) async {
                if (item == 1) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String query = txtSearch.text;
                      return AlertDialog(
                        title: const Text("Search Engine"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyRadioTile(title: "Google", query: query),
                            MyRadioTile(title: "Yahoo", query: query),
                            MyRadioTile(title: "bing", query: query),
                            MyRadioTile(title: "Duck Duck Go", query: query),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(top: height * 0.07),
                        child: Dialog.fullscreen(
                          backgroundColor: Colors.white,
                          child: Column(
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("X  DISMISS")),
                              Consumer<SearchProvider>(
                                builder: (BuildContext context, value, Widget? child) =>
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: searchProviderTrue.userHistory.length,
                                        itemBuilder: (context, index) {
                                          final data = searchProviderTrue.userHistory[index];
                                          final url = data.split('---').sublist(0, 1).join(' ');
                                          final search = data.split('---').sublist(1, 2).join(' ');
                                          return ListTile(
                                            onTap: () {
                                              txtSearch.text = search;
                                              webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
                                              Navigator.pop(context);
                                            },
                                            title: Text(search),
                                            subtitle: Text(url),
                                            trailing: IconButton(
                                                onPressed: () {
                                                  searchProviderFalse
                                                      .deleteFromHistory(index);
                                                },
                                                icon: const Icon(Icons.delete)),
                                          );
                                        },
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
          //todo -------------------> Search Bar
          bottom: PreferredSize(
            preferredSize: Size(width, 40),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Container(
                alignment: Alignment.center,
                child: TextField(
                  controller: txtSearch,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      searchProviderFalse.getSearchEngineUrl(value);
                      refreshWeb(searchProviderTrue);
                    }
                  },
                  decoration: buildInputDecoration(),
                ),
              ),
            ),
          ),
        ),
        //todo ----------------------> web
        body: Column(
          children: [
            (searchProviderTrue.isLoading)
                ? const LinearProgressIndicator(color: Colors.blue)
                : const Gap(0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(searchProviderTrue.setSearchEngine)),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                  },
                  onLoadStart: (controller, url) {
                    searchProviderFalse.updateLoadingStatus(true);
                  },
                  onLoadStop: (controller, url) {
                    searchProviderFalse.updateLoadingStatus(false);
                    String query = txtSearch.text != ""
                        ? txtSearch.text
                        : searchProviderTrue.selectedSearchEngine;
                    searchProviderFalse.addToHistory(url.toString(), query);
                  },
                ),
              ),
            ),
          ],
        ),
        //todo ----------------------> bottom Navigation Bar
        bottomNavigationBar: Container(
          color: Colors.grey.shade200,
          height: height * 0.079,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  onPressed: () {
                    searchProviderFalse.getSearchEngineUrl("");
                    txtSearch.clear();
                    refreshWeb(searchProviderTrue);
                  },
                  icon: const Icon(Icons.home)),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_add_outlined)),
              IconButton(
                  onPressed: () async {
                    if (await webViewController?.canGoBack() ?? false) {
                      webViewController?.goBack();
                    }
                  },
                  icon: const Icon(Icons.arrow_back_ios)),
              IconButton(
                  onPressed: () async {
                    if (await webViewController?.canGoForward() ?? false) {
                      webViewController?.goForward(); // Go forward in web view
                    }
                  },
                  icon: const Icon(Icons.arrow_forward_ios)),
            ],
          ),
        ));
  }
}

PopupMenuItem<int> buildPopupMenuItem(double width, String title, int value) {
  return PopupMenuItem<int>(
    value: value,
    child: Text(title, style: TextStyle(fontSize: width * 0.042)),
  );
}

InputDecoration buildInputDecoration() {
  return InputDecoration(
    filled: true,
    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
    fillColor: Colors.white,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    hintText: "Search here..",
    hintStyle: const TextStyle(color: Colors.grey),
  );
}
