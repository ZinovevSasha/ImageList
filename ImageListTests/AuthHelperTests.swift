//
//  AuthHelperTests.swift
//  ImageListTests
//
//  Created by Александр Зиновьев on 07.03.2023.
//


import XCTest
@testable import ImageList

struct UnsplashConfigurationMockEmpty: AuthConfigurationProtocol {
    var accessKey: String = ""
    var secretKey: String = ""
    var redirectURI: String = ""
    var accessScope: String = ""
    var defaultBaseHost: String = ""
    var authorizeURLString: String = ""
    var tokenURLString: String = ""
}

final class AuthHelperTests: XCTestCase {
    func testAuthHelperGiveCorrectAuthURL() {
        // Given
        let configuration = UnsplashAuthConfiguration.standard
        let authHelper = AuthHelper(configuration, requestBuilder: RequestBuilder())
        
        // When
        
        let request = authHelper.authRequest()
        let url = request?.url
        guard let url = url else { return }
        let urlString = url.absoluteString
        
        // Then
        XCTAssertTrue(urlString.contains(configuration.authorizeURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
        XCTAssertTrue(urlString.contains("code"))
    }
    
    func testAuthHelperGiveCorrectTokenURL() {
        // Given
        let configuration = UnsplashAuthConfiguration.standard
        let authHelper = AuthHelper(configuration, requestBuilder: RequestBuilder())
        
        // When
        let request = authHelper.oAuthTokenRequest(code: "code")
        let url = request?.url
        guard let url = url else { return }
        let urlString = url.absoluteString
        
        // Then
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.secretKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("authorization_code"))
        XCTAssertTrue(urlString.contains("code"))
    }
    
    func testCodeFromURL() {
        // Given
        let authHelper = AuthHelper(UnsplashAuthConfiguration.standard, requestBuilder: RequestBuilder())
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")
        urlComponents?.queryItems = [
            URLQueryItem(name: "code", value: "lastCode")
        ]
        // When
        let code = authHelper.code(from: urlComponents?.url)
        guard let code = code else { return }
        
        // Then
        XCTAssertEqual(code, "lastCode")
    }
        
    func testGetHostAndPathFunctionForCorrectHostAndPath() {
        // Given
        let configuration = UnsplashAuthConfiguration.standard
        let authHelper = AuthHelper(configuration, requestBuilder: RequestBuilder())
        
        // When
        guard let request = authHelper.authRequest() else { return }
        guard let url = request.url?.absoluteString.components(separatedBy: "?") else { return }
        
        // Then
        if !url.isEmpty {
            XCTAssertEqual(url[0], configuration.authorizeURLString)
        }
    }
    
    func testGetHostAndPathFunctionIfNoURL() {
        // Given
        let configuration = UnsplashConfigurationMockEmpty()
        let authHelper = AuthHelper(configuration, requestBuilder: RequestBuilder())
        
        // When
        let request = authHelper.authRequest()
        let url = request?.url
        guard let url = url else { return }
        
        // Then
        XCTAssertNil(url)
    }
}
