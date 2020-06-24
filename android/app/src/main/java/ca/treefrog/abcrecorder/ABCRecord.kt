package ca.treefrog.abcrecorder

import android.os.Parcelable
import kotlinx.android.parcel.Parcelize
import java.util.*

@Parcelize
data class ABCRecord (
    var id: UUID = UUID.randomUUID(),
    var time_start: Date = Date(),
    var time_end: Date = Date(),
    var location: String = "",
    var precondition_client: String = "",
    var precondition_reporter: String = "",
    var client_behaviour: String = "",
    var client_saying: String = "",
    var reporter_action: String = "",
    var reporter_saying: String = ""
): Parcelable {

    companion object {
        val csv_header: String = listOf(
            "id", "start time", "end time", "Where were you and Client?",
            "What was he doing/saying before the behaviour?",
            "What were you doing/saying before the behaviour?",
            "What did he do?", "What did he say?",
            "What did you do?", "Waht did you say?")
            .map { "\"$it\"" }.joinToString(",")
    }
    val csv_row: String
    get() = listOf(id.toString(), time_start.toString(), time_end.toString(),
        location, precondition_client, precondition_reporter, client_behaviour, client_saying,
        reporter_action, reporter_saying).map { "\"$it\"" }.joinToString()
    val html_row: String
    get()  =
        """
		<tr>
			<td>
				<p>DATE: <u>$time_start</u></p>
				<p>START TIME:<br/><u>$time_start</u></p>
				<p>END TIME:<br/><u>$time_end</u></p>
			</td>
			<td>
				<p><b>Where were you and Client?</b><br/>\(location)</p>
				<p><b>What was he doing/saying before the behaviour</b><br/>$precondition_client</p>
				<p><b>What were you doing/saying before the behaviour</b><br/>$precondition_reporter</p>
			</td>
			<td>
				<p><b>What did he do?</b><br/>$client_behaviour</p>
				<p><b>What did he say?</b><br/>$client_saying</p>
			</td>
			<td>
				<p><b>What did you do?</b><br/>$reporter_action</p>
				<p><b>What did you say?</b><br/>$reporter_saying</p>
			</td>
		</tr>
		"""
}