#import <Foundation/Foundation.h>

#import "config.h"
#import "state.h"



#define VALID_PARMS_NBR   4



int main (int argc, char *argv[])
{
  StateMachine *stateMachine = nil;
    
  if (argc == 1 || argc > VALID_PARMS_NBR || (argc < VALID_PARMS_NBR && strcmp(argv[1], "help"))) {
    NSLog(@"Usage of this program is: Convertor sum_to_convert_from currency_convert_from currency_name_convert_to\n");
    NSLog(@"To see the list of currencies available call Convertor help\n");
  } else if (argc < VALID_PARMS_NBR && !strcmp(argv[1], "help")) {
    NSLog(@"Currencies available:\n HUF\n IDR\n ISK\n JPY\n KRW\n LTL\n" 
                                    " CZK\n LVL\n MTL\n MYR\n NOK\n NZD\n" 
                                    " PHP\n PLN\n RON\n HRK\n RUB\n SEK\n"
                                    " SGD\n SIT\n SKK\n THB\n TRY\n ZAR\n"
                                    " EUR\n USD\n BGN\n DKK\n GBP\n CHF\n"
                                    " AUD\n BRL\n CAD\n CNY\n HKD\n ILS\n INR\n MXN\n");
    NSLog(@"Or you can try to use a long names like so \"Long name\":\n"
           " Hungarian Forint\n Indonesian Rupiahs\n Icelandic Kronur" 
           "Japanese Yen\n South Korean Won\n Lithuanian Litai\n Czech Koruna" 
           "Latvian Lati\n Malta Liri\n Malaysian Ringgits\n Norwegian Krone" 
           "New Zealand Dollars\n Philippine Pesos\n Polish Zlotych\n Romanian New Lei"
           "Croatian Kuna\n Russian Rubles\n Swedish Kronor\n Singapore Dollars" 
           "Slovenian Tolars\n Slovakian Koruny\n Thai Baht\n Turkish New Lira" 
           "South African Rand\n Euro\n U.S.Dollar\n Bulgarian lev\n Danish Krone" 
           "British Pound\n Swiss Franc\n Australian Dollar\n Brazilian Real" 
           "Canadian Dollar\n Chinese Yuan\n Hong Kong Dollar\n Israeli Shekel" 
           "Indian Rupee\n Mexican peso\n");

  } else {
    dbg(@"Parameters: %s, %s, %s\n", argv[0], argv[1], argv[2]);
    stateMachine = [[StateMachine alloc]init];
    if (stateMachine != nil) {
      NSString *argSumFrom = [NSString stringWithFormat:@"%s", argv[1]];
      NSString *argFrom = [NSString stringWithFormat:@"%s", argv[2]];
      NSString *argTo = [NSString stringWithFormat:@"%s", argv[3]];
      [stateMachine passCommandLineArgumentsToStateMachine:argFrom with:argTo sumFrom:argSumFrom];
      [stateMachine runStateMachine:STATE_INIT_DATA];
      /* Releasing state machine after work done */
      [stateMachine release];
    }
  }
  
    
  return 0;
}
