//
//  backtrace.hpp
//  ClouDoc
//
//  Created by mac on 2019. 1. 3..
//

#ifndef backtrace_hpp
#define backtrace_hpp

#include <stdio.h>

#include <execinfo.h>
int backtrace(void **buffer, int size);

char **backtrace_symbols(void *const *buffer, int size);

void backtrace_symbols_fd(void *const *buffer, int size, int fd);

#endif /* backtrace_hpp */
