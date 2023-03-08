//
//  ImageListTests.swift
//  ImageListTests
//
//  Created by Александр Зиновьев on 07.03.2023.
//

import XCTest
@testable import ImageList

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var loadRequestCalled = false
    var progressValue: Float = 0.0
    var isProgressValueHiden = false
    
    
    var presenter: ImageList.WebViewViewPresenterProtocol
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    func setProgressValue(_ newValue: Float) {
        progressValue = newValue
    }
    func setProgressHidden(_ isHiden: Bool) {
        isProgressValueHiden = isHiden
    }
    
    init(presenter: ImageList.WebViewViewPresenterProtocol) {
        self.presenter = presenter
    }
}

final class WebViewPresenterSpy: WebViewViewPresenterProtocol {
    var viewDidLoadCalled = false
    
    var view: ImageList.WebViewViewControllerProtocol?
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func code(from url: URL?) -> String? {
        return nil
    }
    
    func didUpdateProgressValue(_ newValue: Double) { }
}

struct AuthHelperMock: AuthHelperProtocol {
    func authRequest() -> URLRequest? {
        URLRequest(url: URL(string: "https://unsplash.com/")!)
    }
    
    func code(from url: URL?) -> String? {
        nil
    }
}

final class WebViewTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        // Given
        let webViewPresenterSpy = WebViewPresenterSpy()
        let webViewController = WebViewViewController(delegate: nil)
        webViewController.presenter = webViewPresenterSpy
        webViewPresenterSpy.view = webViewController
        
        // When
        _ = webViewController.view
        
        // Then
        XCTAssertTrue(webViewPresenterSpy.viewDidLoadCalled)
    }
    
    func testPresenterCallsViewLoadRequest() {
        // Given
        let authHelperMock = AuthHelperMock()
        let presenter = WebViewViewPresenter(view: nil, authHelper: AuthHelperMock())
        let webViewController = WebViewViewControllerSpy(presenter: presenter)
        presenter.view = webViewController
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(webViewController.loadRequestCalled)
    }
    
    func testSetProgressValueIsCalled() {
        // Given
        let authHelperMock = AuthHelperMock()
        let presenter = WebViewViewPresenter(view: nil, authHelper: AuthHelperMock())
        let webViewController = WebViewViewControllerSpy(presenter: presenter)
        presenter.view = webViewController
        
        // When
        presenter.didUpdateProgressValue(0.8)
        
        // Then
        XCTAssertEqual(webViewController.progressValue, 0.8)
    }
    
    func testDidUpdateProgressValue() {
        // Given
        let authHelperMock = AuthHelperMock()
        let presenter = WebViewViewPresenter(view: nil, authHelper: AuthHelperMock())
        let webViewController = WebViewViewControllerSpy(presenter: presenter)
        presenter.view = webViewController
        
        // When progress more or equal to 0.745 it must disappear
        presenter.didUpdateProgressValue(0.745)
        
        // Then
        XCTAssertTrue(webViewController.isProgressValueHiden)
    }
}
