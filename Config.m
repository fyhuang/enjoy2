//
//  Config.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

#include "JSONKit/JSONKit.h"

@implementation Config

-(id) init {
	if(self=[super init]) {
		entries = [[NSMutableDictionary alloc] init];
	}
	return self;
}

@synthesize name, entries;

-(void) setTarget:(Target*)target forAction:(id)jsa {
	[entries setValue:target forKey: [jsa stringify]];
}
-(Target*) getTargetForAction: (id) jsa {
	return [entries objectForKey: [jsa stringify]];
}

-(void) saveJSONTo:(NSURL *)filename {
    NSMutableDictionary *mapping_dict = [[NSMutableDictionary alloc] init];
    [mapping_dict setObject:name forKey:@"name"];
    [mapping_dict setObject:@"Enjoy2-1.1" forKey:@"format"];
    
    NSMutableDictionary *mapping_entries = [[NSMutableDictionary alloc] init];
    for (id key in entries) {
        [mapping_entries setObject:[[entries objectForKey:key] asDict] forKey:key];
    }
    [mapping_dict setObject:mapping_entries forKey:@"entries"];
    
    // Convert to JSON, write to file
    NSData *json_data = [mapping_dict JSONData];
    [json_data writeToURL:filename atomically:true];
    
    [mapping_entries release];
    [mapping_dict release];
}

@end
