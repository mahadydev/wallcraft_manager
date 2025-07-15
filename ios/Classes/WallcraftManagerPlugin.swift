import Flutter
import UIKit
import Photos

public class WallcraftManagerPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "wallcraft_manager", binaryMessenger: registrar.messenger())
        let instance = WallcraftManagerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isSupported":
            handleIsSupported(result: result)
        case "setWallpaperFromFile":
            handleSetWallpaperFromFile(call: call, result: result)
        case "setWallpaperFromBytes":
            handleSetWallpaperFromBytes(call: call, result: result)
        case "saveImageToGalleryFromFile":
            handleSaveImageToGalleryFromFile(call: call, result: result)
        case "saveImageToGalleryFromBytes":
            handleSaveImageToGalleryFromBytes(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleIsSupported(result: @escaping FlutterResult) {
        // iOS doesn't support programmatic wallpaper setting
        // Only saving to Photos and manual setting by user
        result(false)
    }
    
    private func handleSetWallpaperFromFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "File path is required", details: nil))
            return
        }
        
        // iOS doesn't support programmatic wallpaper setting
        // Redirect to save to Photos instead
        saveImageToPhotos(filePath: filePath) { success, error in
            if let error = error {
                result(FlutterError(code: "SAVE_ERROR", message: error.localizedDescription, details: nil))
            } else {
                // Show alert to user about manual setting
                DispatchQueue.main.async {
                    self.showWallpaperInstructions()
                }
                result(success)
            }
        }
    }
    
    private func handleSetWallpaperFromBytes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let bytes = args["bytes"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Bytes are required", details: nil))
            return
        }
        
        // iOS doesn't support programmatic wallpaper setting
        // Redirect to save to Photos instead
        saveImageToPhotos(imageData: bytes.data) { success, error in
            if let error = error {
                result(FlutterError(code: "SAVE_ERROR", message: error.localizedDescription, details: nil))
            } else {
                // Show alert to user about manual setting
                DispatchQueue.main.async {
                    self.showWallpaperInstructions()
                }
                result(success)
            }
        }
    }
    
    private func handleSaveImageToGalleryFromFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "File path is required", details: nil))
            return
        }
        
        saveImageToPhotos(filePath: filePath) { success, error in
            if let error = error {
                result(FlutterError(code: "SAVE_ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(success)
            }
        }
    }
    
    private func handleSaveImageToGalleryFromBytes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let bytes = args["bytes"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Bytes are required", details: nil))
            return
        }
        
        saveImageToPhotos(imageData: bytes.data) { success, error in
            if let error = error {
                result(FlutterError(code: "SAVE_ERROR", message: error.localizedDescription, details: nil))
            } else {
                result(success)
            }
        }
    }
    
    private func saveImageToPhotos(filePath: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let image = UIImage(contentsOfFile: filePath) else {
            completion(false, NSError(domain: "WallcraftManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image file"]))
            return
        }
        
        saveImageToPhotos(image: image, completion: completion)
    }
    
    private func saveImageToPhotos(imageData: Data, completion: @escaping (Bool, Error?) -> Void) {
        guard let image = UIImage(data: imageData) else {
            completion(false, NSError(domain: "WallcraftManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"]))
            return
        }
        
        saveImageToPhotos(image: image, completion: completion)
    }
    
    private func saveImageToPhotos(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        // Check Photos permission
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            performSaveToPhotos(image: image, completion: completion)
        case .denied, .restricted:
            completion(false, NSError(domain: "WallcraftManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Photos access denied"]))
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    self.performSaveToPhotos(image: image, completion: completion)
                } else {
                    completion(false, NSError(domain: "WallcraftManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Photos access denied"]))
                }
            }
        @unknown default:
            completion(false, NSError(domain: "WallcraftManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown authorization status"]))
        }
    }
    
    private func performSaveToPhotos(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCreationRequest.forAsset()
            request.addResource(with: .photo, data: image.jpegData(compressionQuality: 0.9)!, options: nil)
            
            // Create album if it doesn't exist
            let albumName = "Wallcraft"
            let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            
            var albumExists = false
            collections.enumerateObjects { collection, _, _ in
                if collection.localizedTitle == albumName {
                    albumExists = true
                    // Add to existing album
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: collection) {
                        albumChangeRequest.addAssets([request.placeholderForCreatedAsset!] as NSArray)
                    }
                }
            }
            
            if !albumExists {
                // Create new album
                let albumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumRequest.addAssets([request.placeholderForCreatedAsset!] as NSArray)
            }
            
        }) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    private func showWallpaperInstructions() {
        guard let topViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(
            title: "Wallpaper Saved",
            message: "The image has been saved to your Photos. To set it as wallpaper:\n\n1. Open Settings app\n2. Go to Wallpaper\n3. Choose a New Wallpaper\n4. Select the saved image from Photos\n5. Set as Lock Screen, Home Screen, or Both",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        topViewController.present(alert, animated: true)
    }
}