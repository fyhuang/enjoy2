//
//  TargetMouseBtn.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TargetMouseBtn.h"

@implementation TargetMouseBtn

@synthesize which;

-(NSString*) stringify {
	return [[NSString alloc] initWithFormat: @"mbtn~%d", which];
}

+(TargetMouseBtn*) unstringifyImpl: (NSArray*) comps {
	NSParameterAssert([comps count] == 2);
	TargetMouseBtn* target = [[TargetMouseBtn alloc] init];
	[target setWhich: [[comps objectAtIndex:1] integerValue]];
	return target;
}

-(void) trigger {
    NSPoint mouseLoc = [NSEvent mouseLocation];
    CGEventType eventType = (which == kCGMouseButtonLeft) ? kCGEventLeftMouseDown : kCGEventRightMouseDown;
    CGEventRef click = CGEventCreateMouseEvent(NULL,
                                               eventType,
                                               CGPointMake(mouseLoc.x, mouseLoc.y),
                                               which);
    CGEventPost(kCGHIDEventTap, click);
    CFRelease(click);
}

-(void) untrigger {
    NSPoint mouseLoc = [NSEvent mouseLocation];
    CGEventType eventType = (which == kCGMouseButtonLeft) ? kCGEventLeftMouseUp : kCGEventRightMouseUp;
    CGEventRef click = CGEventCreateMouseEvent(NULL,
                                               eventType,
                                               CGPointMake(mouseLoc.x, mouseLoc.y),
                                               which);
    CGEventPost(kCGHIDEventTap, click);
    CFRelease(click);
}

@end
