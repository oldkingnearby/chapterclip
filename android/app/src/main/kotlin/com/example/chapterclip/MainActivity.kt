package com.example.chapterclip

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "chapterclip/app_update"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppVersionInfo" -> {
                    result.success(
                        mapOf(
                            "version" to BuildConfig.VERSION_NAME,
                            "buildNumber" to BuildConfig.VERSION_CODE,
                        )
                    )
                }

                "installApk" -> {
                    val path = call.argument<String>("path")
                    if (path.isNullOrBlank()) {
                        result.error("invalid_args", "APK path is required", null)
                        return@setMethodCallHandler
                    }

                    try {
                        installApk(path)
                        result.success(true)
                    } catch (error: Exception) {
                        result.error(
                            "install_failed",
                            error.message ?: "Failed to open the installer",
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun installApk(path: String) {
        val file = File(path)
        require(file.exists()) { "Downloaded APK was not found" }

        val authority = "${BuildConfig.APPLICATION_ID}.fileprovider"
        val uri = FileProvider.getUriForFile(this, authority, file)
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/vnd.android.package-archive")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        startActivity(intent)
    }
}
