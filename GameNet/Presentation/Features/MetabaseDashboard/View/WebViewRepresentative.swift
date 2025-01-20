//
//  WebViewRepresentative.swift
//  GameNet
//
//  Created by Alliston Aleixo on 19/12/24.
//

import SwiftUI
import WebKit

class WebArchiveDataManager {
    let webArchiveDirectoryURL: URL
    
    init() {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Unable to access document directory.")
        }
        
        webArchiveDirectoryURL = documentDirectory.appendingPathComponent("WebArchives")

        if !fileManager.fileExists(
            atPath: webArchiveDirectoryURL.path
        ) {
            try? fileManager.createDirectory(
                at: webArchiveDirectoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }

    func saveWebArchive(from webView: WKWebView, withName name: String) {
        webView.createWebArchiveData { result in
            switch result {
            case .success(let archiveData):
                let fileURL = self.webArchiveDirectoryURL.appendingPathComponent("\(name).webarchive")
                do {
                    try archiveData.write(to: fileURL)
                    print("Web archive saved at: \(fileURL.path)")
                } catch {
                    print("Error saving web archive: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("Error creating web archive data: \(error.localizedDescription)")
            }
        }
    }

    func loadWebArchive(named name: String, into webView: WKWebView) {
        let fileURL = self.webArchiveDirectoryURL.appendingPathComponent("\(name).webarchive")

        do {
            let archiveData = try Data(contentsOf: fileURL)
            webView.load(archiveData, mimeType: "application/x-webarchive", characterEncodingName: "", baseURL: fileURL)
            print("Web archive loaded from: \(fileURL.path)")
        } catch {
            print("Error loading web archive: \(error.localizedDescription)")
        }
    }
}

struct WebView: UIViewRepresentable {
    let webView: WKWebView
    let webArchiveDataManager: WebArchiveDataManager
    
    init() {
        webView = WKWebView(frame: .zero)
        webArchiveDataManager = WebArchiveDataManager()
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(webView, webArchiveDataManager: webArchiveDataManager)
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let url = URL(string: "http://192.168.0.2:3000/public/dashboard/4045df1b-f4cd-4460-84e6-39dcd883d593#theme=night")!

        let request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: TimeInterval(30)
        )
        
        Task {
            if let content = await urlIsReachable(request) {
                webView.loadHTMLString(content, baseURL: url)//.load(request)
            } else {
                webArchiveDataManager.loadWebArchive(named: "MetabaseDashboard", into: webView)
            }
        }
    }

    func urlIsReachable(_ request: URLRequest) async -> String? {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode{
                case 404:
                    return nil
                default:
                    if let string = String(data: data, encoding: .utf8) {
                        return string
                    }
                }
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WKWebView
        let webArchiveDataManager: WebArchiveDataManager

        init(_ parent: WKWebView, webArchiveDataManager: WebArchiveDataManager) {
            self.parent = parent
            self.webArchiveDataManager = webArchiveDataManager
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("WebView started loading")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView finished loading")

            webArchiveDataManager.saveWebArchive(from: parent, withName: "MetabaseDashboard")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("WebView failed with error: \(error)")

            webArchiveDataManager.loadWebArchive(named: "MetabaseDashboard", into: webView)
        }
    }
}
