#ifndef __NETWORK__

@class StateMachine;

@interface NetworkWorker:NSObject<NSURLSessionDownloadDelegate> {
    
}

- (id) init;
- (void)prepareLoader: (NSObject *)parent;
- (BOOL)startDownloadCurrencies;
- (BOOL)checkError;
- (NSString *)getCurrencyFileToParse;
- (void)dealloc;

@end

#endif /* Header definition ends here */
