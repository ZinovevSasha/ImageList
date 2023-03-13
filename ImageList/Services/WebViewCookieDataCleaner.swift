//
//  WebViewCookieDataCleaner.swift
//  ImageList
//
//  Created by Александр Зиновьев on 13.03.2023.
//

import WebKit

protocol WebViewCookieDataCleanerProtocol {
    func clean()
}

final class WebViewCookieDataCleaner: WebViewCookieDataCleanerProtocol {
    func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record]) {}
            }
        }
    }
}
