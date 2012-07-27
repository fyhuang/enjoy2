//
//  JSActionButton.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

@implementation JSActionButton

@synthesize max, active;

-(id)initWithIndex: (int)newIndex andName: (NSString *)newName {
	if(self= [ super init]) {
		subActions = NULL;
		index = newIndex;
		name = [[NSString alloc] initWithFormat: @"Button %d %@", (index+1), newName];
	}
	return self;
}

-(id) findSubActionForValue: (IOHIDValueRef) val {
	if(IOHIDValueGetIntegerValue(val) == max)
		return self;
	return NULL;
}

-(void) notifyEvent: (IOHIDValueRef) value {
	active = IOHIDValueGetIntegerValue(value) == max;
}

@end
