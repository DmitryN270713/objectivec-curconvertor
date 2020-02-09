#import <Foundation/Foundation.h>

#import "config.h"
#import "state.h"
#import "cmd.h"
#import "network.h"
#import "xml.h"


@interface StateMachine()

@property (readwrite, copy) NSString *valuteFrom;
@property (readwrite, copy) NSString *valuteTo;
@property (readwrite) Float32 sumFrom;
@property (readwrite) NSUInteger valuteIndexFrom;
@property (readwrite) NSUInteger valuteIndexTo;
@property (readwrite) NSString *errorString;
@property (readwrite) states_t previousState;
@property (readwrite) Float32 rateFrom;
@property (readwrite) Float32 rateTo;
@property (readwrite) Float32 resultSumToUser;
@property (readwrite) NSString *resultString;

-(void)aquireValutesIndecies;
-(void)releaseObjectsOnExit;

@end

@implementation StateMachine

@synthesize state;
@synthesize async_sem;
@synthesize cmd_parser;
@synthesize network;
@synthesize valuteFrom;
@synthesize valuteTo;
@synthesize sumFrom;
@synthesize valuteIndexFrom;
@synthesize valuteIndexTo;
@synthesize errorString;
@synthesize previousState;
@synthesize rateFrom;
@synthesize rateTo;
@synthesize resultSumToUser;
@synthesize resultString;

-(id)init {
  self = [super init];

  self.cmd_parser = nil;
  self.network = nil;
  self.xmlParser = nil;
  self.async_sem = nil;
  
  return self;
}

-(void)passCommandLineArgumentsToStateMachine:(NSString *)valueFrom with:(NSString *)valueTo sumFrom:(NSString *)_sumFrom {
  self.valuteFrom = valueFrom;
  [valueFrom release];
  self.valuteTo = valueTo;
  [valueTo release];
  self.sumFrom = [_sumFrom floatValue];
  [_sumFrom release];
}

-(void)aquireValutesIndecies {
  self.valuteIndexFrom = [self.cmd_parser getIndexInAbbrevation:self.valuteFrom];
  if (self.valuteIndexFrom == 0xDEADBEEF) {
    /* Try to look for the full name */
    self.valuteIndexFrom = [self.cmd_parser getIndexInFullNames:self.valuteFrom];
    if (self.valuteIndexFrom == 0xDEADBEEF) {
      self.state = STATE_EXIT_ON_ERROR;
      self.errorString = [NSString stringWithFormat:@"No such currency: %@\n", self.valuteFrom];
      return;
    }
    self.valuteFrom = [self.cmd_parser getAbbrevationByIndex:self.valuteIndexFrom];
  }
  
  self.valuteIndexTo = [self.cmd_parser getIndexInAbbrevation:self.valuteTo];
  if (self.valuteIndexTo == 0xDEADBEEF) {
    /* Try to look for the full name */
    self.valuteIndexTo = [self.cmd_parser getIndexInFullNames:self.valuteTo];
    if (self.valuteIndexTo == 0xDEADBEEF) {
      self.state = STATE_EXIT_ON_ERROR;
      self.errorString = [NSString stringWithFormat:@"No such currency: %@\n", self.valuteTo];
      return;
    }
    self.valuteTo = [self.cmd_parser getAbbrevationByIndex:self.valuteIndexTo];
  }
}

-(void)runStateMachine:(states_t)state {
  BOOL run = TRUE;
  while (run) {
    switch (self.state) {
      case STATE_INIT_DATA:
        /* Initialize data here */
        self.cmd_parser = [[Cmd_Parser alloc]init];
        if (self.cmd_parser == nil) {
          self.previousState = STATE_INIT_DATA;
          self.state = STATE_EXIT_ON_ERROR;
          dbg(@"Cannot initialize command parser\n");
          break;
        }
        
        self.network = [[NetworkWorker alloc]init];
        if (self.network == nil) {
          self.previousState = STATE_INIT_DATA;
          self.state = STATE_EXIT_ON_ERROR;
          dbg(@"Cannot initialize network worker\n");
          break;
        }
        
        self.xmlParser = [[XMLParser alloc]init];
        if (self.xmlParser == nil) {
          self.previousState = STATE_INIT_DATA;
          self.state = STATE_EXIT_ON_ERROR;
          dbg(@"Cannot initialize xml parser\n");
          break;
        }
        
        self.async_sem = dispatch_semaphore_create(0);
        if (self.async_sem == nil) {
          self.previousState = STATE_INIT_DATA;
          self.state = STATE_EXIT_ON_ERROR;
          dbg(@"Cannot initialize semaphore\n");
          break;
        }
        
        /* Parse command here */
        
        [self aquireValutesIndecies];
        if (self.state != STATE_EXIT_ON_ERROR) {
          self.state = STATE_CMD_PARSED;
          self.previousState = STATE_INIT_DATA;
        }
        
        break;
      case STATE_CMD_PARSED:
        /* Set network worker parameters and start file loading from network
         and go to IDLE */
        [self.network prepareLoader:((NSObject *)self)];
        [self.network startDownloadCurrencies];
        self.state = STATE_IDLE;
        self.previousState = STATE_CMD_PARSED;
        break;
      case STATE_FILELOADED:
        /* Parse file and possibly go to IDLE */
        [self.xmlParser prepareParser:self with:self.network from:self.valuteFrom to:self.valuteTo];
        [self.xmlParser startFileParsing];
        
        
        self.previousState = STATE_FILELOADED;
        self.state = STATE_IDLE;
        break;
      case STATE_XML_PARSED:
        /* Calculate value */
        NSLog(@"%@", [self.cmd_parser formStartMessageToUser:self.valuteIndexFrom with:self.valuteIndexTo]);
        resultSumToUser = self.sumFrom / self.rateFrom * self.rateTo;
        self.previousState = STATE_XML_PARSED;
        self.state = STATE_VALUE_CALCULATED;
        break;
      case STATE_VALUE_CALCULATED:
        /* String prepared to be shown to usr */
        self.resultString = [self.cmd_parser formResultStringToUSer:self.valuteIndexFrom with:self.valuteIndexTo
                                                               from:self.sumFrom to:self.resultSumToUser];
        self.previousState = STATE_VALUE_CALCULATED;
        self.state = STATE_STR_TO_USER;
        break;
      case STATE_STR_TO_USER:
        /* Show string to user */
        NSLog(@"------------------RESULT:------------------\n");
        NSLog(@"%@", self.resultString);
        self.previousState = STATE_STR_TO_USER;
        self.state = STATE_EXIT;
        break;
      case STATE_EXIT:
        /* Releasing objects */
        [self releaseObjectsOnExit];
        /* Exit */        
        run = FALSE;
        break;
      case STATE_EXIT_ON_ERROR:
        run = FALSE;
        NSLog(@"%@\n", self.errorString);
        break;
      case STATE_IDLE:
        dbg(@"Waiting for async operation done\n");
        /* Wait for the action done */
        dispatch_semaphore_wait(self.async_sem, DISPATCH_TIME_FOREVER);
        
        if (self.previousState == STATE_CMD_PARSED) {
          BOOL isError = [self.network checkError];
          if (isError) {
            self.state = STATE_EXIT_ON_ERROR;
            self.errorString = @"Error occured while loading information from the server\n";
          } else {
            dbg("File loaded. State can be changed\n");
            self.previousState = STATE_CMD_PARSED;
          }
        } else if (self.previousState == STATE_FILELOADED) {
          if ([self.xmlParser checkError]) {
            self.state = STATE_EXIT_ON_ERROR;
            self.errorString = @"An error occured while parsing xml\n";
          } else {
            Float32 from = 0;
            Float32 to = 0;
            [self.xmlParser getRates:&from with:&to];
            self.rateFrom = from;
            self.rateTo = to;
            self.previousState = STATE_FILELOADED;
          }
        }
        
        break;
      default:
        break;
    }
  }
}

-(void)changeStateAsync:(states_t)toState {
  dbg(@"Semaphore released\n");
  self.state = toState;
  dispatch_semaphore_signal(self.async_sem);
  
}

-(void)releaseObjectsOnExit {
  /* Release parser */
  self.cmd_parser = nil;
  
  /* Release network worker */
  self.network = nil;
  
  /* Release valute string */
  self.valuteFrom = nil;
  
  /* Release valute string */
  self.valuteTo = nil;
  
  /* Release semaphore */
  self.async_sem = nil;
  
  /* Release result string */
  self.resultString = nil;
  
  dbg(@"Properties released\n");
}

@end