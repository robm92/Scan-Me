//
//  JBChartFooterView.m
//  JBChartViewDemo
//
//  Created by Terry Worona on 11/6/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "JBBarChartFooterView.h"

// Numerics
CGFloat const kJBBarChartFooterPolygonViewDefaultPadding = 4.0f;

// Colors
static UIColor *kJBBarChartFooterViewDefaultBackgroundColor = nil;

@interface JBBarChartFooterView ()

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *rightLabel;

@end

@implementation JBBarChartFooterView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [JBBarChartFooterView class])
	{

	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = kJBBarChartFooterViewDefaultBackgroundColor;
        
        _padding = kJBBarChartFooterPolygonViewDefaultPadding;
        
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.adjustsFontSizeToFitWidth = YES;
        _leftLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_leftLabel];
        
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.adjustsFontSizeToFitWidth = YES;
        _rightLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightLabel];
    }
    return self;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat xOffset = self.padding;
    CGFloat yOffset = 0;
    CGFloat width = ceil(self.bounds.size.width * 0.5) - self.padding;
    
    self.leftLabel.frame = CGRectMake(xOffset, yOffset, width, self.bounds.size.height);
    self.rightLabel.frame = CGRectMake(CGRectGetMaxX(_leftLabel.frame), yOffset, width, self.bounds.size.height);
}

@end
