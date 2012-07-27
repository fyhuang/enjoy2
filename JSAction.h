//
//  JSAction.h
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hid/IOHIDLib.h>

@interface JSAction : NSObject {
	int usage, index;
	void* cookie;
	NSArray* subActions;
	id base;
	NSString* name;
}

@property(readwrite) int usage;
@property(readwrite) void* cookie;
@property(readonly) int index;
@property(readonly) NSArray* subActions;
@property(readwrite, retain) id base;
@property(readonly) NSString* name;
@property(readonly) BOOL active;

-(void) notifyEvent: (IOHIDValueRef) value;
-(NSString*) stringify;
-(NSArray*) subActions;
-(id) findSubActionForValue: (IOHIDValueRef) value;

@end
