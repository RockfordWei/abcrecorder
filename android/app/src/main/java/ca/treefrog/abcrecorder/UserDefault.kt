package ca.treefrog.abcrecorder

import android.content.Context
import android.content.SharedPreferences
import android.util.Log
import com.google.gson.Gson
import java.lang.Exception
import java.util.*

class UserDefault(context: Context) {

    companion object {
        private const val _RECORDSET = "recordset"
        const val RECORD_ID = "record_id"
        const val RECORD_UPDATE = 649
        private val gson = Gson().newBuilder().setDateFormat("yyyy-MM-dd HH:mm").create()
    }

    private var standard: SharedPreferences  = context.getSharedPreferences("ca.treefrog.abcrecorder.default.user", Context.MODE_PRIVATE)

    private fun load(): Recordset? {
        standard.getString(_RECORDSET, null)?.let { json ->
            try {
                return gson.fromJson(json, Recordset::class.java)
            } catch (error: Exception) {
                Log.d("ERROR", error.toString())
                Log.d("DEBUG", json)
                return null
            }
        }
        return null
    }
    private fun save(recordset: Recordset) {
        gson.toJson(recordset)?.let {
            Log.d("SAVING", it)
            standard.edit().putString(_RECORDSET, it).apply()
            return
        }
        Log.d("DEBUG", "gson save failure")
    }

    var recordset: Recordset
        get() = load()?: Recordset(mutableListOf())
        set(newValue) = save(newValue)

    fun get(id: UUID): ABCRecord? {
        return recordset.get(id)
    }

    fun update(record: ABCRecord) {
        val rec = recordset
        rec.update(record)
        save(rec)
        recordset = rec
    }

    fun delete(id: UUID) {
        val rec = recordset
        rec.records.firstOrNull { it.id == id }?.let {
            rec.delete(it)
            save(rec)
            recordset = rec
        }
    }
}
