//
//  ViewController.swift
//  APPlainAlertSwift
//
//  Created by Parti Albert on 2024. 12. 05..
//
import UIKit

class ViewController: UIViewController, APPlainAlertDelegate, URLSessionDownloadDelegate {

    
    var progressAlert: APPlainAlert?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Alapértelmezett pozíció frissítése
        APPlainAlert.updateAlertPosition(.top)
    }

    @IBAction func successAlert(_ sender: UIButton) {
        let alert = APPlainAlert(title: "Success!!!!", message: "Something works! Lorem ipsum!", type: .success)
        alert.messageColor = .green
        alert.show()
    }

    @IBAction func infoAlert(_ sender: UIButton) {
        let alert = APPlainAlert(title: "Info", message: "This is an info message.", type: .info)
        alert.messageColor = .blue
        alert.iconColor = .cyan
        alert.shouldShowCloseIcon = true
        alert.delegate = self
        alert.hiddenDelay = 5.0
        alert.show()
    }

    @IBAction func failureAlert(_ sender: UIButton) {
        let alert = APPlainAlert(title: "Failure", message: "Operation was unsuccessful.", type: .error)
        alert.messageColor = .red
        alert.closeButtonColor = .systemBlue
        alert.titleFont = .systemFont(ofSize: 24)
        alert.subTitleFont = .systemFont(ofSize: 16)
        alert.titleColor = .white // Címsor színének beállítása fehérre
        alert.subtitleColor = .yellow // Alszöveg színének beállítása sárgára
        alert.show()
    }

    @IBAction func progressAlert(_ sender: UIButton) {
        progressAlert = APPlainAlert(title: "Downloading...", message: "Please wait.", type: .progress)
        progressAlert?.messageColor = .yellow
        progressAlert?.hiddenDelay = 100.0
        progressAlert?.delegate = self
        progressAlert?.show()

        downloadFile()
    }
    
    @IBAction func infoWithSafari(_ sender: Any) {
        let alert = APPlainAlert(title: "Hmm...", message: "Tap for information", type: .info)
        alert.action = {
            if let url = URL(string: "https://appsyscode.com"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alert.messageColor = .purple
        alert.show()
    }


    @IBAction func panicAlert(_ sender: UIButton) {
        let alert = APPlainAlert(title: "Panic!", message: "Something broke!", type: .panic)
        alert.messageColor = .orange
        alert.show()
    }

    @IBAction func hideAllAlerts(_ sender: UIButton) {
        APPlainAlert.hideAll()
    }

    func progressStatus(_ floatCount: Float) {
        print("Progressss: \(floatCount)%")
        progressAlert?.progressView(progress: floatCount / 100, status: "\(Int(floatCount))%")
        if floatCount == 100 {
            progressAlert?.hidedelayprogress()
        }
    }

    func closeButtonAction() {
        print("Close button tapped!")
    }

    func downloadFile() {
        guard let url = URL(string: "http://ipv4.download.thinkbroadband.com/50MB.zip") else { return }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        let task = session.downloadTask(with: url)
        task.resume()
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) * 100
        progressStatus(progress)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Download failed: \(error.localizedDescription)")
        } else {
            print("Download successful!")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default

        // Dokumentumok könyvtár elérése, ahol a fájlt meg szeretnéd őrizni
        let documentsDirectoryURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let destinationURL = documentsDirectoryURL.appendingPathComponent(downloadTask.response?.suggestedFilename ?? "downloadedFile")

        do {
            // Ha a célhelyen már van ilyen fájl, töröljük
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            // Mozgatjuk a fájlt az ideiglenes helyről a célhelyre
            try fileManager.moveItem(at: location, to: destinationURL)
            print("Fájl letöltve: \(destinationURL.path)")
        } catch {
            print("Hiba történt a fájl áthelyezésekor: \(error)")
        }
    }

}
