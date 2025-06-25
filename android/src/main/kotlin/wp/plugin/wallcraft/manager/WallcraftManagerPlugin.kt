package wp.plugin.wallcraft.manager

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
import android.util.Log
import java.util.concurrent.atomic.AtomicBoolean

/** WallcraftManagerPlugin */
class WallcraftManagerPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "wallcraft_manager")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        val resultSent = AtomicBoolean(false)
        try {
            when (call.method) {
                "isSupported" -> handleIsSupported(result, resultSent)
                "setWallpaperFromFile" -> handleSetWallpaperFromFile(call, result, resultSent)
                "setWallpaperFromBytes" -> handleSetWallpaperFromBytes(call, result, resultSent)
                "saveImageToGalleryFromFile" -> handleSaveImageToGalleryFromFile(call, result, resultSent)
                "saveImageToGalleryFromBytes" -> handleSaveImageToGalleryFromBytes(call, result, resultSent)
                else -> sendResultOnce(resultSent) { result.notImplemented() }
            }
        } catch (e: Exception) {
            logAndSendError("Exception in onMethodCall", e, result, resultSent, "UNEXPECTED_ERROR")
        }
    }

    private fun handleIsSupported(result: Result, resultSent: AtomicBoolean) =
        sendResultOnce(resultSent) { result.success(true) }

    private fun handleSetWallpaperFromFile(call: MethodCall, result: Result, resultSent: AtomicBoolean) {
        val filePath = call.argument<String>("filePath")
        val type = call.argument<Int>("type") ?: 0
        if (!validateType(type, result, resultSent)) return
        if (!validateFilePath(filePath, result, resultSent)) return
        setWallpaperFromFile(filePath!!, type, result, resultSent)
    }

    private fun handleSetWallpaperFromBytes(call: MethodCall, result: Result, resultSent: AtomicBoolean) {
        val bytes = call.argument<ByteArray>("bytes")
        val type = call.argument<Int>("type") ?: 0
        if (!validateType(type, result, resultSent)) return
        if (bytes == null || bytes.isEmpty()) {
            logAndSendError("Bytes cannot be null or empty", null, result, resultSent, "INVALID_ARGUMENT")
            return
        }
        setWallpaperFromBytes(bytes, type, result, resultSent)
    }

    private fun handleSaveImageToGalleryFromFile(call: MethodCall, result: Result, resultSent: AtomicBoolean) {
        val filePath = call.argument<String>("filePath")
        val fileName = call.argument<String>("fileName") ?: "wallcraft_${System.currentTimeMillis()}.jpg"
        if (filePath.isNullOrEmpty()) {
            logAndSendError("File path cannot be null or empty", null, result, resultSent, "INVALID_ARGUMENT")
            return
        }
        val file = File(filePath)
        if (!file.exists() || !file.canRead()) {
            logAndSendError("File does not exist or cannot be read: $filePath", null, result, resultSent, "FILE_NOT_FOUND")
            return
        }
        val bytes = file.readBytes()
        saveImageToGallery(bytes, fileName, result, resultSent)
    }

    private fun handleSaveImageToGalleryFromBytes(call: MethodCall, result: Result, resultSent: AtomicBoolean) {
        val bytes = call.argument<ByteArray>("bytes")
        val fileName = call.argument<String>("fileName") ?: "wallcraft_${System.currentTimeMillis()}.jpg"
        if (bytes == null || bytes.isEmpty()) {
            logAndSendError("Bytes cannot be null or empty", null, result, resultSent, "INVALID_ARGUMENT")
            return
        }
        saveImageToGallery(bytes, fileName, result, resultSent)
    }

    private fun validateType(type: Int, result: Result, resultSent: AtomicBoolean): Boolean {
        if (type !in 0..2) {
            logAndSendError("Invalid wallpaper type: $type", null, result, resultSent, "INVALID_TYPE", "Type must be 0 (home), 1 (lock), or 2 (both)")
            return false
        }
        return true
    }

    private fun validateFilePath(filePath: String?, result: Result, resultSent: AtomicBoolean): Boolean {
        if (filePath == null) {
            logAndSendError("File path cannot be null", null, result, resultSent, "INVALID_ARGUMENT")
            return false
        }
        val file = File(filePath)
        if (!file.canRead()) {
            logAndSendError("No read permission for file: $filePath", null, result, resultSent, "PERMISSION_DENIED", "No read permission for file")
            return false
        }
        return true
    }

    private fun setWallpaperFromFile(filePath: String, type: Int, result: Result, resultSent: AtomicBoolean) {
        val file = File(filePath)
        val handler = CoroutineExceptionHandler { _, exception ->
            logAndSendError("Coroutine exception", exception, result, resultSent, "COROUTINE_ERROR")
        }
        scope.launch(handler) {
            val bitmap = withContext(Dispatchers.IO) {
                if (!file.exists()) {
                    withContext(Dispatchers.Main) {
                        logAndSendError("File does not exist: $filePath", null, result, resultSent, "FILE_NOT_FOUND")
                    }
                    return@withContext null
                }
                BitmapFactory.decodeFile(filePath)
            }
            if (bitmap == null) {
                logAndSendError("Cannot decode image file: $filePath", null, result, resultSent, "INVALID_IMAGE")
                return@launch
            }
            setWallpaperAsync(bitmap, type, result, resultSent)
        }
    }

    private fun setWallpaperFromBytes(bytes: ByteArray, type: Int, result: Result, resultSent: AtomicBoolean) {
        val handler = CoroutineExceptionHandler { _, exception ->
            logAndSendError("Coroutine exception", exception, result, resultSent, "COROUTINE_ERROR")
        }
        scope.launch(handler) {
            val bitmap = withContext(Dispatchers.IO) {
                try {
                    BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
                } catch (e: Exception) {
                    Log.e("WallcraftManager", "Error decoding bytes: ${e.message}", e)
                    null
                }
            }
            if (bitmap == null) {
                logAndSendError("Cannot decode image from bytes", null, result, resultSent, "INVALID_IMAGE")
                return@launch
            }
            setWallpaperAsync(bitmap, type, result, resultSent)
        }
    }

    private fun setWallpaperAsync(bitmap: android.graphics.Bitmap, type: Int, result: Result, resultSent: AtomicBoolean) {
        scope.launch {
            val success = withContext(Dispatchers.IO) {
                try {
                    val wallpaperManager = WallpaperManager.getInstance(context)
                    when (type) {
                        0 -> setHomeWallpaper(wallpaperManager, bitmap)
                        1 -> setLockWallpaper(wallpaperManager, bitmap)
                        2 -> setBothWallpapers(wallpaperManager, bitmap)
                        else -> wallpaperManager.setBitmap(bitmap)
                    }
                    null // success
                } catch (e: Exception) {
                    Log.e("WallcraftManager", "Error setting wallpaper: ${e.message}", e)
                    e.message ?: "Unknown error"
                }
            }
            if (success == null) {
                sendResultOnce(resultSent) { result.success(true) }
            } else {
                logAndSendError("Wallpaper set error: $success", null, result, resultSent, "SET_WALLPAPER_ERROR", success)
            }
            try {
                bitmap.recycle()
            } catch (e: Exception) {
                Log.w("WallcraftManager", "Failed to recycle bitmap: ${e.message}")
            }
        }
    }

    private fun setHomeWallpaper(wallpaperManager: WallpaperManager, bitmap: android.graphics.Bitmap) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
        } else {
            wallpaperManager.setBitmap(bitmap)
        }
    }

    private fun setLockWallpaper(wallpaperManager: WallpaperManager, bitmap: android.graphics.Bitmap): String? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
            null
        } else {
            "Lock screen wallpaper not supported on this Android version"
        }
    }

    private fun setBothWallpapers(wallpaperManager: WallpaperManager, bitmap: android.graphics.Bitmap) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK)
        } else {
            wallpaperManager.setBitmap(bitmap)
        }
    }

    private fun logAndSendError(
        logMsg: String,
        exception: Throwable?,
        result: Result,
        resultSent: AtomicBoolean,
        code: String,
        details: String? = null
    ) {
        if (exception != null) {
            Log.e("WallcraftManager", "$logMsg: ${exception.message}", exception)
        } else {
            Log.e("WallcraftManager", logMsg)
        }
        sendResultOnce(resultSent) { result.error(code, logMsg, details) }
    }

    private inline fun sendResultOnce(resultSent: AtomicBoolean, block: () -> Unit) {
        if (resultSent.compareAndSet(false, true)) {
            block()
        }
    }

    private fun saveImageToGallery(bytes: ByteArray, fileName: String, result: Result, resultSent: AtomicBoolean) {
        scope.launch {
            val success = withContext(Dispatchers.IO) {
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        // Android 10+ (Q): Use MediaStore
                        val resolver = context.contentResolver
                        val contentValues = android.content.ContentValues().apply {
                            put(android.provider.MediaStore.Images.Media.DISPLAY_NAME, fileName)
                            put(android.provider.MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                            put(android.provider.MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Wallcraft")
                            put(android.provider.MediaStore.Images.Media.IS_PENDING, 1)
                        }
                        val uri = resolver.insert(android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                        if (uri != null) {
                            resolver.openOutputStream(uri)?.use { it.write(bytes) }
                            contentValues.clear()
                            contentValues.put(android.provider.MediaStore.Images.Media.IS_PENDING, 0)
                            resolver.update(uri, contentValues, null, null)
                            return@withContext true
                        }
                    } else {
                        // Android < 10: Write to Pictures directory and scan
                        val picturesDir = android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_PICTURES)
                        val wallcraftDir = File(picturesDir, "Wallcraft")
                        if (!wallcraftDir.exists()) {
                            val created = wallcraftDir.mkdirs()
                            if (!created) {
                                Log.e("WallcraftManager", "Failed to create directory: ${wallcraftDir.absolutePath}")
                                return@withContext false
                            }
                        }
                        val file = File(wallcraftDir, fileName)
                        file.writeBytes(bytes)
                        // Scan file so it appears in gallery
                        val intent = android.content.Intent(android.content.Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
                        intent.data = android.net.Uri.fromFile(file)
                        context.sendBroadcast(intent)
                        return@withContext true
                    }
                } catch (e: Exception) {
                    Log.e("WallcraftManager", "Error saving image to gallery: ${e.message}", e)
                }
                return@withContext false
            }
            if (success) {
                sendResultOnce(resultSent) { result.success(true) }
            } else {
                logAndSendError("Failed to save image to gallery", null, result, resultSent, "SAVE_ERROR")
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        scope.cancel()
    }
}
