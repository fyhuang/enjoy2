//
//  TargetKeyboard.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

@implementation TargetKeyboard

@synthesize vk, descr;

-(NSString*) stringify {
	return [[NSString alloc] initWithFormat: @"key~%d~%@", vk, descr];
}

+(TargetKeyboard*) unstringifyImpl: (NSArray*) comps {
	NSParameterAssert([comps count] == 3);
	TargetKeyboard* target = [[TargetKeyboard alloc] init];
	[target setVk: [[comps objectAtIndex:1] integerValue]];
	[target setDescr: [comps objectAtIndex:2]];
	return target;
}

-(void) trigger: (JoystickController *)jc {
	CGEventRef keyDown = CGEventCreateKeyboardEvent(NULL, vk, true);
	CGEventPost(kCGHIDEventTap, keyDown);
	CFRelease(keyDown);
}

-(void) untrigger: (JoystickController *)jc {
	CGEventRef keyUp = CGEventCreateKeyboardEvent(NULL, vk, false);
	CGEventPost(kCGHIDEventTap, keyUp);
	CFRelease(keyUp);
}

@end
