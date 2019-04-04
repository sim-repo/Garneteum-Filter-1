//
//  MvvMcoordUITests.swift
//  MvvMcoordUITests
//
//  Created by Igor Ivanov on 19/02/2019.
//  Copyright © 2019 Igor Ivanov. All rights reserved.
//

import XCTest

class MvvMcoordUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let app = XCUIApplication()
        
        for _ in 0...1000 {
        let my1StaticText = app.navigationBars["Каталог"]/*@START_MENU_TOKEN@*/.staticTexts["My1"]/*[[".staticTexts[\"Каталог\"]",".staticTexts[\"My1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        my1StaticText.tap()
        
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Женщинам"]/*[[".cells.staticTexts[\"Женщинам\"]",".staticTexts[\"Женщинам\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(1)
        let navigationBar2 = app.navigationBars["Женщинам"]
        let my2StaticText = navigationBar2/*@START_MENU_TOKEN@*/.staticTexts["My2"]/*[[".staticTexts[\"Женщинам\"]",".staticTexts[\"My2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        my2StaticText.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Одежда"]/*[[".cells.staticTexts[\"Одежда\"]",".staticTexts[\"Одежда\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        sleep(1)
        let navigationBar3 = app.navigationBars["Одежда"]
        let my3StaticText = navigationBar3/*@START_MENU_TOKEN@*/.staticTexts["My3"]/*[[".staticTexts[\"Одежда\"]",".staticTexts[\"My3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        my3StaticText.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Платья"]/*[[".cells.staticTexts[\"Платья\"]",".staticTexts[\"Платья\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        sleep(1)
        let navigationBar4 = app.navigationBars["Платья"]
        let my4StaticText = navigationBar4/*@START_MENU_TOKEN@*/.staticTexts["My4"]/*[[".staticTexts[\"Платья\"]",".staticTexts[\"My4\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        my4StaticText.tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Повседневные Платья"]/*[[".cells.staticTexts[\"Повседневные Платья\"]",".staticTexts[\"Повседневные Платья\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        sleep(2)
        let navigationBar5 = app.navigationBars["Повседневные Платья"]
        let my5StaticText = navigationBar5/*@START_MENU_TOKEN@*/.staticTexts["My5"]/*[[".staticTexts[\"Повседневные Платья\"]",".staticTexts[\"My5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        my5StaticText.tap()
        app.buttons["Фильтр"].tap()
        
        sleep(2)
        let navigationBar = app.navigationBars["Фильтры"]
        let my6StaticText = navigationBar/*@START_MENU_TOKEN@*/.staticTexts["My6"]/*[[".staticTexts[\"Фильтры\"]",".staticTexts[\"My6\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        my6StaticText.tap()
        
        sleep(2)
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Состав"]/*[[".cells.staticTexts[\"Состав\"]",".staticTexts[\"Состав\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        navigationBar/*@START_MENU_TOKEN@*/.staticTexts["My7"]/*[[".staticTexts[\"Фильтры\"]",".staticTexts[\"My7\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let backButton = navigationBar.buttons["Back"]
        backButton.tap()
        
        sleep(1)
        my6StaticText.tap()
        sleep(1)
        backButton.tap()
        sleep(1)
        my5StaticText.tap()
        sleep(1)
        navigationBar5.buttons["Back"].tap()
        sleep(1)
        my4StaticText.tap()
        sleep(1)
        navigationBar4.buttons["Back"].tap()
        sleep(1)
        my3StaticText.tap()
        sleep(1)
        navigationBar3.buttons["Back"].tap()
        sleep(1)
        my2StaticText.tap()
        sleep(1)
        navigationBar2.buttons["Back"].tap()
        sleep(1)
        my1StaticText.tap()
        }
    }
    
    
    func testExample2() {
        
    }

}
