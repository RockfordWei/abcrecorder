package ca.treefrog.abcrecorder

import android.app.Dialog
import android.content.Intent
import android.net.Uri
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.text.Html
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.widget.LinearLayout
import android.widget.Toast
import androidx.core.content.FileProvider
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.android.synthetic.main.activity_main.*
import java.io.File
import java.io.OutputStream
import java.lang.Exception
import java.nio.charset.Charset
import java.util.*

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
                Dialog(this).alert()
                return@setOnClickListener
            }
            val id = adapter.selection.first()
            val intent = Intent(this, FormActivity::class.java)
            intent.putExtra(UserDefault.RECORD_ID, id.toString())
            startActivityForResult(intent, UserDefault.RECORD_UPDATE)
        }

        buttonDelete.setOnClickListener {
            if (adapter.selection.isEmpty()) {
                Dialog(this).alert()
                return@setOnClickListener
            }
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

        buttonMail.setOnClickListener {
            if (adapter.selection.isEmpty()) {
                Dialog(this).alert()
                return@setOnClickListener
            }
            loadAsset("template.html")?.let { template ->
                val records = default.recordset.records
                    .filter { adapter.selection.contains(it.id) }
                    .sortedByDescending { it.time_start }
                val rows = records.map { it.html_row }.joinToString("\n")
                val html = template.replace("<!--TBODY-->", rows)
                val csv_body = ABCRecord.csv_header + records.map { it.csv_row }.joinToString("\n")


                val folder = File(filesDir, "/")
                if (!folder.exists()) {
                    folder.mkdir()
                }
                val csvFile = File(folder.path, "abc_record.csv")
                csvFile.writeText(csv_body, Charset.defaultCharset())

                val htmFile = File(folder.path, "abc_record.htm")
                htmFile.writeText(html, Charset.defaultCharset())

                val csvUri = FileProvider.getUriForFile(this, "ca.treefrog.abcrecorder.fileprovider", csvFile)
                val htmUri = FileProvider.getUriForFile(this, "ca.treefrog.abcrecorder.fileprovider", htmFile)
                val intent = Intent(Intent.ACTION_SEND_MULTIPLE)

                val mimeTypes = arrayOf("text/csv", "text/html")
                intent.setType("vnd.android.cursor.dir/email");
                intent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes)
                intent.putExtra(Intent.EXTRA_SUBJECT, getString(R.string.text_mail_title, Date().toFormattedString()))

                val uriList = arrayListOf(csvUri, htmUri)
                intent.putParcelableArrayListExtra(Intent.EXTRA_STREAM, uriList)
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                startActivity(intent)
            }
        }
    }

    private fun loadAsset(fileName: String): String? {
        try {
            val inputStream = assets.open(fileName)
            val size = inputStream.available()
            if (size < 1) return null
            val buffer = ByteArray(size)
            inputStream.read(buffer)
            inputStream.close()
            return String(buffer, Charset.defaultCharset())
        } catch (error: Exception) {
            Log.d("DEBUG", error.toString())
            return null
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