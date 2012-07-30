//
//  TargetController.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class KeyInputTextView;
@class ConfigsController;
@class JoystickController;
@class Target;

@class TargetMouseMove;

@interface TargetController : NSObject {
	IBOutlet KeyInputTextView* keyInput;
	IBOutlet NSButtonCell *radioNoAction, *radioKey, *radioConfig;
	IBOutlet NSMatrix* radioButtons;
    IBOutlet NSSegmentedControl* mouseDirSelect;
    IBOutlet NSSegmentedControl* mouseBtnSelect;
    IBOutlet NSSegmentedControl* scrollDirSelect;
	IBOutlet NSTextField* title;
	IBOutlet NSPopUpButton* configPopup;
	IBOutlet ConfigsController* configsController;
	IBOutlet JoystickController* joystickController;
	id currentJsaction;
}

-(void) keyChanged;
-(void) load;
-(void) commit;
-(void) reset;
-(Target*) state;
-(void) refreshConfigsPreservingSelection: (BOOL) preserve;
-(IBAction)configChosen:(id)sender;
-(IBAction)radioChanged:(id)sender;
-(IBAction)mdirChanged:(id)sender;
-(IBAction)mbtnChanged:(id)sender;
-(IBAction)sdirChanged:(id)sender;
-(void) focusKey;

@property(readwrite) BOOL enabled;

@end
