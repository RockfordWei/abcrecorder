package ca.treefrog.abcrecorder

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson

class UserDefault {
    companion object {
        lateinit private var standard: SharedPreferences
        fun init(context: Context) {
            standard = context.getSharedPreferences("ca.treefrog.abcrecorder.default.user", Context.MODE_PRIVATE)
        }

        private const val _RECORDSET = "recordset"
        private fun load(): Recordset? {
            standard.getString(_RECORDSET, null)?.let { json ->
                return Gson().fromJson(json, Recordset::class.java)
            }
            return null
        }
        private fun save(recordset: Recordset) {
            Gson().toJson(recordset)?.let { standard.edit().putString(_RECORDSET, it).apply() }
        }

        val recordset = load()?: Recordset(mutableMapOf())

        fun update(record: ABCRecord) {
            recordset.update(record)
            save(recordset)
        }

        fun delete(record: ABCRecord) {
            recordset.delete(record)
            save(recordset)
        }
    }
}