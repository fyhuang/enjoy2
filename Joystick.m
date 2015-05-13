//
//  Joystick.m
//  Enjoy
//
//  Created by Sam McCall on 4/05/09.
//

@implementation Joystick


@synthesize	vendorId, productId, productName, name, index, device, children;

-(id)initWithDevice: (IOHIDDeviceRef) newDevice {
	if(self=[super init]) {
		children = [[NSMutableArray alloc]init];
		
		device = newDevice;
		productName = (NSString*)IOHIDDeviceGetProperty( device, CFSTR(kIOHIDProductKey) );
		vendorId = [(NSNumber*)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDVendorIDKey)) intValue];
		productId = [(NSNumber*)IOHIDDeviceGetProperty(device, CFSTR(kIOHIDVendorIDKey)) intValue];
		
		name = productName;
	}
	return self;
}

-(void) setIndex: (int) newIndex {
	index = newIndex;
	name = [[NSString alloc] initWithFormat: @"%@ #%d", productName, (index+1)];
}
-(int) index {
	return index;
}

-(void) invalidate {
	IOHIDDeviceClose(device, kIOHIDOptionsTypeNone);
	NSLog(@"Removed a device: %@", [self name]);
}

-(id) base {
	return NULL;
}

-(void) populateActions {
	NSArray* elements = (NSArray*)IOHIDDeviceCopyMatchingElements(device, NULL, kIOHIDOptionsTypeNone);
	
	int buttons = 0;
	int axes = 0;
	
	for(int i=0; i<[elements count]; i++) {
		IOHIDElementRef element = (IOHIDElementRef)[elements objectAtIndex: i];
		int type = IOHIDElementGetType(element);
		int usage = IOHIDElementGetUsage(element);
		int usagePage = IOHIDElementGetUsagePage(element);
		int max = IOHIDElementGetPhysicalMax(element);
		int min = IOHIDElementGetPhysicalMin(element);
        CFStringRef elName = IOHIDElementGetName(element);
		
//		if(usagePage != 1 || usagePage == 9) {
//			NSLog(@"Skipping usage page %x usage %x", usagePage, usage);
//			continue;
//		}
		
		JSAction* action = NULL;
		
		if(!(type == kIOHIDElementTypeInput_Misc || type == kIOHIDElementTypeInput_Axis ||
			 type == kIOHIDElementTypeInput_Button)) {

			continue;
		}
		
		if((max - min == 1) || usagePage == kHIDPage_Button || type == kIOHIDElementTypeInput_Button) {
			action = [[JSActionButton alloc] initWithIndex: buttons++ andName: (NSString *)elName];
			[(JSActionButton*)action setMax: max];
        } else if(usage == 0x39) {
			action = [[JSActionHat alloc] init];
        } else {
			if(usage >= 0x30 && usage < 0x36) {
				action = [[JSActionAnalog alloc] initWithIndex: axes++];
				[(JSActionAnalog*)action setMax: (double)max];
                [(JSActionAnalog*)action setMin: (double)min];
            } else {
				continue;
            }
		}

		[action setBase: self];
		[action setUsage: usage];
		[action setCookie: IOHIDElementGetCookie(element)];
		[children addObject:action];
	}
}

-(NSString*) stringify {
	return [[NSString alloc] initWithFormat: @"%d~%d~%d", vendorId, productId, index];
}

- (JSAction*) findActionByCookie: (void*) cookie {
	for(int i=0; i<[children count]; i++)
		if([[children objectAtIndex:i]cookie] == cookie)
			return (JSAction*)[children objectAtIndex:i];
	return NULL;
}

-(id) handlerForEvent: (IOHIDValueRef) value {
	JSAction* mainAction = [self actionForEvent: value];
	if(!mainAction)
		return NULL;
	return [mainAction findSubActionForValue: value];
}
-(JSAction*) actionForEvent: (IOHIDValueRef) value {
	IOHIDElementRef elt = IOHIDValueGetElement(value);
	void* cookie = IOHIDElementGetCookie(elt);
	return [self findActionByCookie: cookie];
}

@end
