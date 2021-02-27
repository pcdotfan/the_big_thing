package cx.g4.the_big_thing

import android.appwidget.AppWidgetManager
import android.content.Context
import android.widget.RemoteViews
import android.app.PendingIntent
import android.content.Intent
import android.content.SharedPreferences
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Implementation of App Widget functionality.
 */
class NewAppWidget : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.new_app_widget).apply {
                setOnClickPendingIntent(R.id.widget_container,
                        PendingIntent.getActivity(context, 0, Intent(context, MainActivity::class.java), 0))
                setTextViewText(R.id.widget_title, widgetData.getString("title", null)
                        ?: "No Title Set")
                setTextViewText(R.id.widget_message, widgetData.getString("message", null)
                        ?: "No Message Set")
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}
