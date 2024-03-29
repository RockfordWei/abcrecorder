package ca.treefrog.abcrecorder

import android.app.Dialog
import android.widget.TextView
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

fun Dialog.confirm(title: String? = null, message: String? = null, ok: ()-> Unit) {
    setContentView(R.layout.dialog_ok_cancel)
    title?.let {
        val textDialogTitle = findViewById<TextView>(R.id.textDialogTitle)
        textDialogTitle.text = it
    }
    message?.let {
        val textDialogContent = findViewById<TextView>(R.id.textDialogContent)
        textDialogContent.text = it
    }
    val buttonOk = findViewById<android.widget.Button>(R.id.buttonDialogOK)
    val buttonCancel = findViewById<android.widget.Button>(R.id.buttonDialogCancel)
    buttonCancel.setOnClickListener { dismiss() }
    buttonOk.setOnClickListener {
        dismiss()
        ok()
    }
    show()
}

fun Dialog.alert(message: String? = null) {
    setContentView(R.layout.dialog_ok)
    message?.let {
        val textDialogContent = findViewById<TextView>(R.id.textDialogOKContent)
        textDialogContent.text = it
    }
    val buttonOk = findViewById<android.widget.Button>(R.id.buttonDialogAlertOK)
    buttonOk.setOnClickListener {
        dismiss()
    }
    show()
}