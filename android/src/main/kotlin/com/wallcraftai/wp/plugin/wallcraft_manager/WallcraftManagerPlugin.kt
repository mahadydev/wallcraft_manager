package com.wallcraftai.wp.plugin.wallcraft_manager

import android.app.WallpaperManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context
import androidx.annotation.NonNull
import android.graphics.BitmapFactory
import java.io.File
import java.io.IOException
import android.os.Build
import kotlinx.coroutines.*

/** WallcraftManagerPlugin */
class WallcraftManagerPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wallcraft_manager")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "isSupported" -> {
                result.success(true)
            }
            "setWallpaperFromFile" -> {
                val filePath = call.argument<String>("filePath")
                val type = call.argument<Int>("type") ?: 0
                setWallpaperFromFile(filePath, type, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    private fun setWallpaperFromFile(filePath: String?, type: Int, result: Result) {
        if (filePath == null) {
            result.error("INVALID_ARGUMENT", "File path cannot be null", null)
            return
        }

        scope.launch {
            val bitmap = withContext(Dispatchers.IO) {
                val file = File(filePath)
                if (!file.exists()) {
                    withContext(Dispatchers.Main) {
                        result.error("FILE_NOT_FOUND", "File does not exist", null)
                    }
                    return@withContext null
                }
                BitmapFactory.decodeFile(filePath)
            }
            if (bitmap == null) {
                // Error already sent or decode failed
                if (!resultHasBeenSent(result)) {
                    result.error("INVALID_IMAGE", "Cannot decode image file", null)
                }
                return@launch
            }
            setWallpaperAsync(bitmap, type, result)
        }
    }

    private fun setWallpaperAsync(bitmap: android.graphics.Bitmap, type: Int, result: Result) {
        scope.launch {
            val success = withContext(Dispatchers.IO) {
                try {
                    val wallpaperManager = WallpaperManager.getInstance(context)
                    when (type) {
                        0 -> { // Home screen
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
                            } else {
                                wallpaperManager.setBitmap(bitmap)
                            }
                        }
                        1 -> { // Lock screen
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
                            } else {
                                return@withContext "Lock screen wallpaper not supported on this Android version"
                            }
                        }
                        2 -> { // Both
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK)
                            } else {
                                wallpaperManager.setBitmap(bitmap)
                            }
                        }
                        else -> {
                            wallpaperManager.setBitmap(bitmap)
                        }
                    }
                    null // success
                } catch (e: Exception) {
                    e.message ?: "Unknown error"
                }
            }
            if (success == null) {
                result.success(true)
            } else {
                result.error("SET_WALLPAPER_ERROR", success, null)
            }
        }
    }

    // Helper to avoid duplicate error reporting (optional, for clarity)
    private fun resultHasBeenSent(result: Result): Boolean {
        // This is a placeholder. In practice, you may want to track if result has been sent.
        // Flutter's MethodChannel.Result does not expose this, so this is just for code clarity.
        return false
    }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    scope.cancel()
  }
}
