//
//  Joystick.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class JoystickController;
@class JSAction;

@interface Joystick : NSObject {
	int vendorId;
	int productId;
    JoystickController *controller;
	int index;
	NSString* productName;
	IOHIDDeviceRef device;
	NSMutableArray* children;
	NSString* name;
}

@property(readwrite) int vendorId;
@property(readwrite) int productId;
@property(readwrite, copy) JoystickController* controller;
@property(readwrite) int index;
@property(readwrite, copy) NSString* productName;
@property(readwrite) IOHIDDeviceRef device;
@property(readonly) NSArray* children;
@property(readonly) NSString* name;

-(void) populateActions;
-(void) invalidate;
-(id) handlerForEvent: (IOHIDValueRef) value;
-(id)initWithDevice: (IOHIDDeviceRef) newDevice andController: (JoystickController*) controller;
-(JSAction*) actionForEvent: (IOHIDValueRef) value;

@end
