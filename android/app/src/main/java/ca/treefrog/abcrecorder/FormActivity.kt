package ca.treefrog.abcrecorder

import android.os.Bundle
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_form.*
import java.util.*

class FormActivity: AppCompatActivity() {

    private var record = ABCRecord()
    lateinit private var default: UserDefault
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        default = UserDefault(this)
        setContentView(R.layout.activity_form)

        supportActionBar?.let { toolbar ->
            toolbar.setHomeButtonEnabled(true)
            toolbar.setDisplayHomeAsUpEnabled(true)
        }

        buttonUpdate.setText(R.string.button_add_record)
        textTimeStart.setText(Date().toFormattedString())
        textTimeStop.setText(Date().toFormattedString())
        intent.getStringExtra(UserDefault.RECORD_ID)?.let {
            UUID.fromString(it)?.let {
                default.get(it)?.let {
                    record = it
                    textTimeStart.setText(it.time_start.toFormattedString())
                    textTimeStop.setText(it.time_end.toFormattedString())
                    textLocation.setText(it.location)
                    textPreClient.setText(it.precondition_client)
                    textPreReporter.setText(it.precondition_reporter)
                    textClientDoing.setText(it.client_behaviour)
                    textClientSaying.setText(it.client_saying)
                    textReporterAction.setText(it.reporter_action)
                    textReporterResponse.setText(it.reporter_saying)
                    buttonUpdate.setText(R.string.button_update_record)
                }
            }
        }

        buttonUpdate.setOnClickListener {
            record.time_start = textTimeStart.text.toString().toTimestamp()
            record.time_end = textTimeStop.text.toString().toTimestamp()
            record.location = textLocation.text.toString()
            record.precondition_client = textPreClient.text.toString()
            record.precondition_reporter = textPreReporter.text.toString()
            record.client_behaviour = textClientDoing.text.toString()
            record.client_saying = textClientSaying.text.toString()
            record.reporter_action = textReporterAction.text.toString()
            record.reporter_saying = textReporterResponse.text.toString()
            default.update(record)
            finishActivity(UserDefault.RECORD_UPDATE)
        }
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            android.R.id.home -> onBackPressed()
        }
        return true
    }
}