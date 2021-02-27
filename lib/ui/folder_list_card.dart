import 'package:the_big_thing/utils/material_icons.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class FolderListCard extends StatelessWidget {
  final Color color;
  final String name;
  final String desc;
  final String icon;
  final int count;
  FolderListCard(
      {Key key,
      this.color = Vx.black,
      this.name = '',
      this.desc = '',
      this.icon = '',
      this.count = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
    return Card(
      color: color,
      child: VStack([
        HStack(
          [
            isDark
                ? name.text.white.xl.bold.make()
                : name.text.gray700.xl.bold.make()
          ],
          alignment: MainAxisAlignment.spaceBetween,
        ).wFull(context),
        VStack([
          isDark ? desc.text.gray400.make() : desc.text.gray600.make(),
        ]).py4(),
        HStack(
          [
            Icon(MaterialIcons.mIcons[icon],
                color: isDark ? Vx.gray400 : Vx.gray600),
            [
              isDark
                  ? count.text.gray400.xl3.bold.heightTight.make().px2()
                  : count.text.gray600.xl3.bold.heightTight.make().px2(),
              isDark
                  ? '条大事记'.text.gray400.base.make()
                  : '条大事记'.text.gray600.base.make(),
            ].hStack(crossAlignment: CrossAxisAlignment.end)
          ],
          alignment: MainAxisAlignment.spaceBetween,
        ).wFull(context).pLTRB(0, 18, 0, 0),
      ]).p16(),
    );
  }
}
