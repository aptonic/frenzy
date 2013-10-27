@class MASShortcut;

typedef enum {
    MASShortcutViewAppearanceDefault = 0,  // Height = 19 px
    MASShortcutViewAppearanceTexturedRect, // Height = 25 px
    MASShortcutViewAppearanceRounded       // Height = 43 px
} MASShortcutViewAppearance;

@interface MASShortcutView : NSView  {
    
    NSButtonCell *_shortcutCell;
    NSInteger _shortcutToolTipTag;
    NSInteger _hintToolTipTag;
    NSTrackingArea *_hintArea;
    
    BOOL _enabled;
    BOOL _hinting;
    MASShortcut *_shortcutValue;
    NSString *_shortcutPlaceholder;
    void (^_shortcutValueChange)(MASShortcutView *sender);
    BOOL _recording;
    
    MASShortcutViewAppearance _appearance;
    
}

@property (nonatomic, strong) MASShortcut *shortcutValue;
@property (nonatomic, getter = isRecording) BOOL recording;
@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic, copy) void (^shortcutValueChange)(MASShortcutView *sender);
@property (nonatomic) MASShortcutViewAppearance appearance;

@end
