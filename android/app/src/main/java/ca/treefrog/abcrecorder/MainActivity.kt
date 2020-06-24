package ca.treefrog.abcrecorder

import android.content.Intent
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        buttonAdd.setOnClickListener {
            val intent = Intent(this, FormActivity::class.java)
            startActivityForResult(intent, UserDefault.RECORD_UPDATE)
        }
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
            Log.d("DEBUG", "data table reload")
        }
    }
}