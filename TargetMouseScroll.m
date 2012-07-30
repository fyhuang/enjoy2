//
//  TargetMouseScroll.m
//  Enjoy
//
//  Created by Yifeng Huang on 7/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TargetMouseScroll.h"

@implementation TargetMouseScroll

@synthesize howMuch;

-(NSString*) stringify {
	return [[NSString alloc] initWithFormat: @"mscroll~%d", howMuch];
}

+(TargetMouseScroll*) unstringifyImpl: (NSArray*) comps {
	NSParameterAssert([comps count] == 2);
	TargetMouseScroll* target = [[TargetMouseScroll alloc] init];
	[target setHowMuch: [[comps objectAtIndex:1] integerValue]];
	return target;
}

-(void) trigger: (JoystickController *)jc {
    CGEventRef scroll = CGEventCreateScrollWheelEvent(NULL,
                                                      kCGScrollEventUnitLine,
                                                      1,
                                                      [self howMuch]);
    CGEventPost(kCGHIDEventTap, scroll);
    CFRelease(scroll);
}

@end
