//
//  QYTextView.h
//  SeekLinkText
//
//  Created by yuqy on 15-5-25.
//  Copyright (c) 2015年 QY. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QYTextView;

/** 链接替换文本 */
static NSString * const defaultReplacedString = @"我是link";
/** 链接默认背景 */
#define defaultLinkBackgroundColor [UIColor greenColor]
/** 链接点击背景 */
#define defaultLinkClickingBackgroundColor [UIColor redColor]

@protocol QYTextViewDelegate <UITextViewDelegate>
@optional
- (void)textView:(QYTextView *)textView didClickLinkWithURL:(NSURL *)linkURL;
@end

@interface QYTextView : UITextView
/** 原始文本 */
@property (nonatomic, copy) NSString *originalString;



@property (nonatomic, weak) id<QYTextViewDelegate> delegate;
+ (instancetype)view;
@end
