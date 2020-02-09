#ifndef __CMD__

@interface Cmd_Parser : NSObject
{
@private
    NSArray *_abbrivations;
    
@private
    NSArray *_fullNames;
}

@property (readonly) NSArray *abbrivations;
@property (readonly) NSArray *fullNames;

- (NSUInteger)getIndexInAbbrevation:(const NSString *)abbrivation;
- (NSUInteger)getIndexInFullNames:(const NSString *)fullName;
- (NSString *)getAbbrevationByIndex:(const NSUInteger)abbrivationIndex;
- (NSString *)getFullNameByIndex:(const NSUInteger)fullNameIndex;
- (NSString *)formStartMessageToUser:(NSUInteger)indexFrom with:(NSUInteger)indexTo;
- (NSString *)formResultStringToUSer:(const NSUInteger)indexFrom with:(const NSUInteger)indexTo from:(const float)sumFrom to:(const float)sumTo;

@end

#endif  /* Hedaer definition ends here */
