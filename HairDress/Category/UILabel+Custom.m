//
//  UILabel+Custom.m
//  HairDress
//
//  Created by Apple on 2019/12/19.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "UILabel+Custom.h"



@implementation UILabel (Custom)

-(UILabel *)initCustomWithFrame:(CGRect)frame
                          title:(NSString *)title
                        bgColor:(UIColor *)bgColor
                     titleColor:(UIColor *)titleColor
                      titleFont:(CGFloat)fontsize
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    
    lbl.text = title;
    lbl.font = [UIFont systemFontOfSize:fontsize];
    
    lbl.backgroundColor = bgColor;
    lbl.textColor = titleColor;
    [lbl sizeToFit];
    
    return lbl;
}


-(UILabel *)initCommonWithFrame:(CGRect)frame
                  title:(NSString *)title
                   bgColor:(UIColor *)bgColor
                titleColor:(UIColor *)titleColor
                      titleFont:(CGFloat)fontsize
                  textAlignment:(NSTextAlignment)textAlignment
                          isFit:(BOOL)isFit
{
    UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
    lbl.text = title;
    lbl.font = [UIFont systemFontOfSize:fontsize];
    lbl.textColor = titleColor;
    lbl.textAlignment = textAlignment;
    lbl.backgroundColor = bgColor;
    if(isFit){
        [lbl sizeToFit];
    }
    return lbl;
}

- (void)textAlignmentLeftAndRight{
    [self textAlignmentLeftAndRightWith:CGRectGetWidth(self.frame)];
}

- (void)textAlignmentLeftAndRightWith:(CGFloat)labelWidth{

    if(self.text==nil||self.text.length==0) {

    return;

    }

    CGSize size = [self.text boundingRectWithSize:CGSizeMake(labelWidth,MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:self.font} context:nil].size;

    NSInteger length = (self.text.length-1);

    NSString* lastStr = [self.text substringWithRange:NSMakeRange(self.text.length-1,1)];

    if([lastStr isEqualToString:@":"]||[lastStr isEqualToString:@"："]) {

    length = (self.text.length-2);

    }

    CGFloat margin = (labelWidth - size.width)/length;

    NSNumber*number = [NSNumber numberWithFloat:margin];

    NSMutableAttributedString* attribute = [[NSMutableAttributedString alloc]initWithString:self.text];
    [attribute addAttribute:NSKernAttributeName value:number range:NSMakeRange(0,length)];

    self.attributedText= attribute;

}

@end
