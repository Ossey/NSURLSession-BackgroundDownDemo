//
//  NSURLSession+CorrectedResumeData.m
//  BackgroundDownloadDemo
//
//  Created by mofeini on 17/2/19.
//  Copyright © 2017年 com.test.demo. All rights reserved.
//

#import "NSURLSession+CorrectedResumeData.h"


#define IS_IOS10_AFTER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)

static NSString *const resumeCurrentRequestKey = @"NSURLSessionResumeCurrentRequest";
static NSString *const resumeOriginalRequestKey = @"NSURLSessionResumeOriginalRequest";
static NSString *const keyedArchiveRootObjectKey = @"NSKeyedArchiveRootObjectKey";

static NSData * correctRequestData(NSData *data) {
    if (!data) {
        return nil;
    }
    // return the same data if it's correct
    if ([NSKeyedUnarchiver unarchiveObjectWithData:data] != nil) {
        return data;
    }
    NSMutableDictionary *archive = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil] mutableCopy];
    
    if (!archive) {
        return nil;
    }
    NSInteger k = 0;
    id objectss = archive[@"$objects"];
    while ([objectss[1] objectForKey:[NSString stringWithFormat:@"$%ld",k]] != nil) {
        k += 1;
    }
    NSInteger i = 0;
    while ([archive[@"$objects"][1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld",i+k]];
            [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
        i++;
    }
    if ([archive[@"$objects"][1] objectForKey:@"__nsurlrequest_proto_props"] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:@"__nsurlrequest_proto_props"];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld",i+k]];
            [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
    }
    // Rectify weird "NSKeyedArchiveRootObjectKey" top key to NSKeyedArchiveRootObjectKey = "root"
    if ([archive[@"$top"] objectForKey:keyedArchiveRootObjectKey] != nil) {
        [archive[@"$top"] setObject:archive[@"$top"][keyedArchiveRootObjectKey] forKey: NSKeyedArchiveRootObjectKey];
        [archive[@"$top"] removeObjectForKey:keyedArchiveRootObjectKey];
    }
    // Reencode archived object
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    return result;
}

static NSMutableDictionary *getResumeDictionary(NSData *data) {
    
    NSMutableDictionary *resumeDict = nil;
    
    if IS_IOS10_AFTER {
        id root = nil;
        id keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        @try {
            root = [keyedUnarchiver decodeTopLevelObjectForKey:keyedArchiveRootObjectKey error:nil];
            if (root == nil) {
                root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
            }
        } @catch (NSException *exception) {
            @throw [NSException exceptionWithName:@"NSKeyedUnarchiver error" reason:@"NSKeyedUnarchiver 获取失败" userInfo:nil];
        }
        
        [keyedUnarchiver finishDecoding];
        resumeDict = [root mutableCopy];
    }
    
    if (resumeDict == nil) {
        [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
    }
    
    return resumeDict;
}

static NSData *correctResumeData(NSData *data) {
    if (data == nil) {
        return nil;
    }
    
    NSMutableDictionary *resumtDict = getResumeDictionary(data);
    if (resumtDict == nil) {
        return nil;
    }
    
    resumtDict[resumeCurrentRequestKey] = correctRequestData(resumtDict[resumeCurrentRequestKey]);
    resumtDict[resumeOriginalRequestKey] = correctRequestData(resumtDict[resumeOriginalRequestKey]);
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:resumtDict format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    return result;
}

@implementation NSURLSession (CorrectedResumeData)

- (NSURLSessionDownloadTask *)xy_downloadTaskWithResumeData:(NSData *)resumeData {
    
    NSData *data = correctResumeData(resumeData);
    data = data ? data : resumeData;
    
    // 恢复下载
    NSURLSessionDownloadTask *task = [self downloadTaskWithResumeData:data];
    NSMutableDictionary *resumtDict = getResumeDictionary(data);
    if (resumtDict) {
        if (task.originalRequest == nil) {
            NSData *orginalRequestData = resumtDict[resumeOriginalRequestKey];
            NSURLRequest *orginalRequest = [NSKeyedUnarchiver unarchiveObjectWithData:orginalRequestData];
            if (orginalRequest) {
                // 由于是只读属性，这里使用kvc赋值
                [task setValue:orginalRequest forKey:@"originalRequest"];
            }
            
            if (task.currentRequest == nil) {
                NSData *currentRequestData = resumtDict[resumeCurrentRequestKey];
                NSURLRequest *currentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:currentRequestData];
                if (currentRequest) {
                    // 由于是只读属性，这里使用kvc赋值
                    [task setValue:currentRequest forKey:@"currentRequest"];
                }
            }
        }
    }
    return task;
    
}

@end
