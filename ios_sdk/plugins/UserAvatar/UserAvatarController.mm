//*************************************************************************
//	创建日期:	2015-9-25
//	文件名称:	UserAvatarController.mm
//  创建作者:	Rect 	
//	版权所有:	Shadowkobg.com
//	相关说明:	头像设置 拍照 - 打开相册
//*************************************************************************


//-------------------------------------------------------------------------

//#include "UnityAppController.h"
#import "UserAvatarController.h"
#include "cocos2d.h"
#include "QSHelper.h"

@interface UserAvatarController()  {
    int _luaFunctionId;
    UIViewController*	_glRootController;
}

@end

//-------------------------------------------------------------------------
@implementation UserAvatarController
@synthesize popoverViewController = _popoverViewController;
@synthesize m_pstrFileName;


//-------------------------------------------------------------------------
-(void)setGLRootController:(UIViewController* )vc luaId:(int)luaFunctionId
{
    _luaFunctionId = luaFunctionId;
    _glRootController = vc;
}

//-(void)SetUnityFuncName:(const char *)pstr
//{
//    m_pstrFuncName = [NSString stringWithUTF8String:pstr];
//    [m_pstrFuncName retain];
//}
-(void)SetUnityFileName:(const char *)pstr
{
    m_pstrFileName = [NSString stringWithUTF8String:pstr];
    m_pstrFileName = [NSString stringWithFormat:@"%@%@",@"/",m_pstrFileName];
    [m_pstrFileName retain];
}
//-------------------------------------------------------------------------
-(void)showActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                                cancelButtonTitle:NSLocalizedString( @"取消", nil )
                                                destructiveButtonTitle:nil
											    otherButtonTitles:NSLocalizedString( @"拍照", nil ), NSLocalizedString( @"从相册选择", nil ), nil];
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		[sheet showFromRect:CGRectMake( 0, 0, 188, 188 ) inView:_glRootController.view animated:YES];
	}
	else
	{
		[sheet showInView:_glRootController.view];
	}
	
	[sheet release];
    
}
//-------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( buttonIndex == 0 )
	{
		[self showPicker:UIImagePickerControllerSourceTypeCamera];
	}
	else if( buttonIndex == 1 )
	{
		[self showPicker:UIImagePickerControllerSourceTypePhotoLibrary];
	}
	else 
	{
//        if (NULL == m_pstrFuncName || [m_pstrFuncName isEqualToString:@""])
//        {
//            NSLog(@"actionSheet m_pstrFuncName is null");
//            return;
//        }
		//UnitySendMessage( [m_pstrObjectName UTF8String], [m_pstrFuncName UTF8String], RESULE_CANCEL );
	}
}
//-------------------------------------------------------------------------
- (void)showPicker:(UIImagePickerControllerSourceType)type
{
	UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
	picker.delegate = self;
	picker.sourceType = type;
	picker.allowsEditing = YES;
	
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
	{
		Class popoverClass = NSClassFromString( @"UIPopoverController" );
		if( !popoverClass )
			return;
        
		_popoverViewController = [[popoverClass alloc] initWithContentViewController:picker];
		[_popoverViewController setDelegate:self];

		[_popoverViewController presentPopoverFromRect:CGRectMake( 0, 0, 188, 188 )
												inView:_glRootController.view
							  permittedArrowDirections:UIPopoverArrowDirectionAny
											  animated:YES];
	}
	else
	{
        UIViewController *vc = _glRootController;
		[vc presentModalViewController:picker animated:YES];
	}
}
//-------------------------------------------------------------------------
- (void)popoverControllerDidDismissPopover:(UIPopoverController*)popoverController
{
	self.popoverViewController = nil;
	
   // UnitySendMessage( [m_pstrObjectName UTF8String], [m_pstrFuncName UTF8String], RESULE_FINISH );
    
}
//-------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
	UIImage *image;
	UIImage *image2;
    image = [info objectForKey:UIImagePickerControllerEditedImage];
    
   // NSLog( @"picker got image with orientation: %i", image.imageOrientation );
    UIGraphicsBeginImageContext(CGSizeMake(196,196));
    [image drawInRect:CGRectMake(0, 0, 196, 196)];
    image2 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imgData;
    if(UIImagePNGRepresentation(image2) == nil)
    {
        imgData = UIImageJPEGRepresentation(image2, .6);
    }
    else
    {
         imgData = UIImagePNGRepresentation(image2);
    }
    
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:m_pstrFileName] contents:imgData attributes:nil];
    
    //NSLog(@"UnitySendMessage %s",RESULE_SUCCESS);
    //UnitySendMessage( [m_pstrObjectName UTF8String], [m_pstrFuncName UTF8String], RESULE_SUCCESS);
    NSString* nsStr = [DocumentsPath stringByAppendingString:m_pstrFileName];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:nsStr, @"fileName", 0, @"code", nil];
    [self CocosSendMessage:dic];
	[self dismissWrappedController];
}

//-------------------------------------------------------------------------
- (void)CocosSendMessage:(NSDictionary*)dic
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [QSHelper callBackCocos2dFunction:_luaFunctionId JsongString:jsonString];
    [QSHelper setCurrentPlugin:Plugin_Null];
}
//-------------------------------------------------------------------------

//-------------------------------------------------------------------------
- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
	[self dismissWrappedController];
   // UnitySendMessage( [m_pstrObjectName UTF8String], [m_pstrFuncName UTF8String], RESULE_CANCEL);
}
//-------------------------------------------------------------------------
- (void)dismissWrappedController
{
    
    UIViewController *vc = _glRootController;
	
	if( !vc )
		return;
	
	[vc dismissModalViewControllerAnimated:YES];
	[self performSelector:@selector(removeAndReleaseViewControllerWrapper) withObject:nil afterDelay:1.0];
	
}
//-------------------------------------------------------------------------
- (void)removeAndReleaseViewControllerWrapper
{
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && _popoverViewController )
	{
		[_popoverViewController dismissPopoverAnimated:YES];
		self.popoverViewController = nil;
	}
}

- (UIViewController *)getCurVC {
//    UIView* v = ((UIView*)cocos2d::Director::getInstance()->getOpenGLView()->getEAGLView());
//    
//    for (UIView* next = [v superview]; next; next = next.superview) {
//        UIResponder *nextResponder = [next nextResponder];
//        if ([nextResponder isKindOfClass:[UIViewController class]]) {
//            return (UIViewController *)nextResponder;
//        }
//    }
//    return nil;
    
    return [QSHelper getRootViewController];
}

@end

//-------------------------------------------------------------------------
void SettingAvaterFormiOS(int luaFuncName, const char* pstrFileName )
{
    [QSHelper setCurrentPlugin:Plugin_AvatarDiy];
    UserAvatarController * app = [[UserAvatarController alloc] init];
    
	if( ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] )
	{
		[app showPicker:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
		return;
	}
    
    UIViewController* vc = [app getCurVC];
    [app setGLRootController:vc luaId:luaFuncName];
    //[app SetUnityFuncName:pstrFuncName];
    [app SetUnityFileName:pstrFileName];
	[app showActionSheet];
	
}
