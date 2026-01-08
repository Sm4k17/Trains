//
//  UserAgreementView.swift
//  Trains
//
//  Created by Рустам Ханахмедов on 06.01.2026.
//

import SwiftUI
import WebKit

struct UserAgreementView: UIViewRepresentable {
    let url: URL
    @Environment(\.colorScheme) private var scheme
    
    func makeCoordinator() -> AgreementWebCoordinator {
        AgreementWebCoordinator()
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        let web = WKWebView(frame: .zero, configuration: cfg)
        web.navigationDelegate = context.coordinator
        web.scrollView.contentInsetAdjustmentBehavior = .never
        web.allowsBackForwardNavigationGestures = true
        web.isOpaque = false
        web.backgroundColor = .systemBackground
        web.scrollView.backgroundColor = .systemBackground
        
        if #available(iOS 13.0, *) {
            web.overrideUserInterfaceStyle = (scheme == .dark) ? .dark : .light
        }
        context.coordinator.isDark = (scheme == .dark)
        
        web.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData))
        return web
    }
    
    func updateUIView(_ web: WKWebView, context: Context) {
        context.coordinator.isDark = (scheme == .dark)
        if #available(iOS 13.0, *) {
            web.overrideUserInterfaceStyle = (scheme == .dark) ? .dark : .light
        }
        context.coordinator.applyDarkCSS(to: web)
    }
    
    final class AgreementWebCoordinator: NSObject, WKNavigationDelegate {
        var isDark: Bool = false
        
        func applyDarkCSS(to webView: WKWebView) {
            let javaScript = """
            (function(){
              var s = document.getElementById('app-dark-css');
              if(!s){ s = document.createElement('style'); s.id='app-dark-css'; document.head.appendChild(s); }
              if(\(isDark ? "true" : "false")){
                s.textContent = `html{filter:invert(1) hue-rotate(180deg);background:#0B0C0E!important}
                                 html,body{color-scheme:dark}
                                 img,video,picture,canvas,svg{filter:invert(1) hue-rotate(180deg)!important}
                                 a{color:#4C8DFF!important}`;
              } else { s.textContent = ''; }
            })();
            """
            webView.evaluateJavaScript(javaScript, completionHandler: nil)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            applyDarkCSS(to: webView)
        }
    }
}

struct UserAgreementWebScreen: View {
    @Environment(\.dismiss) private var dismiss
    private let urlString = "https://yandex.ru/legal/timetable_termsofuse/ru/"
    
    var body: some View {
        Group {
            if let url = URL(string: urlString) {
                UserAgreementView(url: url)
                    .ignoresSafeArea(edges: .bottom)
            } else {
                Text("Не удалось загрузить соглашение")
                    .foregroundColor(.ypBlack)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton { dismiss() }
            }
            ToolbarItem(placement: .principal) {
                Text("Пользовательское соглашение")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.ypBlack)
            }
        }
    }
}
