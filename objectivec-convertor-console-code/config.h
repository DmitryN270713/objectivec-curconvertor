#ifndef __CONFIG__
#define __CONFIG__

#define DEBUG_TRACES
#undef DEBUG_TRACES

#ifdef DEBUG_TRACES
# define dbg(fmt, ...) NSLog((@"%s " fmt), __PRETTY_FUNCTION__,  ##__VA_ARGS__)
#else
# define dbg(...)
#endif

#endif /* End of config definition */
