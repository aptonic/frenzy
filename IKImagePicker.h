//
//  IKImagePicker.h
//  Frenzy
//
//  Created by John Winter on 22/07/11.
//  Copyright 2011 Aptonic Software. All rights reserved.
//

@interface IKImagePicker : IKPictureTaker
{
}

+ (IKImagePicker *) imagePicker;
- (void) beginImagePickerWithDelegate:(id) delegate didEndSelector:(SEL) didEndSelector contextInfo:(void *) contextInfo; 
- (void) beginImagePickerSheetForWindow:(NSWindow *)aWindow withDelegate:(id) delegate didEndSelector:(SEL) didEndSelector contextInfo:(void *) contextInfo; 

@end

#define IKImagePickerAllowsVideoCaptureKey IKPictureTakerAllowsVideoCaptureKey
#define IKImagePickerAllowsFileChoosingKey IKPictureTakerAllowsFileChoosingKey
#define IKImagePickerShowRecentPictureKey IKPictureTakerShowRecentPictureKey
#define IKImagePickerUpdateRecentPictureKey IKPictureTakerUpdateRecentPictureKey
#define IKImagePickerAllowsEditingKey IKPictureTakerAllowsEditingKey
#define IKImagePickerShowEffectsKey IKPictureTakerShowEffectsKey
#define IKImagePickerInformationalTextKey IKPictureTakerInformationalTextKey
#define IKImagePickerImageTransformsKey IKPictureTakerImageTransformsKey
#define IKImagePickerOutputImageMaxSizeKey IKPictureTakerOutputImageMaxSizeKey
#define IKImagePickerCropAreaSizeKey IKPictureTakerCropAreaSizeKey

extern NSString *const IKPictureTakerShowAddressBookPicture;
extern NSString *const IKPictureTakerShowEmptyPicture;


/* old types for layerForType: */
extern NSString *const IKImageBrowserCellLayerTypeBackground;
extern NSString *const IKImageBrowserCellLayerTypeForeground;
extern NSString *const IKImageBrowserCellLayerTypeSelection;
extern NSString *const IKImageBrowserCellLayerTypePlaceHolder;
