package ca.treefrog.abcrecorder

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.CheckBox
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import java.util.*

class RecordAdapter(private val records: List<Presentable>) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    companion object {
        private val TYPE_SECTION = 0
        private val TYPE_ITEM = 1
    }

    var selection: MutableSet<UUID> = mutableSetOf()

    override fun getItemCount(): Int {
        return records.size
    }

    override fun getItemViewType(position: Int): Int {
        records[position].id?.let {
            return TYPE_ITEM
        }
        return TYPE_SECTION
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) = holder.let {
        if (holder.itemViewType == TYPE_SECTION) {
            (it as SectionViewHolder).onBind(position)
        } else {
            (it as ItemViewHolder).onBind(position)
        }
    }
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == TYPE_SECTION)
            SectionViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.item_section, parent, false))
        else
            ItemViewHolder(LayoutInflater.from(parent.context).inflate(R.layout.item_event, parent, false))
    }
    inner class SectionViewHolder(view: View): RecyclerView.ViewHolder(view) {
        fun onBind(position: Int) {
            itemView.findViewById<TextView>(R.id.textSectionHeader).setText(records[position].text)
        }
    }

    inner class ItemViewHolder(view: View): RecyclerView.ViewHolder(view) {
        fun onBind(position: Int) {
            val checkbox = itemView.findViewById<CheckBox>(R.id.checkableEventSummary)
            records[position].let { rec ->
                rec.detail?.let { detail ->
                    val summary = itemView.context.getString(R.string.text_label, detail, rec.text)
                    checkbox.setText(summary)
                    rec.id?.let {
                        checkbox.isChecked = selection.contains(it)
                    }
                }
            }
            checkbox.setOnCheckedChangeListener { _, isChecked ->
                records[position].id?.let { id ->
                    if (isChecked) {
                        selection.add(id)
                    } else {
                        selection.remove(id)
                    }
                }
            }
        }
    }

}