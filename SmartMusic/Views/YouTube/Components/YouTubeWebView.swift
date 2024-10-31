import SwiftUI
import WebKit

struct YouTubeWebView: UIViewRepresentable {
    let videoId: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.configuration.allowsInlineMediaPlayback = true
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // YouTube 嵌入播放器 HTML
        let embedHTML = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                body { margin: 0; background-color: black; }
                .video-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; }
                .video-container iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe width="100%" height="100%"
                    src="https://www.youtube.com/embed/\(videoId)?playsinline=1&autoplay=1"
                    frameborder="0"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowfullscreen>
                </iframe>
            </div>
        </body>
        </html>
        """
        
        webView.loadHTMLString(embedHTML, baseURL: nil)
    }
} 