//
//  QYTextView.m
//  SeekLinkText
//
//  Created by yuqy on 15-5-25.
//  Copyright (c) 2015年 QY. All rights reserved.
//

#import "QYTextView.h"
#import "QYLink.h"

@interface QYTextView ()
/**
 *  链接检测器
 */
@property (nonatomic, strong) NSDataDetector *linkDetector;
/**
 *  存放链接
 */
@property (nonatomic, strong) NSMutableArray *linkArray;
@end

@implementation QYTextView
#pragma mark - 初始化
+ (instancetype)view
{
    return [[self alloc] init];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}
- (void)setup
{
    self.selectable = YES;
    self.editable = NO;
    self.scrollEnabled = NO;
    self.userInteractionEnabled = NO;
    self.textContainerInset = UIEdgeInsetsMake(0, -5, 0, -5);
    self.backgroundColor = [UIColor clearColor];
}
#pragma mark - private method
- (void)createLinksWithStr:(NSString *)str
{
    __block NSMutableString *tempStrM = [str mutableCopy];
    [self.linkDetector enumerateMatchesInString:str
                                        options:0
                                          range:NSMakeRange(0, str.length)
                                     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
    {
        QYLink *link = [QYLink link];
        link.URL = result.URL;
        if (defaultReplacedString && defaultReplacedString.length) { // 需要替换字符串
            NSRange absoluteRange = [tempStrM rangeOfString:result.URL.absoluteString];
            [tempStrM replaceCharactersInRange:absoluteRange withString:defaultReplacedString];
            
            link.range = NSMakeRange(absoluteRange.location, defaultReplacedString.length);
        } else { // 使用原始串
            link.range = result.range;
        }
        [self.linkArray addObject:link];
    }];
    // 展示的字符串
    NSMutableAttributedString *exhibitionString = [[NSMutableAttributedString alloc] initWithString:tempStrM];
    self.attributedText = exhibitionString;
    
    for (QYLink *link in self.linkArray) {
        // 添加链接的位置
        [self addLinkRectsWithLink:link];
        if (defaultLinkBackgroundColor) {
            [exhibitionString addAttribute:NSBackgroundColorAttributeName value:defaultLinkBackgroundColor range:link.range];
        }
    }
    if (defaultLinkBackgroundColor) self.attributedText = exhibitionString;
    
}
- (void)addLinkRectsWithLink:(QYLink *)link
{
    // 设置选中范围
    self.selectedRange = link.range;
    NSArray *selectionRects = [self selectionRectsForRange:self.selectedTextRange];
    NSMutableArray *mutableRects = [NSMutableArray array];
    for (UITextSelectionRect *selectionRect in selectionRects) {
        // 有可能出现宽或高为0的错误值
        if (!selectionRect.rect.size.width || !selectionRect.rect.size.height) continue;
        // 添加到link的范围数组中
        [mutableRects addObject:selectionRect];
    }
    link.rects = mutableRects;
}
- (QYLink *)touchingLinkWithPoint:(CGPoint)point
{
    __block QYLink *touchingLink = nil;
    [self.linkArray enumerateObjectsUsingBlock:^(QYLink *link, NSUInteger idx, BOOL *stop) {
        for (UITextSelectionRect *selectionRect in link.rects) {
            if (CGRectContainsPoint(selectionRect.rect, point)) {
                touchingLink = link;
                break;
            }
        }
    }];
    return touchingLink;
}
- (void)showClinkingBackgroundWithTouchingLink:(QYLink *)touchingLink
{
    if (touchingLink && defaultLinkClickingBackgroundColor) {
        NSMutableAttributedString *attrStr = [self.attributedText mutableCopy];
        [attrStr removeAttribute:NSBackgroundColorAttributeName range:touchingLink.range];
        [attrStr addAttribute:NSBackgroundColorAttributeName value:defaultLinkClickingBackgroundColor range:touchingLink.range];
        self.attributedText = attrStr;
    }
}
- (void)removeClinkingBackgroundWithTouchingLink:(QYLink *)touchingLink
{
    if (touchingLink && defaultLinkClickingBackgroundColor) {
        NSMutableAttributedString *attrStr = [self.attributedText mutableCopy];
        [attrStr removeAttribute:NSBackgroundColorAttributeName range:touchingLink.range];
        [attrStr addAttribute:NSBackgroundColorAttributeName value:defaultLinkBackgroundColor range:touchingLink.range];
        self.attributedText = attrStr;
    }
}
#pragma mark - event response
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    QYLink *touchingLink = [self touchingLinkWithPoint:touchPoint];
    [self showClinkingBackgroundWithTouchingLink:touchingLink];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    QYLink *touchingLink = [self touchingLinkWithPoint:point];
    
    if (touchingLink) {
        // 说明手指在某个链接上面抬起来
        if ([self.delegate respondsToSelector:@selector(textView:didClickLinkWithURL:)]) {
            [self.delegate textView:self didClickLinkWithURL:touchingLink.URL];
        }
    }
    // 相当于触摸被取消
    [self touchesCancelled:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    QYLink *touchingLink = [self touchingLinkWithPoint:point];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeClinkingBackgroundWithTouchingLink:touchingLink];
    });
}
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if ([self touchingLinkWithPoint:point]) {
        return self;
    }
    return nil;
}
#pragma mark - Setter
- (void)setOriginalString:(NSString *)originalString
{
    _originalString = originalString;
    [self createLinksWithStr:originalString];
}
#pragma mark - 懒加载
- (NSDataDetector *)linkDetector
{
    if (!_linkDetector) {
        _linkDetector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    }
    return _linkDetector;
}
- (NSMutableArray *)linkArray
{
    if (!_linkArray) {
        _linkArray = [NSMutableArray array];
    }
    return _linkArray;
}
@end
