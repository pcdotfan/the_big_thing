import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ThingListCard extends StatelessWidget {
  final String name;
  final String content;
  final Color color;
  final bool sticky;
  final String dueDate;

  ThingListCard(
      {Key key,
      this.name = '',
      this.content = '',
      this.sticky = false,
      this.color = Colors.black,
      this.dueDate = ''})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inDays = DateTime.now().difference(DateTime.parse(dueDate)).inDays;
    return Card(
      color: color,
      child: ZStack([
        sticky
            ? Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  child: '置顶'.text.sm.white.make().p4(),
                ).backgroundColor(Vx.red600))
            : SizedBox(),
        VStack([
          HStack(
            [name.text.white.xl.bold.make()],
            alignment: MainAxisAlignment.spaceBetween,
          ).wFull(context),
          VStack([
            content.text.gray500.make().py4(),
          ]),
          HStack(
            [
              SizedBox(),
              inDays == 0
                  ? [
                      '就是今天'.text.gray400.xl3.bold.heightTight.make().px2(),
                    ].hStack(crossAlignment: CrossAxisAlignment.end)
                  : [
                      inDays
                          .abs()
                          .text
                          .gray400
                          .xl3
                          .bold
                          .heightTight
                          .make()
                          .px2(),
                      "${inDays > 0 ? '天前' : '天后'}".text.gray400.base.make(),
                    ].hStack(crossAlignment: CrossAxisAlignment.end)
            ],
            alignment: MainAxisAlignment.spaceBetween,
          ).wFull(context).pLTRB(0, 18, 0, 0),
        ]).p16()
      ]),
    ).wFull(context);
  }
}
