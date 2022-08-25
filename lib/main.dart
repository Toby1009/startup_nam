
import 'dart:ui';

import 'package:english_words/english_words.dart'; // 一個外部的包，包含很多英文字和一些實用的方法，可以到pub.dev裡面查看
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

//MyApp為主畫面，繼承無狀態Widget，即為不可改變Widget狀態
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  //build 用來建立Widget子樹的
  //context用來記錄Widget在Widget樹上的上下文，每個Widget都會對應一個context對象，就像藍圖一樣，提供了Widget的前後關係
  @override
  Widget build(BuildContext context) {
    //MaterialApp is by material library that can implements widgets that follow Material Design principles
    //總之可以使用很多東東
    return  MaterialApp(
      //去掉預設的debug標誌
      debugShowCheckedModeBanner: false,
      title: 'Startup Name Generator',
      //客製化主題風格
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor:  Colors.white,
          foregroundColor:  Colors.black,
        ),
      ),
      //來自Material library，讓Widget樹可以在主畫面
      home: const RandomWords(),
    );
  }
}

//在IDE輸入stful即可快速新增一個有狀態的Widget
//繼承一個有狀態的Widget，即為可改變Widget狀態
//決定是否在下次build時複用Widget，決定條件在canUpdate()方法中
class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  //新增一個繼承State的Class，可以用來build，也就是可以用來更新UI

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

//一個StatefulWidget會對應一個State類，State類表示與其對應的StatefulWidget要維護的狀態
//可以用setState()改變狀態，改變狀態即為更新UI
class _RandomWordsState extends State<RandomWords> {
  //一個WordPair陣列，WordPair來自 english_words包
  final _suggestions = <WordPair>[];
  //set不可重複，很適合用來記錄是否按過list
  final _saved = <WordPair>{};
  //設定文字大小
  final _biggerFont = const TextStyle(fontSize: 18);
  void _pushSaved(){
    //Navigator為導航，是一個堆疊，負責管理App的Route(路由/路徑)
    //Push一個Route到Navigator堆疊上面，就能讓畫面顯示到該Route上
    //Pop一個Route從Navigator堆疊，就會回到上一個畫面
    //所以可以利用Navigator來跳轉到下一個畫面
    Navigator.of(context).push(
      //用MaterialPageRoute來設定並return Route
      MaterialPageRoute<void>(
        //建構Route的主要內容
        builder: (context){
          //map為迭代的方法，會遍訪所有_saved的值，也就是所有按過愛心的值
          final tiles = _saved.map(
            (pair){
              //返回ListTile，顯示按過愛心的文字串，每個字首為大寫，並設定字的大小
              return ListTile(
                title:  Text(
                  //以簡單字串返回單詞，每個字首大寫
                  pair.asPascalCase,
                  //設定字的大小
                  style:  _biggerFont,
                ),
              );
            },
          );
          //如果ListTile有字的話，新增分割線，並顯示按過愛心的文字串，反之則反
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(
                context: context,
                tiles: tiles,
                ).toList()
              : <Widget>[];
          //builder的reutrn，返回Scaffold，設定appBar和內容，內容為按過的愛心的清單
          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggetstions'),
            ),
            body:  ListView(children: divided),
          );
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar為畫面最上面那排
        appBar: AppBar(
          //設定主畫面的標題，Ios預設為顯示在中間，Android預設為靠左邊
          //可以利用centerTitle來限制為中間
          centerTitle: true,
          title: const Text('Startup Name Generator'),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _pushSaved,
              tooltip: 'Saved Suggestions',
            ),
          ],
        ),
        body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            //i每次被調用的時候都會新增,0,1,2,........
            itemBuilder: (context, i) {
              if (i.isOdd) return const Divider();
              //文字的部分為i除2，也等於list的位置，也就是減去了分隔符的位置
              final index = i ~/ 2;
              //if index 小於 list的長度，就新增隨機英文
              if (index >= _suggestions.length) {
                _suggestions.addAll(generateWordPairs().take(10));
              }
              //如果該文字有被按愛心，則為true
              final alreadySaved = _saved.contains(_suggestions[index]);
              return ListTile(
                title: Text(
                  _suggestions[index].asPascalCase,
                  style: _biggerFont,
                ),
                trailing: Icon(
                  //已經被按愛心的為實心，否則為空心
                  alreadySaved ? Icons.favorite : Icons.favorite_border,
                  //已經被按心則為紅色，否則沒顏色
                  color: alreadySaved ? Colors.red : null,
                  //語意標籤，不會顯示在UI中
                  semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
                ),
                //點擊List時呼叫onTap
                onTap: (() {
                  //setState觸發器觸發State呼叫build()方法來更新UI
                  setState(() {
                    //如果按過了則取消，反之則反
                    if (alreadySaved) {
                      _saved.remove(_suggestions[index]);
                    } else {
                      _saved.add(_suggestions[index]);
                    }
                  });
                }),
              );
            }));
  }
}
