import 'dart:math';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Config {
  Color backgroundColor; // Widget 当前背景颜色
  Color barColor; //所有条形图 统一一个颜色
  List<Color> barColors; //每个条形图颜色 [barColors 被赋值时候 barColor 失效,]
  Color barBackgroundColor; //条形图背景颜色
  Color textColor; //字体颜色
  Color yAxisTextColor; //Y轴文字颜色
  Color xAxisColor; //X轴颜色
  double barWidth; //条形图宽度
  double barMargin; //条形图间隔宽度
  double paddingTop; //图表上边距
  double xFontSize; //X轴文字的字体大小
  double textBottomDescent; // X轴文字 文字距离X轴下沉下降高度
  double textBottomHeight; // X轴文字高度
  double textBottomMargin; //X轴文字，文字以下下边间距
  int toStringAsFixed;// 显示的数据保留的小数位数
  int yAxisRankNum;// Y轴文字设置多少个等级阶梯
  double yAxisRankWidth;// Y轴文字右边的等级线宽度
  double yAxisRankHeight;// Y轴文字右边的等级线高度
  bool showYAxisRankLine; // 展示Y轴等级分割线
  Color yAxisRankLineColor; // Y轴等级分割线 颜色
  List dataList;// 数据源
  List<String> xAxisTexts;// x轴文字
  double height;// 表格高度
  double yAxisWidth;// Y轴宽度
  String xText;// x轴最右边文字
  String yText;// y轴最顶部文字
  bool showXyAxisArrows; // 展示X轴和Y轴的小箭头
  bool showCircleBarTop; // 设置柱状图顶部圆角
  bool showAnimation; // 展示动态加载动画

  BuildContext context;

  double scale = 1.0;


  Config({
    @required this.dataList,
    @required this.height,
    this.toStringAsFixed = 0,
    this.backgroundColor = Colors.transparent,
    this.barColor = const Color(0xFF5858D6),
    this.barColors,
    this.barBackgroundColor = Colors.transparent,
    this.textColor = const Color(0xFF000000),
    this.yAxisTextColor = const Color(0xFF000000),
    this.xAxisColor = const Color(0xFF000000),
    this.barWidth = 22.0,
    this.barMargin = 20.0,
    this.paddingTop = 20.0,
    this.yAxisWidth = 40.0,
    this.textBottomMargin = 8.0,
    this.xFontSize = 12.0,
    this.textBottomDescent = 15,
    this.textBottomHeight = 20,
    this.yAxisRankNum = 8,
    this.yAxisRankWidth = 4,
    this.yAxisRankHeight = 0.5,
    this.showYAxisRankLine = false,
    this.yAxisRankLineColor =  Colors.blueGrey,
    this.xText = "",
    this.yText = "",
    this.showXyAxisArrows = true,
    this.showCircleBarTop = false,
    this.showAnimation = true,
    @required this.xAxisTexts,
  });
}

class ChartColumnPaint extends StatefulWidget {
  final Config config;

  ChartColumnPaint({
    @required this.config,
  }){
    //
  }


  @override
  _ChartColumnPaintState createState() {
    return _ChartColumnPaintState();
  }

}

class _ChartColumnPaintState extends State<ChartColumnPaint> with TickerProviderStateMixin {
  AnimationController _controller;
  final _animations = <double>[];
  double _scale = 1.0; // 热更新记录 config.scale
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(ChartColumnPaint oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setScale();
    _animation(this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _stack();
  }


  void _animation (TickerProvider vc  ){
    Config config = widget.config;
    _controller = AnimationController(
      vsync: vc,
      duration: Duration(milliseconds: config.showAnimation ? 4000 : 1),
    )..forward();

    for (int i = 0; i < config.dataList.length; i++) {
      final double end = double.parse(config.dataList[i].toString()) / config.scale;
      double begin = 0;
      // 使用一个补间值 Tween 创建每个矩形的动画值
      final Tween<double> tween = Tween(begin: begin, end: end);
      // 初始化数组里面的值
      _animations.add(begin);

      // 创建补间动画
      Animation<double> animation = tween.animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.ease,
        ),
      );
      _controller.addListener(() {
        // 使用 setState 更新 _animations 数组里面的动画值
        setState(() {
          _animations[i] = animation.value;
        });
      });
    }
    setState(() {
      config.dataList.clear();
      config.dataList = _animations;
    });
  }

  // 设置缩放比例
  void _setScale (){

    Config config = widget.config;
    List<double> ls = config.dataList.map((e) {
      return double.parse(e.toString());
    }).toList();
    double  _sh = widget.config.height - config.textBottomHeight- config.textBottomMargin - config.textBottomDescent - config.paddingTop ;
    if (ls.length > 0)  _scale = ls.reduce(max) / _sh;
    config.scale = _scale;
  }

  Stack _stack() {
    return Stack(
      children: [
        Container(
          height: widget.config.height,
        ),
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            height: widget.config.height,
            width: widget.config.yAxisWidth,
            child: Container(
//              color: widget.config.barColor,
              child: CustomPaint(
                size: Size(widget.config.yAxisWidth, widget.config.height),
                painter: ChartColumnYAxisPainter(config: widget.config),
              ),
            ),
          ),
        ),
        Positioned(
            left: widget.config.yAxisWidth,
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  color: widget.config.backgroundColor,
                  child: CustomPaint(
                    size: Size(
                        (widget.config.xAxisTexts.length + 1.5) *
                            (widget.config.barMargin + widget.config.barWidth),
                        widget.config.height),
                    painter: ChartColumnPainter(config: widget.config),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class ChartColumnYAxisPainter extends CustomPainter {
  Paint _linePaint;
  Config config;
  double yAxisRankWidth;
  double scale = 1.0;
  ChartColumnYAxisPainter({@required this.config}) {
    yAxisRankWidth = config.yAxisRankWidth;
    init();
  }

  init() {
    _linePaint = Paint()..color = config.xAxisColor
      ..strokeWidth = 0.5;
  }

  @override
  void paint(Canvas canvas, Size size) {

    if (config.dataList.length != 0) {
      Offset start = ui.Offset(config.yAxisWidth - yAxisRankWidth,
          size.height - config.textBottomHeight - config.textBottomMargin - config.textBottomDescent);
      Offset endX = ui.Offset(230 /*随便给个长度使得两个X轴线重合，*/,
          size.height - config.textBottomHeight - config.textBottomMargin - config.textBottomDescent);
      Offset endY =
      ui.Offset(config.yAxisWidth - yAxisRankWidth, 0);
      canvas.drawLine(start, endX, _linePaint); //画一条X轴

      if (config.showXyAxisArrows) {
        if (!config.showYAxisRankLine) { // 只有在不显示横向分割线时候才显示Y轴箭头
          canvas.drawLine(Offset(endY.dx,endY.dy ),Offset(endY.dx - 3,endY.dy + 5), _linePaint);
          canvas.drawLine(Offset(endY.dx,endY.dy ),Offset(endY.dx + 3,endY.dy + 5), _linePaint);
        }
      }
      if (!config.showYAxisRankLine)  canvas.drawLine(start, endY, _linePaint); //画一条Y轴

      Painter(config).fm_drawYAxisInfo(canvas, size);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ChartColumnPainter extends CustomPainter {
  Paint _bgPaint;
  Paint _barPaint;
  Paint _linePaint;
  List targetPercentList;
  Canvas canvas;
  Config config;

  ChartColumnPainter({@required this.config}) {
    setXAxisTexts(config.xAxisTexts);
    init();
  }

  init() {
    _bgPaint = Paint()
      ..isAntiAlias = true //是否启动抗锯齿
      ..color = config.barBackgroundColor ?? Colors.transparent; //画笔颜色

    _barPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill; //绘画风格，默认为填充;

    _linePaint = Paint()
      ..color = config.xAxisColor
      ..strokeWidth = 0.5;
  }

  setXAxisTexts(List<String> bottomStringList) {
    config..xAxisTexts = bottomStringList;
  }


  Rect bgRect;
  Rect fgRect;

  @override
  void paint(Canvas canvas, Size size) {
//    print("size: " + size.toString());  //画布大小
//  print("config.barMargin:${config.barMargin}");

    // 绘制 Y轴分割线
    if (config.showYAxisRankLine) Painter(config).fm_yAxisRankLines(canvas,size);
    // X轴线 的Y坐标
    double xAxisBottomY = size.height - config.textBottomHeight - config.textBottomMargin - config.textBottomDescent;

    int i = 1;
    if (config.dataList.length != 0) {
      for (int i = 1; i < config.dataList.length; i++) {
        //绘制背景柱形
        bgRect = Rect.fromLTRB(
            config.barMargin * i + config.barWidth * (i - 1),
            config.paddingTop,
            (config.barMargin + config.barWidth) * i,
            size.height -
                config.textBottomHeight -
                config.textBottomMargin -
                config.textBottomDescent);
        canvas.drawRect(bgRect, _bgPaint);

        // 绘制前景柱形
        double rectLeft = config.barMargin * i + config.barWidth * (i - 1);
        final double sh = size.height - config.textBottomHeight- config.textBottomMargin - config.textBottomDescent - config.paddingTop ;
        double rectTop = config.paddingTop + sh  - double.parse(config.dataList[i - 1].toString())  + (config.showCircleBarTop == false ? 0 : config.barWidth);

        _barPaint.color = config.barColors == null ? config.barColor : (i < config.barColors.length
            ? config.barColors[i - 1] : config.barColors.last);
        Color circleColor =  _barPaint.color;

        if (rectTop > xAxisBottomY) _barPaint.color = Colors.transparent;
        fgRect = Rect.fromLTRB(  rectLeft, rectTop,
            (config.barMargin + config.barWidth) * i,
            xAxisBottomY);

        canvas.drawRect(fgRect, _barPaint);

        double showCircleBarTopMargin = 0; // 显示柱状图顶部圆角 时候，适配柱状图数字过低时候 数值显示没间隙问题。
        // 是否柱状图顶部圆角
        if ( config.showCircleBarTop) {
          Painter(config).fm_drawCircle(canvas, fgRect , circleColor, rectTop - xAxisBottomY);
          showCircleBarTopMargin = config.barWidth/2 + (rectTop > xAxisBottomY ? rectTop/2 - xAxisBottomY/2 : 0);
        }

        // 22为具体数值与柱形顶部的间距
        Offset textOffset =
        ui.Offset(rectLeft - config.barWidth / 2, rectTop - 22 - showCircleBarTopMargin);
        double v = double.parse(config.dataList[i - 1].toString()) * config.scale;
        String text = v > 0 ? v.toStringAsFixed(config.toStringAsFixed) : "";

        // 绘制柱状图上面数字
        Painter(config).fm_drawParagraph( canvas, textOffset, text) ; //在bar上描绘具体数值

      }

      double mViewWidth = (config.xAxisTexts.length + 1.5) *
          (config.barWidth + config.barMargin); //整个视图的宽度

      // 画一条X轴线
      Offset start = ui.Offset( 0, xAxisBottomY);
      Offset endX = ui.Offset(mViewWidth,xAxisBottomY );
      canvas.drawLine(start, endX, _linePaint); //画一条X轴

      if (config.showXyAxisArrows) {
        canvas.drawLine(Offset(endX.dx,endX.dy ),Offset(endX.dx - 5,endX.dy - 3), _linePaint);
        canvas.drawLine(Offset(endX.dx,endX.dy ),Offset(endX.dx - 5,endX.dy + 3), _linePaint);
      }

      // //绘制X轴多个文案描述
      if (config.xAxisTexts != null && config.xAxisTexts.isNotEmpty) {
        i = 1;
        for (String bottomText in config.xAxisTexts) {
          Offset bottomTextOffset = Offset(
              config.barMargin * i +
                  config.barWidth * (i - 2) +
                  config.barWidth / 2,
              size.height - config.textBottomHeight - config.textBottomMargin);
          Painter(config).fm_drawParagraph(canvas, bottomTextOffset, bottomText);
          i++;
        }
      }

      // 绘制X轴最右边变量名称
      Offset bottomTextOffset = Offset(
          config.barMargin * i + config.barWidth * (i - 1),
          size.height - config.textBottomHeight - config.textBottomMargin);
      Painter(config).fm_drawParagraph(canvas, bottomTextOffset, config.xText);
    }
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Painter {
  Config config;

  Painter(this.config);
  /// 画文字
  void fm_drawParagraph( Canvas canvas, Offset offset, String text, ) {
    ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign
            .center, //在ui.ParagraphConstraints(width: barWidth * 2);所设置的宽度中居中显示
        fontSize: config.xFontSize * (config.barWidth/15 > 1.2 ? 1.2 : (config.barWidth/15 < 0.8 ? 0.8 : config.barWidth/15)),
//        maxLines: 1
      ),
    )..pushStyle(ui.TextStyle(color: config.textColor));
    paragraphBuilder.addText(text);

    ParagraphConstraints pc =
    ui.ParagraphConstraints(width: config.barWidth * 2); //字体可用宽度
    //这里需要先layout, 后面才能获取到文字高度
    Paragraph textParagraph = paragraphBuilder.build()..layout(pc);
    canvas.drawParagraph(textParagraph, offset); //描绘offset所表示的位置上描绘文字text
  }

  /// 画y轴分割线
  void fm_yAxisRankLines(Canvas canvas, Size size) {
    double  _sh = size.height - config.textBottomHeight- config.textBottomMargin - config.textBottomDescent - config.paddingTop ;
    final double gap = _sh / config.yAxisRankNum;
    final List<double> yAxisLabels = [];
    Paint paint = Paint()
      ..color = config.showYAxisRankLine
          ? config.yAxisRankLineColor
          : config.yAxisTextColor
      ..strokeWidth = config.yAxisRankHeight;

    for (int i = 1; i <= config.yAxisRankNum; i++) {
      yAxisLabels.add(gap * i);
    }
    yAxisLabels.asMap().forEach(
          (index, label) {
        // 标识的高度为画布高度减去标识的值
        final double top = size.height - label - config.textBottomHeight - config.textBottomMargin - config.textBottomDescent;
        final rect = Rect.fromLTWH(
          -300,
          top,
          config.showYAxisRankLine == true ? (config.xAxisTexts.length )* ((config.barWidth + config.barMargin)) + 600 : 0,
          (config.showYAxisRankLine == true ? 1 : 2) * config.yAxisRankHeight,
        ); // 左边 - 300 ，右边 +300 是为了左右延长分割线，左右拖拽视图时候分割线还有显示效果。

        // 绘制 Y轴右边的线条
        if(config.dataList.length > 0) canvas.drawRect(rect, paint);
      },
    );
  }

  /// 画圆画弧
  void fm_drawCircle(Canvas canvas, Rect rect, Color color, double height) {
    var paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 1.0
      ..color = color
      ..strokeCap = StrokeCap.square
      ..invertColors = false;
    if (height < 0) { // 柱状图数值大于半圆，直接在顶部显示。
      canvas.drawArc(Rect.fromLTWH(rect.left,rect.top - config.barWidth/2,config.barWidth,config.barWidth), 0.0, -pi, true, paint);
    }else {// 柱状图数值小于半圆，需要处理只显示弧形。
      canvas.drawArc(Rect.fromLTWH(rect.left,rect.top - height/2 - config.barWidth/2 ,config.barWidth, config.barWidth - height), 0.0, -pi, true, paint);
    }
  }

  /// 画Y轴 Y轴分割线 Y轴文案
  void fm_drawYAxisInfo(Canvas canvas, Size size) {
    double _sh = size.height - config.textBottomHeight- config.textBottomMargin - config.textBottomDescent - config.paddingTop ;
    double yAxisRankWidth = config.yAxisRankWidth;
    final double gap = _sh / config.yAxisRankNum;
    final List<double> yAxisLabels = [];

    Paint paint = Paint()
      ..color = config.showYAxisRankLine
          ? config.yAxisRankLineColor
          : config.yAxisTextColor
      ..strokeWidth = config.yAxisRankHeight;

    // 使用 50.0 为间隔绘制比传入数据多一个的标识
    for (int i = 0; i <= config.yAxisRankNum; i++) {
      yAxisLabels.add(gap * i);
    }

    yAxisLabels.asMap().forEach(
          (index, label) {
        TextSpan textSpan = TextSpan(
          text: (label* config.scale).toStringAsFixed(config.toStringAsFixed),
          style: TextStyle(
              fontSize: config.xFontSize, color: config.yAxisTextColor),
        );

        // 绘制文字需要用 `TextPainter`，最后调用 paint 方法绘制文字
        TextPainter painter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.right,
          textDirection: TextDirection.ltr,
          textWidthBasis: TextWidthBasis.longestLine,
        )..layout(
            minWidth: 0, maxWidth: config.yAxisWidth - yAxisRankWidth * 1.2)  ;
        painter.layout();

        // 标识的高度为画布高度减去标识的值
        final double top = size.height - label - config.textBottomHeight - config.textBottomMargin - config.textBottomDescent;
        double wLine = index == 0 ? 0 : yAxisRankWidth;
        final rect = Rect.fromLTWH(
          config.yAxisWidth - yAxisRankWidth,
          top,
          wLine,
          (config.showYAxisRankLine == true ? 1 : 2) * config.yAxisRankHeight,
        );
        final Offset textOffset = Offset(
          config.yAxisWidth - painter.size.width - yAxisRankWidth * 2,
          top - config.xFontSize / 2  ,
        );

        // 绘制 Y轴右边的线条
        if (index <= config.yAxisRankNum) canvas.drawRect(rect, paint);
        painter.paint(canvas, textOffset);
      },
    );
  }

}
