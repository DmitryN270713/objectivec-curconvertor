#import <Foundation/Foundation.h>

#import "config.h"
#import "network.h"
#import "state.h"



@interface NetworkWorker()

@property (readwrite) BOOL isError;
@property (readwrite) NSObject *parentObject;
@property (readwrite, retain) NSString *filePath;

@end


@implementation NetworkWorker

@synthesize isError;
@synthesize parentObject;
@synthesize filePath;

- (id)init {
  self = [super init];
  if (self == nil) {
    return nil;
  }
    
  /* May be later I'll add something here */
    
  return self;
}

- (void)prepareLoader: (NSObject *)parent {
  NSFileManager *filemgr = nil;
  NSString *currentpath = nil;
  
  self.parentObject = parent;
  
  /* Construct our path, where xml-data will be saved */
  
  filemgr = [[NSFileManager alloc] init];
  currentpath = [filemgr currentDirectoryPath];
  
  self.filePath = [NSString stringWithFormat:@"%@/currencies.xml", currentpath];
  
  [filemgr release];
  filemgr = nil;
}

- (BOOL)startDownloadCurrencies {
    NSString *currencyURL = @"http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml";
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    
    NSURLSessionDownloadTask *getTask = [session downloadTaskWithURL:[NSURL URLWithString:currencyURL]];
    
    [getTask resume];
    
    return TRUE;
}

- (void)URLSession:(NSURLSession *)session
                   task:(NSURLSessionTask *)task
   didCompleteWithError:(NSError *)error {
    if (error.code) {
        dbg("An error occurred during file loading: %@ code: %ld\n", error.localizedDescription, error.code);
      self.isError = TRUE;
    } else {
        dbg("No errors occured\n");
    }
  [((StateMachine *)self.parentObject) changeStateAsync:STATE_FILELOADED];
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    dbg("Resumed\n");
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    dbg("Loading... written: %lld of %lld\n", totalBytesWritten, totalBytesExpectedToWrite);
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    
  dbg("File downloaded from %@ current folder: %@\n", location.path, self.filePath);
  [[NSData dataWithContentsOfURL:location]
  writeToFile:self.filePath atomically:TRUE];
}

- (NSString *)getCurrencyFileToParse {
  return self.filePath;
}

- (BOOL)checkError {
  return self.isError;
}

- (void)dealloc {
  
  /*Deallocate loaded file path*/
  self.filePath = nil;
  
  [super dealloc];
}

@end
