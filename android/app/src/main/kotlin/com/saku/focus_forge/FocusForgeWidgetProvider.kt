package com.saku.focus_forge

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class FocusForgeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.focus_forge_widget).apply {
                // Ambil data yang dikirim oleh Flutter dari SharedPreferences
                val streakText = widgetData.getString("streak_text", "🔥 0 Hari")
                val scheduleTitle = widgetData.getString("schedule_title", "Tidak Ada Jadwal")
                val scheduleTime = widgetData.getString("schedule_time", "Mulai buat jadwal baru!")
                val isDark = widgetData.getBoolean("is_dark", true)

                // Perbarui tampilan teks widget utama
                setTextViewText(R.id.widget_streak, streakText)
                setTextViewText(R.id.widget_schedule_title, scheduleTitle)
                setTextViewText(R.id.widget_schedule_time, scheduleTime)

                // === DYNAMIC THEME STYLING ===
                if (isDark) {
                    setInt(R.id.widget_root, "setBackgroundResource", R.drawable.widget_background_dark)
                    setTextColor(R.id.widget_title, Color.parseColor("#8095FF"))
                    setTextColor(R.id.widget_subtitle, Color.parseColor("#6C6E85"))
                    setInt(R.id.widget_streak_container, "setBackgroundColor", Color.parseColor("#222538"))
                    setTextColor(R.id.widget_streak, Color.parseColor("#FFB74D"))
                    
                    setInt(R.id.widget_divider_1, "setBackgroundColor", Color.parseColor("#2A2C3E"))
                    setInt(R.id.widget_divider_2, "setBackgroundColor", Color.parseColor("#2A2C3E"))
                    
                    setTextColor(R.id.widget_schedule_label, Color.parseColor("#8E91A8"))
                    setTextColor(R.id.widget_schedule_title, Color.parseColor("#FFFFFF"))
                    setTextColor(R.id.widget_schedule_time, Color.parseColor("#A5A8C0"))
                } else {
                    setInt(R.id.widget_root, "setBackgroundResource", R.drawable.widget_background_light)
                    setTextColor(R.id.widget_title, Color.parseColor("#3B82F6"))
                    setTextColor(R.id.widget_subtitle, Color.parseColor("#4B5563"))
                    setInt(R.id.widget_streak_container, "setBackgroundColor", Color.parseColor("#FFE0B2"))
                    setTextColor(R.id.widget_streak, Color.parseColor("#E65100"))
                    
                    setInt(R.id.widget_divider_1, "setBackgroundColor", Color.parseColor("#E2E8F0"))
                    setInt(R.id.widget_divider_2, "setBackgroundColor", Color.parseColor("#E2E8F0"))
                    
                    setTextColor(R.id.widget_schedule_label, Color.parseColor("#4B5563"))
                    setTextColor(R.id.widget_schedule_title, Color.parseColor("#1F2937"))
                    setTextColor(R.id.widget_schedule_time, Color.parseColor("#4B5563"))
                }

                // === TODAY'S TASKS LIST RENDERING ===
                val taskCountText = widgetData.getString("task_count_text", "TUGAS (0)")
                setTextViewText(R.id.widget_tasks_label, taskCountText)
                setTextColor(R.id.widget_tasks_label, Color.parseColor(if (isDark) "#8E91A8" else "#4B5563"))

                // Task item 1
                val task1Title = widgetData.getString("task_1_title", "")
                val task1Completed = widgetData.getBoolean("task_1_completed", false)
                if (task1Title.isNullOrEmpty()) {
                    setViewVisibility(R.id.widget_task_1_container, View.VISIBLE)
                    setTextViewText(R.id.widget_task_1_status, "")
                    setTextViewText(R.id.widget_task_1_title, "Tidak ada tugas")
                    setTextColor(R.id.widget_task_1_title, Color.parseColor(if (isDark) "#6C6E85" else "#9CA3AF"))
                    
                    setViewVisibility(R.id.widget_task_2_container, View.GONE)
                    setViewVisibility(R.id.widget_task_3_container, View.GONE)
                } else {
                    setViewVisibility(R.id.widget_task_1_container, View.VISIBLE)
                    setTextViewText(R.id.widget_task_1_status, if (task1Completed) "☑" else "☐")
                    setTextViewText(R.id.widget_task_1_title, task1Title)
                    
                    val statusColor1 = if (task1Completed) (if (isDark) "#4CAF50" else "#2E7D32") else (if (isDark) "#FFB74D" else "#E65100")
                    setTextColor(R.id.widget_task_1_status, Color.parseColor(statusColor1))
                    
                    val titleColor1 = if (task1Completed) (if (isDark) "#6C6E85" else "#9CA3AF") else (if (isDark) "#FFFFFF" else "#1F2937")
                    setTextColor(R.id.widget_task_1_title, Color.parseColor(titleColor1))

                    // Task item 2
                    val task2Title = widgetData.getString("task_2_title", "")
                    val task2Completed = widgetData.getBoolean("task_2_completed", false)
                    if (task2Title.isNullOrEmpty()) {
                        setViewVisibility(R.id.widget_task_2_container, View.GONE)
                        setViewVisibility(R.id.widget_task_3_container, View.GONE)
                    } else {
                        setViewVisibility(R.id.widget_task_2_container, View.VISIBLE)
                        setTextViewText(R.id.widget_task_2_status, if (task2Completed) "☑" else "☐")
                        setTextViewText(R.id.widget_task_2_title, task2Title)
                        
                        val statusColor2 = if (task2Completed) (if (isDark) "#4CAF50" else "#2E7D32") else (if (isDark) "#FFB74D" else "#E65100")
                        setTextColor(R.id.widget_task_2_status, Color.parseColor(statusColor2))
                        
                        val titleColor2 = if (task2Completed) (if (isDark) "#6C6E85" else "#9CA3AF") else (if (isDark) "#FFFFFF" else "#1F2937")
                        setTextColor(R.id.widget_task_2_title, Color.parseColor(titleColor2))

                        // Task item 3
                        val task3Title = widgetData.getString("task_3_title", "")
                        val task3Completed = widgetData.getBoolean("task_3_completed", false)
                        if (task3Title.isNullOrEmpty()) {
                            setViewVisibility(R.id.widget_task_3_container, View.GONE)
                        } else {
                            setViewVisibility(R.id.widget_task_3_container, View.VISIBLE)
                            setTextViewText(R.id.widget_task_3_status, if (task3Completed) "☑" else "☐")
                            setTextViewText(R.id.widget_task_3_title, task3Title)
                            
                            val statusColor3 = if (task3Completed) (if (isDark) "#4CAF50" else "#2E7D32") else (if (isDark) "#FFB74D" else "#E65100")
                            setTextColor(R.id.widget_task_3_status, Color.parseColor(statusColor3))
                            
                            val titleColor3 = if (task3Completed) (if (isDark) "#6C6E85" else "#9CA3AF") else (if (isDark) "#FFFFFF" else "#1F2937")
                            setTextColor(R.id.widget_task_3_title, Color.parseColor(titleColor3))
                        }
                    }
                }

                // Siapkan PendingIntent untuk membuka aplikasi utama ketika widget di-klik
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
