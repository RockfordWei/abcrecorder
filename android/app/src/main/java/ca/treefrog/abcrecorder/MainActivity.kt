package ca.treefrog.abcrecorder

import android.app.Dialog
import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.widget.LinearLayout
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {

    lateinit private var default: UserDefault
    lateinit private var adapter: RecordAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        default = UserDefault(this)

        setContentView(R.layout.activity_main)
        buttonAdd.setOnClickListener {
            val intent = Intent(this, FormActivity::class.java)
            startActivityForResult(intent, UserDefault.RECORD_UPDATE)
        }
        tableRecords.layoutManager = LinearLayoutManager(this)
        reload()

        buttonEdit.setOnClickListener {
            if (adapter.selection.isEmpty()) {
                return@setOnClickListener
            }
            val id = adapter.selection.first()
            val intent = Intent(this, FormActivity::class.java)
            intent.putExtra(UserDefault.RECORD_ID, id.toString())
            startActivityForResult(intent, UserDefault.RECORD_UPDATE)
        }

        buttonDelete.setOnClickListener {

            Dialog(this).confirm {
                adapter.selection.forEach {
                    default.delete(it)
                }
                reload()
            }
        }

        buttonAll.setOnClickListener {
            adapter.selection = if (adapter.selection.isEmpty()) default.recordset.records.map { it.id }.toMutableSet() else mutableSetOf()
            adapter.notifyDataSetChanged()
        }
    }

    private fun reload() {
        adapter = RecordAdapter(default.recordset.presentation())
        tableRecords.adapter = adapter
        tableRecords.adapter?.notifyDataSetChanged()
    }
    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.about, menu)
        return true
    }
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        val code = BuildConfig.VERSION_CODE
        val extra = if (BuildConfig.DEBUG) "debug" else ""
        when (item.itemId) {
            R.id.menu_about ->
                packageManager.getPackageInfo(packageName, 0).versionName?.let { version ->
                    Toast.makeText(this, getString(R.string.text_build, version, code, extra), Toast.LENGTH_LONG).show()
                }
        }
        return true
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == UserDefault.RECORD_UPDATE) {
            reload()
        }
    }
}