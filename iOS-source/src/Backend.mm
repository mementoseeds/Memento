#include "Backend.h"

@implementation DocumentPicker

//We call this method from c++, to open document picker
- (void)openDocumentPicker:(NSString*)pickerType
{
    //Find the current app window, and its view controller object
    UIApplication* app = [UIApplication sharedApplication];
    UIWindow* rootWindow = app.windows[0];
    UIViewController* rootViewController = rootWindow.rootViewController;
    
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[pickerType] inMode:UIDocumentPickerModeOpen];
    
    documentPicker.delegate = self;

    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;

    [rootViewController presentViewController:documentPicker animated:YES completion:nil];
}

- (void)openDirectoryDialog
{
    UIApplication* app = [UIApplication sharedApplication];
    UIWindow* rootWindow = app.windows[0];
    UIViewController* rootViewController = rootWindow.rootViewController;

    //This line crashes
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[@"public.item"]];
    //documentPicker.delegate = self;
//    [rootViewController presentViewController:documentPicker animated:YES completion:nil];
}

@end

void callFromCpp()
{
    DocumentPicker *directoryDialog = [[DocumentPicker alloc] init];
    [directoryDialog openDirectoryDialog];
}
