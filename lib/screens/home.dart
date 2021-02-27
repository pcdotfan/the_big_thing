import 'package:the_big_thing/entities/folder.dart';
import 'package:the_big_thing/entities/thing.dart';
import 'package:the_big_thing/ui/folder_list_card.dart';
import 'package:the_big_thing/ui/thing_list_card.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:get/route_manager.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:home_widget/home_widget.dart';
import "package:velocity_x/velocity_x.dart";
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  SearchBar searchBar;
  String keyword = '';

  AppBar buildAppBar(BuildContext context) {
    return new AppBar(
      title: Text('大事发生'),
      actions: [
        searchBar.getSearchAction(context),
        keyword.length > 0
            ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    keyword = '';
                  });
                })
            : SizedBox()
      ],
      bottom: TabBar(
        tabs: [
          Tab(icon: Icon(Icons.home)),
          Tab(icon: Icon(Icons.folder_open_outlined)),
        ],
      ),
    );
  }

  void updateHomeWidget() {
    final thingsBox = Hive.box<Thing>('things');
    if (thingsBox.isNotEmpty) {
      final latestThing = thingsBox.values.last;

      final inDays = latestThing.dueDate.difference(DateTime.now()).inDays;
      HomeWidget.saveWidgetData<String>(
          'title',
          "${latestThing.name} ${inDays > 0 ? "还有 $inDays 天" : inDays < 0 ? "$inDays 天前" : "就是今天"}");
      HomeWidget.saveWidgetData<String>('message', latestThing.content);
      HomeWidget.updateWidget(name: 'NewAppWidget');
    }
  }

  @override
  void initState() {
    super.initState();
    searchBar = new SearchBar(
        inBar: false,
        hintText: '搜索大事记',
        setState: setState,
        onChanged: (val) {
          setState(() {
            keyword = val;
          });
        },
        buildDefaultAppBar: buildAppBar);
    updateHomeWidget();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: searchBar.build(context),
          floatingActionButton: FloatingActionButton(
                  tooltip: '新增',
                  onPressed: () =>
                      Get.toNamed('/folders/create-edit').then((value) {
                        setState(() {});
                      }),
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.add))
              .py8(),
          body: TabBarView(
            children: [
              VStack([
                keyword.length > 0
                    ? Builder(builder: (context) {
                        return ValueListenableBuilder(
                            valueListenable:
                                Hive.box<Thing>('things').listenable(),
                            builder: (context, Box<Thing> box, _) {
                              if (box.values.isEmpty) return SizedBox();
                              final searchThings = box.values.where(
                                  (thing) => thing.name.contains(keyword));
                              return VStack([
                                '搜索结果'.text.xl.semiBold.make().py8().px16(),
                                VStack(searchThings
                                    .map((thing) => GestureDetector(
                                          onTap: () => Get.toNamed('/things/' +
                                              thing.key.toString()),
                                          child: ThingListCard(
                                            name: thing.name,
                                            content: thing.content,
                                            color: Color(thing.color),
                                            dueDate:
                                                thing.dueDate.toIso8601String(),
                                          ),
                                        ).px8())
                                    .toList())
                              ]).py12();
                            });
                      })
                    : SizedBox(),
                Builder(builder: (context) {
                  return ValueListenableBuilder(
                      valueListenable: Hive.box<Folder>('folders').listenable(),
                      builder: (context, Box<Folder> box, _) {
                        if (box.values.isEmpty) return SizedBox();
                        final stickyFolders =
                            box.values.where((folder) => folder.sticky);
                        if (stickyFolders.length == 0) return SizedBox();
                        return VStack([
                          '置顶记事录'.text.xl.semiBold.make().py8().px16(),
                          HStack(stickyFolders
                                  .map((folder) => GestureDetector(
                                        onTap: () => Get.toNamed('/folders/' +
                                            folder.key.toString()),
                                        child: FolderListCard(
                                          name: folder.name,
                                          desc: '',
                                          color: Color(folder.color),
                                          icon: folder.icon,
                                          count: folder.count,
                                        ).w56(context).px8(),
                                      ))
                                  .toList())
                              .scrollHorizontal()
                        ]).py12();
                      });
                }),
                VStack([
                  '就是今天'.text.xl.semiBold.make().py8().px16(),
                  ValueListenableBuilder(
                      valueListenable: Hive.box<Thing>('things').listenable(),
                      builder: (context, Box<Thing> box, _) {
                        if (box.values.isEmpty)
                          return Center(child: '空'.text.gray700.xl6.make())
                              .p24();
                        final things = box.values.where((thing) =>
                            thing.dueDate.difference(DateTime.now()).inDays ==
                            0);
                        return VStack(things
                            .map((thing) => GestureDetector(
                                  onTap: () => Get.toNamed(
                                      '/things/' + thing.key.toString()),
                                  child: ThingListCard(
                                    name: thing.name,
                                    content: thing.content,
                                    color: Color(thing.color),
                                    dueDate: thing.dueDate.toIso8601String(),
                                  ),
                                ).px8())
                            .toList());
                      })
                ]).py12(),
                VStack([
                  '即将到来'.text.xl.semiBold.make().py8().px16(),
                  ValueListenableBuilder(
                      valueListenable: Hive.box<Thing>('things').listenable(),
                      builder: (context, Box<Thing> box, _) {
                        if (box.values.isEmpty)
                          return Center(child: '空'.text.gray700.xl6.make())
                              .p24();
                        final things = box.values.where((thing) =>
                            thing.dueDate.compareTo(DateTime.now()).days >
                                Duration.zero &&
                            thing.sticky);
                        return VStack(things
                            .map((thing) => GestureDetector(
                                  onTap: () => Get.toNamed(
                                      '/things/' + thing.key.toString()),
                                  child: ThingListCard(
                                    name: thing.name,
                                    content: thing.content,
                                    color: Color(thing.color),
                                    dueDate: thing.dueDate.toIso8601String(),
                                  ),
                                ).px8())
                            .toList());
                      })
                ]).py12(),
                VStack([
                  '已成历史'.text.xl.semiBold.make().py8().px16(),
                  ValueListenableBuilder(
                      valueListenable: Hive.box<Thing>('things').listenable(),
                      builder: (context, Box<Thing> box, _) {
                        if (box.values.isEmpty)
                          return Center(child: '空'.text.gray700.xl6.make())
                              .p24();
                        final things = box.values.where((thing) =>
                            thing.dueDate.difference(DateTime.now()).inDays <
                            0);
                        return VStack(things
                            .map((thing) => GestureDetector(
                                  onTap: () => Get.toNamed(
                                      '/things/' + thing.key.toString()),
                                  child: ThingListCard(
                                    name: thing.name,
                                    content: thing.content,
                                    color: Color(thing.color),
                                    dueDate: thing.dueDate.toIso8601String(),
                                  ),
                                ))
                            .toList());
                      })
                ]).py12()
              ]).scrollVertical(),
              ValueListenableBuilder(
                  valueListenable: Hive.box<Folder>('folders').listenable(),
                  builder: (context, Box<Folder> box, _) {
                    if (box.values.isEmpty)
                      return Center(child: '空'.text.gray700.xl6.make()).p24();
                    return VStack([
                      VStack(box.values
                          .map((folder) => GestureDetector(
                                onTap: () => Get.toNamed(
                                    '/folders/' + folder.key.toString()),
                                child: FolderListCard(
                                  name: folder.name,
                                  desc: folder.desc,
                                  color: Color(folder.color),
                                  icon: folder.icon,
                                  count: folder.count,
                                ).px8(),
                              ))
                          .toList())
                    ]).py12().scrollVertical();
                  })
            ],
          ),
        ));
  }
}
