package com.teravolt.launcher.adapter

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.teravolt.launcher.databinding.ItemDashboardCardBinding
import com.teravolt.launcher.model.DashboardCard

/**
 * Adapter for dashboard cards
 */
class DashboardCardAdapter : ListAdapter<DashboardCard, DashboardCardAdapter.ViewHolder>(DiffCallback) {

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            ItemDashboardCardBinding.inflate(
                LayoutInflater.from(parent.context),
                parent,
                false
            )
        )
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    inner class ViewHolder(private val binding: ItemDashboardCardBinding) :
        RecyclerView.ViewHolder(binding.root) {

        fun bind(card: DashboardCard) {
            binding.cardTitle.text = card.title
            binding.cardSubtitle.text = card.subtitle
            binding.cardStatus.text = card.status
        }
    }

    companion object DiffCallback : DiffUtil.ItemCallback<DashboardCard>() {
        override fun areItemsTheSame(oldItem: DashboardCard, newItem: DashboardCard): Boolean {
            return oldItem.title == newItem.title
        }

        override fun areContentsTheSame(oldItem: DashboardCard, newItem: DashboardCard): Boolean {
            return oldItem == newItem
        }
    }
}
