import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../provider/search_provider.dart';
import '../home_page.dart';

class MyRadioTile extends StatelessWidget {
  String title,query;
  MyRadioTile({super.key,required this.title,required this.query});

  @override
  Widget build(BuildContext context) {
    SearchProvider searchProviderFalse = Provider.of<SearchProvider>(context, listen: false);
    SearchProvider searchProviderTrue = Provider.of<SearchProvider>(context, listen: true);
    return RadioListTile<String>(
      title: Text(title),
      value: title,
      groupValue: searchProviderTrue.selectedSearchEngine,
      onChanged: (value) {
        searchProviderFalse.changeSearchEngine(value!);
        searchProviderFalse.getSearchEngineUrl(query);
        refreshWeb(searchProviderTrue.setSearchEngine);
        Navigator.pop(context);
      },
    );
  }
}

Future<void>? refreshWeb(String url) {
  return webViewController?.loadUrl(
    urlRequest: URLRequest(
      url: WebUri(url),
    ),
  );
}
