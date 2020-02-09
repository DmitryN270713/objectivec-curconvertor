/* Built-in classes */
#import <Foundation/Foundation.h>

#import "config.h"
#import "cmd.h"


@implementation Cmd_Parser

@synthesize abbrivations = _abbrivations;
@synthesize fullNames = _fullNames;


-(id) init {
    
  self = [super init];
  if (self == nil) {
    return nil;
  }
    
  _abbrivations = @[@"HUF", @"IDR", @"ISK", @"JPY", @"KRW", @"LTL", @"CZK", @"LVL", @"MTL", @"MYR", @"NOK", @"NZD", @"PHP", @"PLN", @"RON", @"HRK", @"RUB", @"SEK", @"SGD", @"SIT", @"SKK", @"THB", @"TRY", @"ZAR", @"EUR", @"USD", @"BGN", @"DKK", @"GBP", @"CHF    ", @"AUD", @"BRL", @"CAD", @"CNY", @"HKD", @"ILS", @"INR", @"MXN"];
  _fullNames = @[@"Hungarian Forint", @"Indonesian Rupiahs", @"Icelandic Kronur", @"Japanese Yen", @"South Korean Won", @"Lithuanian Litai", @"Czech Koruna", @"Latvian Lati", @"Malta Liri", @"Malaysian Ringgits", @"Norwegian Krone", @"New Zealand Dollars", @"Philippine Pesos", @"Polish Zlotych", @"Romanian New Lei", @"Croatian Kuna", @"Russian Rubles", @"Swedish Kronor", @"Singapore Dollars", @"Slovenian Tolars", @"Slovakian Koruny", @"Thai Baht", @"Turkish New Lira", @"South African Rand", @"Euro", @"U.S.Dollar", @"Bulgarian lev", @"Danish Krone", @"British Pound", @"Swiss Franc", @"Australian Dollar", @"Brazilian Real", @"Canadian Dollar", @"Chinese Yuan", @"Hong Kong Dollar", @"Israeli Shekel", @"Indian Rupee", @"Mexican peso"];
    
  return self;
}

-(NSUInteger)getIndexInAbbrevation:(const NSString *)abbrivation {
    NSUInteger index = 0;
    
    index = [self.abbrivations indexOfObject: [abbrivation uppercaseString]];
    
    if (index == NSNotFound) {
      dbg("String not found\n");
      return 0xDEADBEEF;
    } else {
      dbg("String %@ found at index %d\n", abbrivation, (unsigned int)index);
    }
    
    return index;
}

- (NSUInteger)getIndexInFullNames:(const NSString *)fullName {
    
    NSUInteger index = 0;
    
    index = [self.fullNames indexOfObject: fullName];
    
    if (index == NSNotFound) {
      dbg("String not found\n");
      return 0xDEADBEEF;
    } else {
      dbg("String %@ found at index %d\n", fullName, (unsigned int)index);
    }
    
    [fullName release];
    
    return index;
}

- (NSString *)getAbbrevationByIndex:(const NSUInteger)abbrivationIndex {
    if (abbrivationIndex >= [self.abbrivations count]) {
        return nil;
    }
    return [self.abbrivations objectAtIndex:abbrivationIndex];
}

- (NSString *)getFullNameByIndex:(const NSUInteger)fullNameIndex {
    if (fullNameIndex >= [self.fullNames count]) {
        return nil;
    }
    return [self.fullNames objectAtIndex:fullNameIndex];
}

- (NSString *)formStartMessageToUser:(NSUInteger)indexFrom with:(NSUInteger)indexTo {
    return [NSString stringWithFormat:@"Converting from %@ to %@...\n", [self.fullNames objectAtIndex: indexFrom], [self.fullNames objectAtIndex:indexTo]];
}

- (NSString *)formResultStringToUSer:(const NSUInteger)indexFrom with:(const NSUInteger)indexTo from:(const float)sumFrom to:(const float)sumTo {
    return [NSString stringWithFormat:@"For %0.2f %@ you will get %0.2f %@\n", sumFrom, [self.fullNames objectAtIndex: indexFrom], sumTo, [self.fullNames objectAtIndex:indexTo]];
}

@end
