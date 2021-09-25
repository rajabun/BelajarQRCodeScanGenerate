//
//  ViewController.swift
//  BelajarQRCodeScanGenerate
//
//  Created by Muhammad Rajab Priharsanto on 03/09/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var infoMessage: UILabel!
    let folderName = "MyApp_ImageCaches"
    let imageName = "QrCode"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createFolderIfNeeded()
        getImageFromFileManager()
    }

    @IBAction func scanQrCodeButton(_ sender: UIButton) {
        goToQrCode()
    }
    
    @IBAction func generateQrCode(_ sender: UIButton) {
        let QRimage = generateQRCode(from: "https://www.tokopedia.com/popeyespetshop/british-shorthair-kucing-lilac-pedigree?whid=0")
        self.qrCodeImage.image = QRimage
    }
    
    @IBAction func saveQrCodeButton(_ sender: UIButton) {
        
        //save ke galeri
//        UIImageWriteToSavedPhotosAlbum(self.qrCodeImage.image ?? UIImage(), self, #selector(imageCompetionSelector(_:didFinishSavingWithError:contextInfo:)), nil)
        
        //share ke medsos atau platform lain atau save ke app files
        saveImage()
    }

    @IBAction func deleteImageButton(_ sender: UIButton) {
        deleteImageFromFileManager()
    }
    
    func goToQrCode() {
        let sampleStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let homeView  = sampleStoryBoard.instantiateViewController(withIdentifier: "ScannerViewController") as! ScannerViewController
        let navController = UINavigationController(rootViewController: homeView)
        navController.topViewController?.navigationItem.title = "Geser kebawah tulisan ini untuk kembali"
        self.present(navController, animated: true, completion: {
            
        })
    }
    
// sumber fungsi convert: https://stackoverflow.com/questions/48535524/uiimagewritetosavedphotosalbum-not-working
    private func convertCGImagetoUIImage(_ cmage:CIImage) -> UIImage? {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(cmage, from: cmage.extent) else { return nil }
        let image = UIImage(cgImage: cgImage)
        return image
    }
    
// sumber save image ke galeri (camera roll) : https://www.hackingwithswift.com/read/13/5/saving-to-the-ios-photo-library
    @objc func imageCompetionSelector(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

// sumber: https://www.hackingwithswift.com/example-code/media/how-to-create-a-qr-code
// sumber lain: https://medium.com/codex/qr-codes-are-simple-in-swift-6d203ebc3f5b
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 5, y: 5)

            if let output = filter.outputImage?.transformed(by: transform) {
                return convertCGImagetoUIImage(output)
            }
        }
        return nil
    }
    
// sumber save image ke files : https://www.hackingwithswift.com/example-code/media/how-to-save-a-uiimage-to-a-file-using-jpegdata-and-pngdata
    // sumber lain: https://programmingwithswift.com/how-to-save-image-to-file-with-swift/
    // sumber lain 2: https://stackoverflow.com/questions/50128462/how-to-save-document-to-files-app-in-swift
    
// sumber lain 3: https://www.youtube.com/watch?v=Yiq-hdhLzVM
    
    func newSaveImageToFiles(_ image: UIImage, _ name: String) -> String {
        guard
            let data = image.jpegData(compressionQuality: 1.0),
            let newPath = getPathForImage(name) else {
            return "Error getting data."
        }
        do {
            try data.write(to: newPath)
            shareToOtherPlatform(path: newPath)
            print(newPath)
            return "Success saving"
        } catch let error {
            return "Error saving \(error)"
        }
    }
    
    func saveImage() {
        guard let image = self.qrCodeImage.image else {return}
        infoMessage.text = newSaveImageToFiles(image, imageName)
    }
    
    func getPathForImage(_ name: String) -> URL? {
        guard let newPath = FileManager
                .default
                .urls(for: .cachesDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .appendingPathComponent("\(name).jpg") else {
            print("Error getting path.")
            return nil
        }
        return newPath
    }
    
    func getImage(_ name: String) -> UIImage? {
        guard
            let newPath = getPathForImage(name)?.path,
            FileManager.default.fileExists(atPath: newPath) else {
            print("Error getting path.")
            return nil
        }
        return UIImage(contentsOfFile: newPath)
    }
    
    func getImageFromFileManager() {
        qrCodeImage.image = getImage(imageName)
    }
    
    func deleteImage(_ name: String) -> String {
        guard
            let newPath = getPathForImage(name)?.path,
            FileManager.default.fileExists(atPath: newPath) else {
            return "Error getting path."
        }
        do {
            try FileManager.default.removeItem(atPath: newPath)
            return "Successfully deleted"
        } catch let error {
            return  "Error deleting image \(error)"
        }
    }
    
    func deleteImageFromFileManager() {
        infoMessage.text = deleteImage(imageName)
//        getImageFromFileManager()
    }
    
    func createFolderIfNeeded() {
        guard let path = FileManager
            .default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(folderName)
            .path else {return}
        
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                print("Successfully creating folder")
            } catch let error {
                print("Error creating folder \(error)")
            }
        }
    }
    
    func deleteFolder() {
        guard let path = FileManager
            .default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(folderName)
            .path else {return}
        
        do {
            try FileManager.default.removeItem(atPath: path)
            print("Successfully deleting folder")
        } catch let error {
            print("Error deleting folder \(error)")
        }
    }
    
    func shareToOtherPlatform(path: URL) {
//        let activityViewController = UIActivityViewController(activityItems: ["https://www.tokopedia.com/forgedstuff/msi-ps42-8rb-034id?whid=0", path], applicationActivities: nil)
        
        //kalo mau share foto ke whatsapp cuma bisa pathnya yang isinya gambar aja
        let activityViewController = UIActivityViewController(activityItems: [path], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

// Ubah warna background di QR Code : https://medium.com/@dominicfholmes/generating-qr-codes-in-swift-4-b5dacc75727c
