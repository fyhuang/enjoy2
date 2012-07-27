//
//  JSAction.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

@implementation JSAction

@synthesize usage, cookie, index, subActions, base, name;

-(id) findSubActionForValue: (IOHIDValueRef) value {
	return NULL;
}

-(NSString*) stringify {
	return [[NSString alloc] initWithFormat: @"%@~%d",[base stringify],(int)cookie];
}
-(void) notifyEvent: (IOHIDValueRef) value {
	[self doesNotRecognizeSelector:_cmd];
}
-(BOOL) active {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

@end
