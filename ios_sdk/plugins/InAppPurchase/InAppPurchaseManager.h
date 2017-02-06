//
//  InAppPurchaseManager.h
//
//  Created by Osipov Stanislav on 1/15/13.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#if UNITY_VERSION < 450
//#include "iPhone_View.h"
#endif

#import "TransactionServer.h"
#import "StoreProductView.h"

//#include "ViewController.h"

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"

@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKRequestDelegate> {
    NSMutableArray * _productIdentifiers;
    NSMutableDictionary * _products;
    TransactionServer * _storeServer;
    
   
}

+ (InAppPurchaseManager *) instance;

- (void) loadStore;
- (void) restorePurchases;
- (void) addProductId:(NSString *) productId;
- (void) buyProduct:(NSString * )productId;

- (void) ShowProductView:(int)viewId;
- (void) CreateProductView:(int) viewId products: (NSArray *) products;


-(void) verifyLastPurchase:(NSString *) verificationURL;

- (void) setPlayResultCallBack:(int) luaFuncID;
- (int) getPlayResultCallBack;

@end

void _loadStore(NSString * productsId);
void _buyProduct(NSString * productId);
void _restorePurchases();
void _verifyLastPurchase(NSString* url);
void _createProductView(int viewId, NSString * productsId );
void _showProductView(int viewId);
void _ISN_RequestInAppSettingState();
