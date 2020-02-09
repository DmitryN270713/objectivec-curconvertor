#ifndef __XML_PARSER__
#define __XML_PARSER__


@interface XMLParser : NSObject <NSXMLParserDelegate> {

}

-(id)init;
-(void)prepareParser:(NSObject *)parent with:(NSObject *)networkWorker
                from:(NSString *)valuteFrom to:(NSString *)valuteTo;
-(void)startFileParsing;
-(BOOL)checkError;
-(void)getRates:(Float32 *)_rateFrom with:(Float32 *)_rateTo;
-(void)dealloc;

@end


#endif /* End of header definition */
