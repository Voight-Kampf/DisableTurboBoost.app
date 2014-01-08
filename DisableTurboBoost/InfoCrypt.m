//
//  InfoCrypt.m
//  Info
//
//  Created by gehaitong on 11-11-4.
//  Copyright 2011年. All rights reserved.
//

#import "InfoCrypt.h"

static NSString *calculateHashResult(unsigned char *result, NSInteger length)
{
    NSString *hash = @"";
    for(int i=0; i<length; i++)
    {
        hash = [hash stringByAppendingFormat:@"%02X", result[i]];
    }
    return hash;
}

static unsigned char *getKey(NSString *key)
{
    unsigned char *result = malloc(CC_MD5_DIGEST_LENGTH);
    CC_MD5([key UTF8String], (CC_LONG)key.length, result);
    return result;
}

@implementation InfoCrypt

+ (BOOL)AES128OperationWithStream:(CCOperation)op input:(NSInputStream *)input output:(NSOutputStream *)output key:(NSString *)key withProcess:(InfoCryptProcessHandler)processHandler
{
    if(nil == input || nil == output || nil == key)
        return NO;
    
    BOOL ret = YES;
    size_t totalRead = 0, totalWrite = 0;
    unsigned char *keyPtr = NULL;
    
    int maxLength = 256*1024;//256KB
    size_t written = 0;
    
    CCCryptorRef context = nil;
    
    uint8_t *buffer = NULL, *bufferOut = NULL;
    
    keyPtr = getKey(key);
    if(nil == keyPtr)
        return NO;
    
    if(CCCryptorCreate(op, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCKeySizeAES128, NULL, &context) != kCCSuccess)
    {
        ret = NO;
        goto fail;
    }
    
    [input open];
    [output open];
    
    buffer = malloc(maxLength);
    bufferOut = malloc(maxLength*2);
    
    while([input hasBytesAvailable])
    {
        int read = (int)[input read:buffer maxLength:maxLength];
        if(CCCryptorUpdate(context, buffer, read, bufferOut, maxLength*2, &written) == kCCSuccess)
        {
            if(![input hasBytesAvailable] || written == 0)
            {
                size_t written2 = 0;
                if(CCCryptorFinal(context, bufferOut+written, maxLength*2-written, &written2) == kCCSuccess)
                {
                    [output write:bufferOut maxLength:written+written2];
                    totalWrite += written+written2;
                    if(NULL != processHandler)
                        processHandler(totalRead, totalWrite);
                }
                else
                    ret = NO;
            }
            else
            {
                [output write:bufferOut maxLength:written];
                totalRead += read;
                totalWrite += written;
                if(NULL != processHandler)
                    processHandler(totalRead, totalWrite);
            }
        }
        else
            ret = NO;
    }
    
fail:
    if(buffer)
        free(buffer);
    if(bufferOut)
        free(bufferOut);
    
    CCCryptorRelease(context);
    [input close];
    [output close];
    
    return ret;
}

+ (NSData *)AES128OperationWithKey:(CCOperation)op input:(NSData *)data key:(NSString *)key
{
    NSData *ret = nil;
    unsigned char *keyPtr = getKey(key);
    if(nil == keyPtr) return nil;
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(op, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCKeySizeAES128, NULL, [data bytes], dataLength, buffer, bufferSize, &numBytesEncrypted);
    
    free(keyPtr);
    
    if(cryptStatus == kCCSuccess)
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    
    free(buffer);
    return ret;
}

+ (NSString *)MD5FromStream:(NSInputStream *)stream
{
    NSData *ret = [self MD5DataFromStream:stream];
    if (ret)
    {
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        [ret getBytes:result length:CC_MD5_DIGEST_LENGTH];
        return calculateHashResult(result, ret.length);
    }
    return nil;
}

+ (NSData *)MD5DataFromStream:(NSInputStream *)stream;
{
    if(nil == stream) return nil;
    
    CC_MD5_CTX context;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    [stream open];
    CC_MD5_Init(&context);
    
    int maxLength = 512*1024;//512K
    uint8_t *buffer = malloc(maxLength);
    while([stream hasBytesAvailable])
    {
        int length = (int)[stream read:buffer maxLength:maxLength];
        CC_MD5_Update(&context, buffer, length);
    }
    
    free(buffer);
    CC_MD5_Final(result, &context);
    [stream close];
    
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

+ (NSString *)MD5:(NSData *)source
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([source bytes], (CC_LONG)source.length, result);
    return calculateHashResult(result, CC_MD5_DIGEST_LENGTH);
}

@end
