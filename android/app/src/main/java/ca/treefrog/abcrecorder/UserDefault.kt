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
        gson.toJson(recordset)?.let { standard.edit().putString(_RECORDSET, it).apply() }
    }

    val recordset = load()?: Recordset(mutableMapOf())

    fun get(id: UUID): ABCRecord? {
        return recordset.get(id)
    }

    fun update(record: ABCRecord) {
        recordset.update(record)
        save(recordset)
    }

    fun delete(record: ABCRecord) {
        recordset.delete(record)
        save(recordset)
    }
}
