//
//  JSONPropertyWindowController.h
//  AutomaticCoder
//

//

#import <Cocoa/Cocoa.h>

@interface JSONPropertyWindowController : NSWindowController
{
    NSString *path;
}
@property (weak) IBOutlet NSTableView *table;
@property(nonatomic,strong)  NSArrayController *arrayController;

- (IBAction)closeWindow:(id)sender;



@end
