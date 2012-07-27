//
//  Config.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

@implementation Config

-(id) init {
	if(self=[super init]) {
		entries = [[NSMutableDictionary alloc] init];
	}
	return self;
}

@synthesize protect, name, entries;

-(void) setTarget:(Target*)target forAction:(id)jsa {
	[entries setValue:target forKey: [jsa stringify]];
}
-(Target*) getTargetForAction: (id) jsa {
	return [entries objectForKey: [jsa stringify]];
}

@end
