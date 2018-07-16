//
//  CautionViewController.m
//  Amal
//
//  Created by Kenneth Parker Ackerson on 7/16/18.
//  Copyright © 2018 Global Heritage Fund. All rights reserved.
//

#import "CautionViewController.h"

@interface CautionViewController ()

@property (nonatomic) IBOutlet UITextView *termsOfServicesAndPrivacyPolicyLabel;

@end

@implementation CautionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableAttributedString *policyText = [[NSMutableAttributedString alloc] initWithString:self.termsOfServicesAndPrivacyPolicyLabel.text attributes:nil];
    
    const NSRange tosRange = [self.termsOfServicesAndPrivacyPolicyLabel.text rangeOfString:@"Terms of Service"];
    const NSRange privacyPolicyRange = [self.termsOfServicesAndPrivacyPolicyLabel.text rangeOfString:@"Privacy Policy"];

    void (^applyLink)(NSRange range, NSString *URLString) = ^(NSRange range, NSString *URLString){
        [policyText addAttribute:NSLinkAttributeName value:URLString range:range];
        [policyText addAttribute:NSUnderlineStyleAttributeName value:@1 range:range];
        [policyText addAttribute:NSUnderlineColorAttributeName value:[self.termsOfServicesAndPrivacyPolicyLabel.textColor colorWithAlphaComponent:0.8] range:range];
    };
    
    applyLink(tosRange, @"http://amal.global/terms-of-service/");
    applyLink(privacyPolicyRange, @"https://globalheritagefund.org/index.php/news-resources/library/privacy-policy/");
    
    const NSRange fullStringRange = NSMakeRange(0, self.termsOfServicesAndPrivacyPolicyLabel.text.length);
    
    [policyText addAttribute:NSForegroundColorAttributeName value:self.termsOfServicesAndPrivacyPolicyLabel.textColor range:fullStringRange];
    [policyText addAttribute:NSFontAttributeName value:self.termsOfServicesAndPrivacyPolicyLabel.font range:fullStringRange];

    // Set the tint color to color the hyperlinks the correct color
    self.termsOfServicesAndPrivacyPolicyLabel.tintColor = self.termsOfServicesAndPrivacyPolicyLabel.textColor;
    self.termsOfServicesAndPrivacyPolicyLabel.attributedText = policyText;
}


@end
