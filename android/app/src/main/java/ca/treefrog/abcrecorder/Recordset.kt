package ca.treefrog.abcrecorder

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize
import java.util.*

@Parcelize
data class Recordset(var records: MutableList<ABCRecord>): Parcelable {
    fun update(record: ABCRecord) {
        delete(record)
        records.add(record)
    }
    fun delete(record: ABCRecord) {
        val index = records.indexOfFirst { it.id == record.id }
        if (index >= 0) {
            records.removeAt(index)
        }
    }
    fun get(id: UUID): ABCRecord? {
        val index = records.indexOfFirst { it.id == id }
        return if (index < 0) null else records[index]
    }
    fun presentation(): List<Presentable> {
        val groups = records.groupBy { it.time_start.begin() }
        val items = mutableListOf<Presentable>()
        groups.keys.forEach { date ->
            groups[date]?.let {
                items.add(Presentable(null, date.toDateString(), null))
                it.sortedByDescending { it.time_start }.forEach {
                    items.add(Presentable(it.id, it.client_behaviour, it.time_start.toHourString()))
                }
            }
        }
        return items
    }
}

data class Presentable(val id: UUID?, val text: String, val detail: String?)