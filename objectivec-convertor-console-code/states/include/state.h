#ifndef __STATE__
#define __STATE__

@class Cmd_Parser;
@class NetworkWorker;
@class XMLParser;

@interface StateMachine : NSObject

typedef NS_ENUM (NSInteger, states_t) {
    STATE_INIT_DATA  = 0x0,
    STATE_CMD_PARSED,
    STATE_FILELOADED,
    STATE_XML_PARSED,
    STATE_VALUE_CALCULATED,
    STATE_STR_TO_USER,
    STATE_EXIT,
    STATE_EXIT_ON_ERROR,
    STATE_IDLE
};

@property (atomic, readwrite) states_t state;
@property (atomic, readwrite, retain) dispatch_semaphore_t async_sem;
@property (readwrite, retain) Cmd_Parser *cmd_parser;
@property (readwrite, retain) NetworkWorker *network;
@property (readwrite, retain) XMLParser *xmlParser;

-(id)init;
-(void)passCommandLineArgumentsToStateMachine:(NSString *)valueFrom with:(NSString *)valueTo sumFrom:(NSString *)_sumFrom;
-(void)runStateMachine:(states_t)state;
-(void)changeStateAsync:(states_t)toState;

@end

#endif /* End of header definition */
