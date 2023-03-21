//
//  ImageListUITests.swift
//  ImageListUITests
//
//  Created by Александр Зиновьев on 16.03.2023.
//

import XCTest

final class ImageListUITests: XCTestCase {
    private let app = XCUIApplication()
    
    private var password: String! = nil
    private var email: String! = nil
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["WebView"]
        webView.waitForExistence(timeout: 15)
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 15))
        loginTextField.tap()
        loginTextField.typeText(email)
        dismissKeyboardIfPresent()
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 15))
        passwordTextField.tap()
        passwordTextField.typeText(password)
        dismissKeyboardIfPresent()
        webView.swipeUp()
        webView.buttons["Login"].tap()
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 15))
    }
    
    func testList() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        let likeButton = cellToLike.buttons["likeButton"]
        sleep(3)
        likeButton.tap()
        sleep(3)
        likeButton.tap()
        
        
        cellToLike.tap()
        sleep(3)
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.4, velocity: -1)
        let backButton = app.buttons["backButton"].tap()
    }
    
    func testProfile() throws {
        sleep(2)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(5)

        XCTAssertTrue(app.staticTexts["nameLabel"].exists)
        XCTAssertTrue(app.staticTexts["emailLabel"].exists)
               
        app.buttons["exitButton"].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
    
    func dismissKeyboardIfPresent() {
        if app.keyboards.element(boundBy: 0).exists {
            app.toolbars.buttons["Done"].tap()
        }
    }
}
