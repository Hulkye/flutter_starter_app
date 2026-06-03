import 'package:date_format/date_format.dart';

///时间格式处理
class DateTimeUtil {
  static DateTime? parseDateTimeStr(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static bool matchTimeAfterHoursUTC(
    int? mills, {
    int beforeHours = 1,
    int hours = 24,
  }) {
    final nowTime = DateTime.now().toUtc();
    // 最小utc时间
    var minUtcMills = nowTime
        .subtract(Duration(hours: beforeHours))
        .millisecondsSinceEpoch;
    // 最大utc时间
    var maxUtcMills = nowTime
        .add(Duration(hours: hours))
        .millisecondsSinceEpoch;
    return mills != null && mills > minUtcMills && mills <= maxUtcMills;
  }

  /// 通用，业务端传格式
  static String getFormatDate(DateTime datetime, List<String> formats) {
    return formatDate(datetime, formats);
  }

  ///返回yyyy-mm-dd,
  static String getYearMonthDay(
    DateTime datetime, {
    String tag = '-',
    bool monthShortName = false,
  }) {
    return formatDate(datetime, [yyyy, tag, monthShortName ? M : mm, tag, dd]);
  }

  ///返回HH:nn
  static String getHourMinute(DateTime datetime, {String tag = ':'}) {
    return formatDate(datetime, [HH, tag, nn]);
  }

  ///返回dd/mm
  static String getDayMonth(
    DateTime datetime, {
    String tag = '/',
    bool monthShortName = false,
  }) {
    return formatDate(datetime, [dd, tag, monthShortName ? M : mm]);
  }

  ///返回yyyy
  static String getYear(DateTime datetime, {String? format}) {
    return formatDate(datetime, [format ?? yyyy]);
  }

  ///返回mm
  static String getMonth(DateTime datetime, {String? format}) {
    return formatDate(datetime, [format ?? mm]);
  }

  ///返回dd
  static String getDay(DateTime datetime, {String? format}) {
    return formatDate(datetime, [format ?? dd]);
  }

  ///返回dd/mm/yyyy HH:nn
  static String getDayMonthYearHourMinute(
    DateTime datetime, {
    String dateTag = '/',
    String timeTag = ':',
    String spaceTag = ' ',
    bool monthShortName = false,
  }) {
    return formatDate(datetime, [
      dd,
      dateTag,
      monthShortName ? M : mm,
      dateTag,
      yyyy,
      spaceTag,
      HH,
      timeTag,
      nn,
    ]);
  }

  ///YYYYMMDDHHmmss转UTC0时间
  static DateTime? getDateTimeWithUTCString(String datetimeStr) {
    if (datetimeStr.length == 14) {
      final year = datetimeStr.substring(0, 4);
      final month = datetimeStr.substring(4, 6);
      final day = datetimeStr.substring(6, 8);
      final hour = datetimeStr.substring(8, 10);
      final min = datetimeStr.substring(10, 12);
      final second = datetimeStr.substring(12);
      //todo 临时按照北京时间转换
      try {
        DateTime theDateTime = DateTime.parse(
          "$year-$month-${day}T$hour:$min:${second}Z",
        );
        return theDateTime.subtract(const Duration(hours: 8));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  //生成今天，时分秒为0
  static DateTime generateToday() {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
  }

  //生成前后n天日期范围
  static List<DateTime> generateDateRange(
    DateTime today,
    int daysBefore,
    int daysAfter,
  ) {
    return List.generate(
      daysBefore + daysAfter + 1,
      (index) => today.subtract(Duration(days: daysBefore - index)),
    );
  }

  ///判断是否同一天，不考虑时分秒
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  ///解析响应体的date时间Wed, 21 Oct 2015 07:28:00 GMT
  static int? getMillsFromResponseDate(String dateStr) {
    try {
      // 1. 分割字符串
      List<String> parts = dateStr.replaceAll(',', '').split(' ');

      // 2. 定义月份映射
      const Map<String, int> months = {
        'Jan': 1,
        'Feb': 2,
        'Mar': 3,
        'Apr': 4,
        'May': 5,
        'Jun': 6,
        'Jul': 7,
        'Aug': 8,
        'Sep': 9,
        'Oct': 10,
        'Nov': 11,
        'Dec': 12,
      };

      // 3. 解析时间部分
      List<String> timeParts = parts[4].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      int second = int.parse(timeParts[2]);

      // 4. 构造DateTime对象（UTC）
      DateTime dateTime = DateTime.utc(
        int.parse(parts[3]),
        months[parts[2]]!,
        int.parse(parts[1]),
        hour,
        minute,
        second,
      );

      // 5. 转换为时间戳
      int timestampMs = dateTime.millisecondsSinceEpoch;
      return timestampMs;
    } catch (e) {
      return null;
    }
  }

  static bool isYesterday(DateTime today, DateTime day) {
    // 将时间归零（忽略时分秒），避免跨天误差
    final todayDate = DateTime(today.year, today.month, today.day);
    final dayDate = DateTime(day.year, day.month, day.day);

    // 计算天数差
    final difference = todayDate.difference(dayDate).inDays;
    return difference == 1; // today - day = 1天 → day是today的昨天
  }

  static bool isTomorrow(DateTime today, DateTime day) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final dayDate = DateTime(day.year, day.month, day.day);

    final difference = todayDate.difference(dayDate).inDays;
    return difference == -1; // today - day = -1天 → day是today的明天
  }
}
