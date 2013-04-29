//
//  TopUpViewController.h
//  linphone
//
//  Created by lion on 22/04/2013.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeViewController.h"
#import "ZZFlipsideViewController.h"
#import "PayPalMobile.h"

@interface TopUpViewController : UIViewController<UITextFieldDelegate,UICompositeViewDelegate,
        PayPalPaymentDelegate, ZZFlipsideViewControllerDelegate, UIPopoverControllerDelegate> {
    NSString * balance;
    NSString * topupAmount;
}

@property (nonatomic, retain) IBOutlet UITextField * balanceText;
@property(nonatomic, strong, readwrite) UIPopoverController *flipsidePopoverController;

@property(nonatomic, strong, readwrite) NSString *environment;
@property(nonatomic, assign, readwrite) BOOL acceptCreditCards;
@property(nonatomic, strong, readwrite) PayPalPayment *completedPayment;


-(IBAction)refresh:(id)sender;
-(IBAction)topUp:(id)sender;

@end