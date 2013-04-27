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
        [mapping_entries setObject:[[entries objectForKey:key] stringify] forKey:key];
    }
    [mapping_dict setObject:mapping_entries forKey:@"entries"];
    
    // Convert to JSON, write to file
    NSData *json_data = [mapping_dict JSONData];
    [json_data writeToURL:filename atomically:true];
    
    [json_data release];
    [mapping_entries release];
    [mapping_dict release];
}

-(Config*) loadSkelFromJSON:(NSData *)jsonData {
    NSDictionary *dict = [jsonData objectFromJSONData];
    name = [dict objectForKey:@"name"];
    return self;
}

-(Config*) loadFromJSON:(NSData *)jsonData withConfigList:(NSArray*)configs {
    NSDictionary *jd = [jsonData objectFromJSONData];
    NSString *jname = [jd objectForKey:@"name"];
    if (![jname isEqualToString:name]) {
        [NSException raise:@"Loading from JSON with different name" format:@"Loading from JSON with different name", nil];
    }
    
    NSDictionary *entries_d = [jd objectForKey:@"entries"];
    for(id key in entries_d) {
        NSString *value = [entries_d objectForKey:key];
        [entries setObject: [Target unstringify:value withConfigList:configs] forKey:key];
    }
    return self;
}

@end
