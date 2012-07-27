//
//  TargetKeyboard.h
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//  Copyright 2009 University of Otago. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Target;

@interface TargetKeyboard : Target {
	CGKeyCode vk;
	NSString* descr;
}

@property (readwrite) CGKeyCode vk;
@property (readwrite, copy) NSString* descr;

+(TargetKeyboard*) unstringifyImpl: (NSArray*) comps;

@end
