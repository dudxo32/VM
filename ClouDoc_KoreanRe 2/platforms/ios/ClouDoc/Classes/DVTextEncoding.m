//
//  DVTextEncoding.m
//  WebControl
//
//  Created by DevCEL on 10. 12. 21..
//  Copyright 2010 ALS Works. All rights reserved.
//  www.devcel.co.kr

#import "DVTextEncoding.h"

@implementation DVTextEncoding
@synthesize saveWeb;
@synthesize revData;
@synthesize delegate;
@synthesize convencoding;


- (void)koreanWebText:(NSString *)path webview:(UIWebView *)currentWebView{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	self.saveWeb = currentWebView;
	self.revData = [NSMutableData data];
	
	
	NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:
														   [NSURLRequest requestWithURL:[NSURL URLWithString:path]]
														   delegate:self];
	[con start];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[self.revData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"error is %@", error);
	self.revData = nil;
	[connection release];
	if ([self respondsToSelector:@selector(didFailedEncoding)]) 
		[self.delegate didFailedEncoding:saveWeb];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	
	
	NSMutableString *jpn = [[NSMutableString alloc] initWithData:self.revData encoding:0x8];
	NSMutableString *kor = [[NSMutableString alloc] initWithData:self.revData encoding:0x80000422];
    NSMutableString *chn = [[NSMutableString alloc] initWithData:self.revData encoding:0x80000423];
	NSData *dataText = [NSData data];
	
	if ([convencoding isEqualToString:@"euckr"]) {
		[kor insertString:@"<html><head></head><body><pre style=\"word-wrap: break-word; white-space: pre-wrap; font-size:35px\">"
					atIndex:0];
		[kor appendString:@"</pre></body></html>"];
		dataText = [kor dataUsingEncoding:NSUTF8StringEncoding];
		
	}else if ([convencoding isEqualToString:@"shiftjis"]) {
		[jpn insertString:@"<html><head></head><body><pre style=\"word-wrap: break-word; white-space: pre-wrap;font-size:35px\">"
					atIndex:0];
		[jpn appendString:@"</pre></body></html>"];
		dataText = [jpn dataUsingEncoding:NSUTF8StringEncoding];
	}
    else if([convencoding isEqualToString:@"gbk"]){
        [chn insertString:@"<html><head></head><body><pre style=\"word-wrap: break-word; white-space: pre-wrap;font-size:35px\">"
                  atIndex:0];
		[chn appendString:@"</pre></body></html>"];
		dataText = [chn dataUsingEncoding:NSUTF8StringEncoding];
    }
	
    NSInteger len = [dataText length];
    if (len != 0) 
        [self.delegate didEndEncoding:saveWeb dec:dataText];
    else
        [self.delegate didFailedEncoding:saveWeb];
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[kor release];
	[jpn release];
	[chn release];
	self.revData = nil;
	[connection release];
}


- (void)dealloc{
	[revData release];
	[saveWeb release];
	[super dealloc];
}


@end
