//
//  InfoCrypt.m
//  Info
//
//  Created by gehaitong on 11-7-13.
//  Copyright 2011年. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>

typedef void (^InfoCryptProcessHandler)(size_t totalRead, size_t totalWrite);

@interface InfoCrypt : NSObject
/*
 AES128OperationWithStream
 提供大数据的处理方法，支持直接写文件操作及进度控制
 */
+ (BOOL)AES128OperationWithStream:(CCOperation)op input:(NSInputStream *)input output:(NSOutputStream *)output key:(NSString *)key withProcess:(InfoCryptProcessHandler)processHandler __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_4_0);

/*
 AES128OperationWithKey
 提供小数据的处理方法，直接内存操作
 */
+ (NSData *)AES128OperationWithKey:(CCOperation)op input:(NSData *)data key:(NSString *)key __OSX_AVAILABLE_STARTING(__MAC_10_4, __IPHONE_4_0);

/*
 MD5FromStream
 大文件/数据的MD5算法
 */
+ (NSString *)MD5FromStream:(NSInputStream *)stream;
+ (NSData *)MD5DataFromStream:(NSInputStream *)stream;
/*
 MD5
 小数据的MD5算法
 */
+ (NSString *)MD5:(NSData *)source;
@end
