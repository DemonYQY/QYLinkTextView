//
//  QYLink.h
//  SeekLinkText
//
//  Created by yuqy on 15-5-25.
//  Copyright (c) 2015年 QY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYLink : NSObject
/**
 *  链接
 */
@property (nonatomic, strong) NSURL *URL;
/**
 *  链接范围
 */
@property (nonatomic, assign) NSRange range;
/**
 *  链接边框（可能多个）
 */
@property (nonatomic, strong) NSArray *rects;

+ (instancetype)link;
@end
