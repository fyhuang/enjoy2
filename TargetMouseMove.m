//
//  TargetMouseMove.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TargetMouseMove.h"

@implementation TargetMouseMove

-(BOOL) isContinuous {
    return true;
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

-(void) trigger: (JoystickController *)jc {
    return;
}

-(void) untrigger: (JoystickController *)jc {
    return;
}

-(void) update: (JoystickController *)jc {
    //printf("Dir %d inputValue %f\n", [self dir], [self inputValue]);
    if (fabs([self inputValue]) < 0.01)
        return; // dead zone
    
    NSRect screenRect = [[NSScreen mainScreen] frame];
    NSInteger height = screenRect.size.height;
    
    // TODO
    double speed = 4.0;
    if ([jc frontWindowOnly])
        speed = 12.0;
    double dx = 0.0, dy = 0.0;
    if ([self dir] == 0)
        dx = [self inputValue] * speed;
    else
        dy = [self inputValue] * speed;
    NSPoint *mouseLoc = &jc->mouseLoc;
    mouseLoc->x += dx;
    mouseLoc->y -= dy;
    
    CGEventRef move = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved,
                                              CGPointMake(mouseLoc->x, height - mouseLoc->y),
                                              0);
    CGEventSetType(move, kCGEventMouseMoved);
    CGEventSetIntegerValueField(move, kCGMouseEventDeltaX, dx);
    CGEventSetIntegerValueField(move, kCGMouseEventDeltaY, dy);
    
    if ([jc frontWindowOnly]) {
        ProcessSerialNumber psn;
        GetFrontProcess(&psn);
        CGEventPostToPSN(&psn, move);
    }
    else {
        CGEventPost(kCGHIDEventTap, move);
    }
    
    CFRelease(move);
}

@end
