//
//  SubAction.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class JSAction;

@interface SubAction : NSObject {
	JSAction *base;
	NSString *name;
	int index;
	BOOL active;
}

-(id) initWithIndex:(int)newIndex name: (NSString*)newName  base: (JSAction*)newBase;

@property(readwrite, assign) JSAction* base;
@property(readwrite, copy) NSString* name;
@property(readwrite) int index;
@property(readwrite) BOOL active;

@end
