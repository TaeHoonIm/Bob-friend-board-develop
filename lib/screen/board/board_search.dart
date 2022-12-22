import 'package:bobfriend/config/global_val.dart';
import 'package:bobfriend/screen/board/board_write.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bobfriend/Model/board.dart';
import 'package:bobfriend/screen/board/board_view.dart';

class BoardSearch extends SearchDelegate {
  List<BoardModel>? boardList;

  BoardSearch(List<BoardModel> this.boardList)
      : super(
          searchFieldLabel: "글 내용을 입력해주세요.",
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
          onPressed: () {
            query = "";
            searchList.clear();
          },
          icon: const Icon(
            Icons.close,
          ))
    ];
  }

  List<BoardModel> searchList = [];

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(Icons.arrow_back));
  }

  List<BoardModel> resultList = [];

  @override
  Widget buildResults(BuildContext context) {
    if (query.isNotEmpty) {
      resultList.clear();
      searchList.addAll(
          boardList!.where((element) => element.content!.contains(query)));
      resultList = searchList;
    }

    if (searchList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Icon(Icons.help_outline, size: 80),
            Text(
              "검색 결과가 없어요!",
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.center,
            )
          ],
        ),
      );
    } else {
      return ListView.builder(
          itemCount: resultList.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 0,
              child: ListTile(
                  title: Text(resultList[index].author!),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text(
                            formatTimestamp(
                              (resultList[index].date!.toDate()),
                            ),
                            style: const TextStyle(color: Colors.grey),
                          )),
                      Expanded(
                          child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                child: const Icon(Icons.thumb_up_alt_outlined,
                                    size: 15),
                              ),
                              Text(
                                  resultList[index].likeCnt!.length.toString()),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                child: const Icon(Icons.comment, size: 15),
                              ),
                              Text(resultList[index].commentCnt!.toString())
                            ],
                          )
                        ],
                      ))
                    ],
                  ),
                  subtitle: Text(
                    resultList[index].content!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                BoardView(resultList[index].reference)));
                  }),
            );
          });
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
    //검색어 추천
  }
}
