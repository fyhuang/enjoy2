//
//  Target.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

@implementation Target

+(Target*) unstringify: (NSString*) str withConfigList: (NSArray*) configs {
	NSArray* components = [str componentsSeparatedByString:@"~"];
	NSParameterAssert([components count]);
	NSString* typeTag = [components objectAtIndex:0];
	if([typeTag isEqualToString:@"key"])
		return [TargetKeyboard unstringifyImpl:components];
	if([typeTag isEqualToString:@"cfg"])
		return [TargetConfig unstringifyImpl:components withConfigList:configs];
    if([typeTag isEqualToString:@"mmove"])
        return [TargetMouseMove unstringifyImpl:components];
    if([typeTag isEqualToString:@"mbtn"])
        return [TargetMouseBtn unstringifyImpl:components];
    if([typeTag isEqualToString:@"mscroll"])
        return [TargetMouseScroll unstringifyImpl:components];
    if([typeTag isEqualToString:@"mtoggle"])
        return [TargetToggleMouseScope unstringifyImpl:components];
		
	NSParameterAssert(NO);
	return NULL;
}

-(NSString*) stringify {
	[self doesNotRecognizeSelector:_cmd];
	return NULL;
}

-(NSDictionary*) asDict {
    // TODO: actually do something
    return [[NSDictionary alloc] init];
}

-(void) trigger: (JoystickController *)jc {
	[self doesNotRecognizeSelector:_cmd];
}

-(void) untrigger: (JoystickController *)jc {
	// no-op by default
}

-(void) update: (JoystickController *) jc {
    [self doesNotRecognizeSelector:_cmd];
}

-(BOOL) isContinuous {
    return false;
}

@synthesize inputValue, running;

@end
