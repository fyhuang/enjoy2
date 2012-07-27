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
		
	NSParameterAssert(NO);
	return NULL;
}

-(NSString*) stringify {
	[self doesNotRecognizeSelector:_cmd];
	return NULL;
}

-(void) trigger {
	[self doesNotRecognizeSelector:_cmd];
}

-(void) untrigger {
	// no-op by default
}

-(BOOL) running {
	return running;
}
-(void) setRunning: (BOOL) newRunning {
	if(newRunning == running)
		return;
	if(newRunning)
		[self trigger];
	else
		[self untrigger];
	running = newRunning;		
}

@synthesize inputValue;

@end
