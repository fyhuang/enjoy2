//
//  ApplicationController.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class JoystickController;
@class TargetController;
@class ConfigsController;

@interface ApplicationController : NSObject {
	IBOutlet JoystickController *jsController;
	IBOutlet TargetController *targetController;
	IBOutlet ConfigsController *configsController;
	
	IBOutlet NSDrawer *drawer;
	IBOutlet NSWindow *mainWindow;
	IBOutlet NSToolbarItem* activeButton;
	IBOutlet NSMenuItem* activeMenuItem;
	IBOutlet NSMenu* dockMenuBase;
}

@property(readwrite) BOOL active;
@property(readonly) JoystickController * jsController;
@property(readonly) TargetController * targetController;
@property(readonly) ConfigsController * configsController;
-(IBAction) toggleActivity: (id)sender;
-(void) configsChanged;
-(void) configChanged;

@end
