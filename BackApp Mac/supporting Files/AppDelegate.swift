//
//  AppDelegate.swift
//  BackApp Mac
//
//  Created by Moritz Schaub on 13.05.20.
//  Copyright © 2020 Moritz Schaub. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    var window: NSWindow!
    
    let recipeStore = RecipeStore()


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView().environmentObject(self.recipeStore)

        // Create the window and set the content view. 
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
        window.delegate = self
    }

    func windowWillClose(_ notification: Notification) {
        //save file
        recipeStore.write()
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        
        
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        //load file
        if let recipes: [Recipe] = recipeStore.load(){
            recipeStore.recipes = recipes
        }
    }
    
    func applicationWillHide(_ notification: Notification) {
        
    }
    
    func applicationWillUnhide(_ notification: Notification) {
        
    }

}

