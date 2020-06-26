package ca.treefrog.abcrecorder

import java.text.SimpleDateFormat
import java.util.*

fun Date.begin(): Date {
    val cal = Calendar.getInstance()
    cal.time = this
    cal.set(Calendar.HOUR_OF_DAY, 0)
    cal.set(Calendar.MINUTE, 0)
    cal.set(Calendar.SECOND, 0)
    cal.set(Calendar.MILLISECOND, 0)
    return cal.time
}

fun Date.toFormattedString(format: String = "yyyy-MM-dd HH:mm"): String {
    val fmt = SimpleDateFormat(format, Locale.getDefault())
    return fmt.format(this)
}

fun Date.toDateString(): String {
    return toFormattedString("yyyy-MM-dd")
}

fun Date.toHourString(): String {
    return toFormattedString("HH:mm")
}

fun String.toTimestamp(format: String = "yyyy-MM-dd HH:mm"): Date {
    val fmt = SimpleDateFormat(format, Locale.getDefault())
    return fmt.parse(this)?:Date()
}