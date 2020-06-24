package ca.treefrog.abcrecorder

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize
import java.util.*

@Parcelize
data class Recordset(var records: MutableMap<Date, MutableList<ABCRecord>>): Parcelable {
    fun update(record: ABCRecord) {
        val key = record.time_start.begin()
        records[key]?.let { list ->
            val index = list.indexOfFirst { it.id == record.id }
            if (index >= 0) {
                list.removeAt(index)
            }
            list.add(record)
            list.sortedByDescending { it.time_start }
            records[key] = list
            return
        }
        records[key] = mutableListOf(record)
    }
    fun delete(record: ABCRecord) {
        val key = record.time_start.begin()
        records[key]?.let { list ->
            val index = list.indexOfFirst { it.id == record.id }
            if (index >= 0) {
                list.removeAt(index)
            }
            records[key] = list
            return
        }
    }
    fun get(id: UUID): ABCRecord? {
        return records.values.flatMap { it }.first { it.id == id }
    }
}