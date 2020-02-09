#import <Foundation/Foundation.h>

#import "config.h"
#import "xml.h"
#import "network.h"
#import "state.h"


@interface XMLParser()

@property (readwrite) NSObject *parentObject;
@property (readwrite, copy) NSString *pathToXML;
@property (readwrite) BOOL isError;
@property (readwrite) NSString *_valuteTo;
@property (readwrite) NSString *_valuteFrom;
@property (readwrite) NSXMLParser *parser;
@property (readwrite) NSInputStream *inputStream;
@property (readwrite) Float32 rateFrom;
@property (readwrite) Float32 rateTo;

-(void)taskParseXML;

@end


@implementation XMLParser

@synthesize parentObject;
@synthesize pathToXML;
@synthesize isError;
@synthesize _valuteTo;
@synthesize _valuteFrom;
@synthesize parser;
@synthesize inputStream;
@synthesize rateFrom;
@synthesize rateTo;

-(id)init {
  self = [super init];
  
  return self;
}

-(void)prepareParser:(NSObject *)parent with:(NSObject *)networkWorker
                from:(NSString *)valuteFrom to:(NSString *)valuteTo {
  self.parentObject = parent;
  self.pathToXML = [((NetworkWorker *) networkWorker) getCurrencyFileToParse];
  self._valuteFrom = valuteFrom;
  self._valuteTo = valuteTo;
  self.isError = FALSE;
  dbg(@"File to be parsed: %@\n", self.pathToXML);
}

-(void)startFileParsing {
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    dbg(@"Start parsing XML\n");
    [self taskParseXML];
  });
}

-(void)taskParseXML {
  BOOL result = NO;
  /* Parse XML here */
  
  self.inputStream = [NSInputStream inputStreamWithFileAtPath:self.pathToXML];
  if (self.inputStream == nil) {
    dbg(@"Cannot process xml file. Error flag set\n");
    self.isError = TRUE;
    return;
  }
  
  self.parser = [[NSXMLParser alloc]initWithStream:self.inputStream];
  if (self.parser == nil) {
    self.inputStream = nil;
    dbg(@"Cannot create parser. Error flag set\n");
    self.isError = TRUE;
    return;
  }
  
  self.parser.shouldProcessNamespaces = TRUE;
  self.parser.delegate = self;
  
  result = [self.parser parse];
  if (result == NO) {
    dbg(@"Error occured, while parsing\n");
    self.isError = TRUE;
  }
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
  dbg(@"Start parsing file\n");
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
  dbg(@"Document parsed. Releasing semaphore\n");
  self.parser = nil;
  self.inputStream = nil;
  [((StateMachine *)self.parentObject) changeStateAsync:STATE_XML_PARSED];
}

-(void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qualifiedName
     attributes:(NSDictionary *)attributeDict {
  dbg(@"element nmae: %@ namespaceURI: %@ qualified name: %@ attribute dict: %@ %@\n",
      elementName, namespaceURI, qualifiedName,
      [attributeDict valueForKey:@"currency"], [attributeDict valueForKey:@"rate"]);
  
  if ([self._valuteFrom isEqualToString:[attributeDict valueForKey:@"currency"]]) {
    self.rateFrom = [[attributeDict valueForKey:@"rate"] floatValue];
    dbg(@"Rate from: %f\n", self.rateFrom);
  } else if ([self._valuteFrom isEqualToString:@"EUR"]) {
    self.rateFrom = 1.0;
  }
  
  if ([self._valuteTo isEqualToString:[attributeDict valueForKey:@"currency"]]) {
    self.rateTo = [[attributeDict valueForKey:@"rate"] floatValue];
    dbg(@"Rate to: %f\n", self.rateTo);
  } else if ([self._valuteTo isEqualToString:@"EUR"]) {
    self.rateTo = 1.0;
  }
}

- (void)parser:(NSXMLParser *)parser
parseErrorOccurred:(NSError *)parseError {
  dbg(@"Error occured while parsing: %@\n", parseError.localizedDescription);
  self.isError = TRUE;
}

-(BOOL)checkError {
  return self.isError;
}

-(void)getRates:(Float32 *)_rateFrom with:(Float32 *)_rateTo {
  *_rateFrom = self.rateFrom;
  *_rateTo = self.rateTo;
  dbg(@"Rates assigned\n");
}

-(void)dealloc {
  self.pathToXML = nil;
  
  [super dealloc];
}

@end