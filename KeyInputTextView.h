//
//  KeyInputTextField.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class TargetController;

@interface KeyInputTextView: NSTextView {
	IBOutlet NSWindow* window;
	IBOutlet TargetController* targetController;
	BOOL hasKey;
	int vk;
	NSString* descr;
	BOOL enabled;
}

@property(readonly) BOOL hasKey;
@property(readwrite) int vk;
@property(readonly) NSString* descr;
@property(readwrite) BOOL enabled;

-(void) clear;

@end
