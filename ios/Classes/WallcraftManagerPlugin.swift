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
        result(false)
    }
    
    private func handleSetWallpaperFromFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "File path is required", details: nil))
            return
        }
        
        guard let imageData = NSData(contentsOfFile: filePath) else {
            result(FlutterError(code: "FILE_NOT_FOUND", message: "Could not read file at path: \(filePath)", details: nil))
            return
        }
        
        guard let image = UIImage(data: imageData as Data) else {
            result(FlutterError(code: "INVALID_IMAGE", message: "Could not decode image from file", details: nil))
            return
        }
        
        setWallpaperFromImage(image: image, result: result)
    }
    
    private func handleSetWallpaperFromBytes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let bytes = args["bytes"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Bytes data is required", details: nil))
            return
        }
        
        guard let image = UIImage(data: bytes.data) else {
            result(FlutterError(code: "INVALID_IMAGE", message: "Could not decode image from bytes", details: nil))
            return
        }
        
        setWallpaperFromImage(image: image, result: result)
    }
    
    private func setWallpaperFromImage(image: UIImage, result: @escaping FlutterResult) {
        // Since iOS doesn't support programmatic wallpaper setting,
        // we'll save the image to Photos and show instructions to the user
        saveImageToPhotos(image: image) { [weak self] success, error in
            if success {
                DispatchQueue.main.async {
                    self?.showWallpaperInstructions()
                }
                result(true)
            } else {
                let errorMessage = error?.localizedDescription ?? "Failed to save image to Photos"
                result(FlutterError(code: "SAVE_ERROR", message: errorMessage, details: nil))
            }
        }
    }
    
    private func handleSaveImageToGalleryFromFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let filePath = args["filePath"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "File path is required", details: nil))
            return
        }
        
        guard let imageData = NSData(contentsOfFile: filePath) else {
            result(FlutterError(code: "FILE_NOT_FOUND", message: "Could not read file at path: \(filePath)", details: nil))
            return
        }
        
        guard let image = UIImage(data: imageData as Data) else {
            result(FlutterError(code: "INVALID_IMAGE", message: "Could not decode image from file", details: nil))
            return
        }
        
        saveImageToPhotos(image: image) { success, error in
            if success {
                result(true)
            } else {
                let errorMessage = error?.localizedDescription ?? "Failed to save image to Photos"
                result(FlutterError(code: "SAVE_ERROR", message: errorMessage, details: nil))
            }
        }
    }
    
    private func handleSaveImageToGalleryFromBytes(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let bytes = args["bytes"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Bytes data is required", details: nil))
            return
        }
        
        guard let image = UIImage(data: bytes.data) else {
            result(FlutterError(code: "INVALID_IMAGE", message: "Could not decode image from bytes", details: nil))
            return
        }
        
        saveImageToPhotos(image: image) { success, error in
            if success {
                result(true)
            } else {
                let errorMessage = error?.localizedDescription ?? "Failed to save image to Photos"
                result(FlutterError(code: "SAVE_ERROR", message: errorMessage, details: nil))
            }
        }
    }
    
    private func saveImageToPhotos(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        // Check photo library permission
        let authStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authStatus {
        case .authorized:
            performSaveToPhotos(image: image, completion: completion)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.performSaveToPhotos(image: image, completion: completion)
                    } else {
                        completion(false, NSError(domain: "WallcraftManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Photo library permission denied"]))
                    }
                }
            }
        case .denied, .restricted:
            completion(false, NSError(domain: "WallcraftManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Photo library permission denied"]))
        case .limited:
            // iOS 14+ limited access - still try to save
            performSaveToPhotos(image: image, completion: completion)
        @unknown default:
            completion(false, NSError(domain: "WallcraftManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown photo library permission status"]))
        }
    }
    
    private func performSaveToPhotos(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        var assetIdentifier: String?
        
        PHPhotoLibrary.shared().performChanges({
            // Create the asset creation request
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: image.jpegData(compressionQuality: 0.9)!, options: nil)
            
            // Get the asset identifier
            assetIdentifier = creationRequest.placeholderForCreatedAsset?.localIdentifier
            
            // Try to add to Wallcraft album
            self.addToWallcraftAlbum(assetIdentifier: assetIdentifier)
            
        }) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    private func addToWallcraftAlbum(assetIdentifier: String?) {
        guard let assetIdentifier = assetIdentifier else { return }
        
        // Find or create Wallcraft album
        let albumName = "Wallcraft"
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let album = collection.firstObject {
            // Album exists, add photo to it
            addPhotoToAlbum(assetIdentifier: assetIdentifier, album: album)
        } else {
            // Create new album
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            }) { success, error in
                if success {
                    // Retry adding to the newly created album
                    let newCollection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                    if let newAlbum = newCollection.firstObject {
                        self.addPhotoToAlbum(assetIdentifier: assetIdentifier, album: newAlbum)
                    }
                }
            }
        }
    }
    
    private func addPhotoToAlbum(assetIdentifier: String, album: PHAssetCollection) {
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
        
        PHPhotoLibrary.shared().performChanges({
            if let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                albumChangeRequest.addAssets(asset)
            }
        }) { success, error in
            if let error = error {
                print("Error adding photo to Wallcraft album: \(error.localizedDescription)")
            }
        }
    }
    
    private func showWallpaperInstructions() {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(
            title: "Wallpaper Saved",
            message: "The image has been saved to your Photos. To set it as wallpaper:\n\n1. Open Settings app\n2. Go to Wallpaper\n3. Choose a New Wallpaper\n4. Select the saved image from Photos\n5. Set as Lock Screen, Home Screen, or Both",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        rootViewController.present(alert, animated: true)
    }
}