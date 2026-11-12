package com.han1meviewer.flutter

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val aliases = mapOf(
        "default" to "LauncherDefault",
        "calc" to "LauncherCalc",
        "cornhub" to "LauncherCornhub",
        "xxt" to "LauncherXxt",
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hvf/native").setMethodCallHandler { call, result ->
            when (call.method) {
                "setLauncherIcon" -> {
                    val name = call.argument<String>("name") ?: "default"
                    result.success(setLauncherIcon(name))
                }
                "excludeFromBackup" -> result.success(true)
                else -> result.notImplemented()
            }
        }
    }

    private fun setLauncherIcon(name: String): Boolean {
        val target = aliases[name] ?: return false
        val pm = packageManager
        // 先启用目标再停用其它，避免出现没有入口的瞬间
        aliases.values.sortedBy { if (it == target) 0 else 1 }.forEach { alias ->
            val state = if (alias == target) {
                PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            } else {
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            }
            pm.setComponentEnabledSetting(
                ComponentName(packageName, "$packageName.$alias"),
                state,
                PackageManager.DONT_KILL_APP,
            )
        }
        return true
    }
}
