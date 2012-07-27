//
//  KeyInputTextField.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

@implementation KeyInputTextView

@synthesize descr, hasKey;

-(id) init {
	if(self = [super init]) {
		setEnabled: NO;
	}
	return self;
}

-(void) clear {
	[self setString: [NSString string]];
	vk = -1;
	hasKey = NO;
	descr = NULL;
}

-(NSString*) stringForKeyCode: (int) keycode {
	switch(keycode) {
		case 0x7a :	return @"F1";
		case 0x78 :	return @"F2";
		case 0x63 :	return @"F3";
		case 0x76 :	return @"F4";
		case 0x60 :	return @"F5";
		case 0x61 :	return @"F6";
		case 0x62 :	return @"F7";
		case 0x64 :	return @"F8";
		case 0x65 :	return @"F9";
		case 0x6d :	return @"F10";
		case 0x67 :	return @"F11";
		case 0x6f :	return @"F12";
		case 0x69 :	return @"F13";
		case 0x6b :	return @"F14";
		case 0x71 :	return @"F15";
		case 0x6a :	return @"F16";
		case 0x40 :	return @"F17";
		case 0x4f :	return @"F18";
		case 0x50 :	return @"F19";

		case 0x35 :	return @"Esc";
		case 0x32 : return @"`";
			
		case 0x12 : return @"1";
		case 0x13 : return @"2";
		case 0x14 : return @"3";
		case 0x15 : return @"4";
		case 0x17 : return @"5";
		case 0x16 : return @"6";
		case 0x1a : return @"7";
		case 0x1c : return @"8";
		case 0x19 : return @"9";
		case 0x1d : return @"0";
		case 0x1b : return @"-";
		case 0x18 : return @"=";
			
		case 0x3f : return @"Fn";
		case 0x39 : return @"Caps Lock";
		case 0x38 : return @"Left Shift";
		case 0x3b : return @"Left Control";
		case 0x3a : return @"Left Option";
		case 0x37 : return @"Left Command";
		case 0x36 : return @"Right Command";
		case 0x3d : return @"Right Option";
		case 0x3e : return @"Right Control";
		case 0x3c : return @"Right Shift";
			
		case 0x73 : return @"Home";
		case 0x74 : return @"Page Up";
		case 0x75 : return @"Delete";
		case 0x77 : return @"End";
		case 0x79 : return @"Page Down";
			
		case 0x30 : return @"Tab";
		case 0x33 : return @"Backspace";
		case 0x24 : return @"Return";
		case 0x31 : return @"Space";
			
		case 0x0c : return @"Q";
		case 0x0d : return @"W";
		case 0x0e : return @"E";
		case 0x0f : return @"R";
		case 0x11 : return @"T";
		case 0x10 : return @"Y";
		case 0x20 : return @"U";
		case 0x22 : return @"I";
		case 0x1f : return @"O";
		case 0x23 : return @"P";
		case 0x21 : return @"[";
		case 0x1e : return @"]";
		case 0x2a : return @"\\";
		case 0x00 : return @"A";
		case 0x01 : return @"S";
		case 0x02 : return @"D";
		case 0x03 : return @"F";
		case 0x05 : return @"G";
		case 0x04 : return @"H";
		case 0x26 : return @"J";
		case 0x28 : return @"K";
		case 0x25 : return @"L";
		case 0x29 : return @";";
		case 0x27 : return @"'";
		case 0x06 : return @"Z";
		case 0x07 : return @"X";
		case 0x08 : return @"C";
		case 0x09 : return @"V";
		case 0x0b : return @"B";
		case 0x2d : return @"N";
		case 0x2e : return @"M";
		case 0x2b : return @",";
		case 0x2f : return @".";
		case 0x2c : return @"/";
			
		case 0x47 : return @"Clear";
		case 0x51 : return @"Keypad =";
		case 0x4b : return @"Keypad /";
		case 0x43 : return @"Keypad *";
		case 0x59 : return @"Keypad 7";
		case 0x5b : return @"Keypad 8";
		case 0x5c : return @"Keypad 9";
		case 0x4e : return @"Keypad -";
		case 0x56 : return @"Keypad 4";
		case 0x57 : return @"Keypad 5";
		case 0x58 : return @"Keypad 6";
		case 0x45 : return @"Keypad +";
		case 0x53 : return @"Keypad 1";
		case 0x54 : return @"Keypad 2";
		case 0x55 : return @"Keypad 3";
		case 0x52 : return @"Keypad 0";
		case 0x41 : return @"Keypad .";
		case 0x4c : return @"Enter";
			
		case 0x7e : return @"Up";
		case 0x7d : return @"Down";
		case 0x7b : return @"Left";
		case 0x7c : return @"Right";
	}
	return [[NSString alloc] initWithFormat: @"Key 0x%x",keycode];
}

-(BOOL) acceptsFirstResponder {
	return enabled;
}

-(BOOL) becomeFirstResponder {
	[self setBackgroundColor: [NSColor selectedTextBackgroundColor]];
	return YES;
}

-(BOOL) resignFirstResponder {
	[self setBackgroundColor: [NSColor textBackgroundColor]];
	return YES;
}

-(void) pressed:(int) keycode {
	[self setVk: keycode];
	[[self window] makeFirstResponder: nil];
	[targetController keyChanged];
}

-(void) setVk: (int) key {
	vk=key;
	hasKey = YES;
	descr = [self stringForKeyCode: key];
	[self setString: descr];
}
-(int) vk {
	return vk;
}

- (void)keyDown:(NSEvent *)evt {
	if([evt isARepeat])
		return;
	[self pressed: [evt keyCode]];
}

-(void) flagsChanged:(NSEvent*)evt {
	// XXX sometimes it's key up
	[self pressed: [evt keyCode]];
}

-(void) setEnabled: (BOOL) newEnabled {
	enabled = newEnabled;
	if(!newEnabled && [window firstResponder] == self)
		[window makeFirstResponder: NULL];
	
	
	if(enabled) {
		if([window firstResponder] == self)
			[self setBackgroundColor: [NSColor selectedTextBackgroundColor]];
		else
			[self setBackgroundColor: [NSColor textBackgroundColor]];
	} else {
		[self setBackgroundColor: [NSColor textBackgroundColor]];
	}	
}
-(BOOL) enabled {
	return enabled;
}


@end
