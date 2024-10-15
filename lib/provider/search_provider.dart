import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchProvider extends ChangeNotifier{
  String search = "", selectedSearchEngine = "Google",setSearchEngine = "https://www.google.com/search?q";
  bool isLoading = true;
  List<String> userHistory = [];

  void changeCategory(String search){
    this.search = search;
    notifyListeners();
  }

  void updateLoadingStatus(bool status){
    isLoading = status;
    notifyListeners();
  }

  void changeSearchEngine(String selectedSearchEngine){
    this.selectedSearchEngine = selectedSearchEngine;
    notifyListeners();
  }

  void getSearchEngineUrl(String query) {
    switch (selectedSearchEngine) {
      case "Yahoo":
        setSearchEngine = "https://search.yahoo.com/search?p=$query";
        break;
      case "bing":
        setSearchEngine = "https://www.bing.com/search?q=$query";
        break;
      case "Duck Duck Go":
        setSearchEngine = "https://duckduckgo.com/?q=$query";
        break;
      default:
        setSearchEngine = "https://www.google.com/search?q=$query";
        break;
    }
    notifyListeners();
  }

  Future<void> addToHistory(String url, String query) async {
    try{
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      bool check = false;
      for(int i=0; i<userHistory.length; i++){
        if(url == userHistory[i].split('---').sublist(0, 1).join(" ")){
          check = true;
          break;
        }
      }
      if(!check){
        userHistory.add("$url---$query");
        notifyListeners();
        sharedPreferences.setStringList("history", userHistory);
      }
    }catch(e){
      print("Error into store history -> $e");
    }
  }

  Future<void> deleteFromHistory(int index) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userHistory.removeAt(index);
    notifyListeners();
    sharedPreferences.setStringList("history", userHistory);
  }

  Future<void> getHistory() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userHistory = sharedPreferences.getStringList("history") ?? [];
    print(userHistory);
    notifyListeners();
  }

  SearchProvider(){
    getHistory();
  }
}