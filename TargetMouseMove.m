//
//  TargetMouseMove.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TargetMouseMove.h"

@implementation TargetMouseMove

-(void) setInputValue: (int) newIV {
    NSRect screenRect = [[NSScreen mainScreen] frame];
    NSInteger height = screenRect.size.height;
    NSPoint mouseLoc = [NSEvent mouseLocation];
    if (dir == 0)
        mouseLoc.x += newIV;
    else
        mouseLoc.y += newIV;
    
    CGEventRef move = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved,
                                              CGPointMake(mouseLoc.x, height - mouseLoc.y),
                                              kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, move);
    CFRelease(move);
}

@synthesize dir;

-(NSString*) stringify {
	return [[NSString alloc] initWithFormat: @"mmove~%d", dir];
}

+(TargetMouseMove*) unstringifyImpl: (NSArray*) comps {
	NSParameterAssert([comps count] == 2);
	TargetMouseMove* target = [[TargetMouseMove alloc] init];
	[target setDir: [[comps objectAtIndex:1] integerValue]];
	return target;
}

-(void) trigger {
    return;
}

-(void) untrigger {
    return;
}

@end
