//
//  Dot52WindowController.m
//  Dot52
//
//  Created by Rafael Cruz on 15/12/13.
//
//

#import "Dot52WindowController.h"
#import "Dot52RoiManager.h"

//  Acho que tenho que usar _ pra nomear essas variaveis locais.
//  Acho que tenho que usar um bloco @interface aqui também, já que essas variáveis vão ser usadas localmente.

float corrCoeff; // Will store the value of the selected correction coefficient.
NSString *apRoiName; // Name to the ROI created with the "AP" button. Will be used as key for this ROI in dot52ManagedRois NSMutableDictionary.
NSString *trvRoiName; // Name to the ROI created with the "TRV" button. Will be used as key for this ROI in dot52ManagedRois NSMutableDictionary.
NSString *lonRoiName; // Name to the ROI created with the "LON" button. Will be used as key for this ROI in dot52ManagedRois NSMutableDictionary.
Dot52RoiManager *dot52RoiManager; // Pointer to Dot52RoiManager sharedInstance.

@implementation Dot52WindowController

@synthesize resultText;
@synthesize buttonCopyResult;
@synthesize iconAp;
@synthesize iconTrv;
@synthesize iconLon;

@synthesize customResultString;
@synthesize resultString;
@synthesize ApDiameterString;
@synthesize TrvDiameterString;
@synthesize LonDiameterString;

#pragma mark - Class Methods
// ---------------------------------------------------------------------------
//  Class Methods
// ---------------------------------------------------------------------------
+ (id) sharedInstance {
    static Dot52WindowController *dot52Window = nil;
    @synchronized(self) {
        if (dot52Window == nil)
            dot52Window = [[self alloc] initWithWindowNibName:@"Dot52WindowController"];
    }
    //[dot52Window autorelease];
    return dot52Window;
}

#pragma mark - Instance Methods
// ---------------------------------------------------------------------------
//  Instance Methods
// ---------------------------------------------------------------------------
- (id)initWithWindow:(NSWindow *)window {
    NSLog(@"Yes, was called!");
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)dealloc {
    NSLog(@"dot52WindowControler dealloc");
    [dot52RoiManager release];
    [super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after dot52Window has been loaded from its nib file.
    
    corrCoeff = M_PI/6;
    apRoiName = @"Anteroposterior";
    trvRoiName = @"Transverse";
    lonRoiName = @"Longitudinal";
    dot52RoiManager = [[Dot52RoiManager sharedInstance] retain];
    
    self.customResultString = [[NSMutableString alloc] initWithString:@"Measures @AP x @TRV x @LON cm, with an estimated volume of about @VOL ml."];
    self.resultString = @"Set anteroposterior, tranverse and longitudinal diameters to estimate volume.";
    
    [self updateResultText];
}

- (void) updateResultText {
    
    // Updating status icons of managed ROIs.
    NSString *roiBeingCreated = [dot52RoiManager dot52RoiName];
    ROI *apRoi = [[dot52RoiManager dot52ManagedRois] objectForKey:apRoiName];
    ROI *trvRoi = [[dot52RoiManager dot52ManagedRois] objectForKey:trvRoiName];
    ROI *lonRoi = [[dot52RoiManager dot52ManagedRois] objectForKey:lonRoiName];
    
    if (apRoi) {
        [iconAp setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
    } else if (roiBeingCreated == apRoiName) {
        [iconAp setImage:[NSImage imageNamed:@"NSStatusPartiallyAvailable"]];
    } else {
        [iconAp setImage:[NSImage imageNamed:@"NSStatusNone"]];
    }
    
    if (trvRoi) {
        [iconTrv setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
    } else if (roiBeingCreated == trvRoiName) {
        [iconTrv setImage:[NSImage imageNamed:@"NSStatusPartiallyAvailable"]];
    } else {
        [iconTrv setImage:[NSImage imageNamed:@"NSStatusNone"]];
    }
    
    if (lonRoi) {
        [iconLon setImage:[NSImage imageNamed:@"NSStatusAvailable"]];
    } else if (roiBeingCreated == lonRoiName) {
        [iconLon setImage:[NSImage imageNamed:@"NSStatusPartiallyAvailable"]];
    } else {
        [iconLon setImage:[NSImage imageNamed:@"NSStatusNone"]];
    }
    
    // Updating NSTextFields
    float apRoiLength = [self lengthForRoiName:apRoiName];
    float trvRoiLength = [self lengthForRoiName:trvRoiName];
    float lonRoiLength = [self lengthForRoiName:lonRoiName];
    float estimatedVolume = apRoiLength * trvRoiLength * lonRoiLength * corrCoeff;
    
    if (apRoiLength > 0) {
        self.ApDiameterString = [NSString stringWithFormat:@"= %.01f cm", apRoiLength];
    } else {
        self.ApDiameterString = @"Set AP.";
    }
    
    if (trvRoiLength > 0) {
        self.TrvDiameterString = [NSString stringWithFormat:@"= %.01f cm", trvRoiLength];
    } else {
        self.TrvDiameterString = @"Set TRV.";
    }
    
    if (lonRoiLength > 0) {
        self.LonDiameterString = [NSString stringWithFormat:@"= %.01f cm", lonRoiLength];
    } else {
        self.LonDiameterString = @"Set LON.";
    }
    
    if ([[buttonCopyResult title] isEqualToString:@"Save"]) {
        [resultText bind:@"value" toObject:self withKeyPath:@"customResultString" options:nil];
    } else {
        if (estimatedVolume > 0) {
            //        [resultText setStringValue:[NSString stringWithFormat:@"Mede %.01f x %.01f x %.01f cm, com volume estimado em %.02f ml.", apRoiLength, trvRoiLength, lonRoiLength, estimatedVolume]];
            [resultText setString:[NSString stringWithFormat:@"Measures %.01f x %.01f x %.01f cm, with an estimated volume of about %.02f ml.", apRoiLength, trvRoiLength, lonRoiLength, estimatedVolume]];
            [buttonCopyResult setEnabled:YES];
        } else {
            [resultText setString:[NSString stringWithFormat:@"Set anteroposterior, tranverse and longitudinal diameters to estimate volume."]];
            [buttonCopyResult setEnabled:NO];
        }
    }
}

#pragma mark - IBActions
// ---------------------------------------------------------------------------
//  IBActions
// ---------------------------------------------------------------------------
- (IBAction)selectCoefficient:(NSPopUpButton *)sender {
    switch ([sender indexOfSelectedItem]) {
        case 0:
            corrCoeff = M_PI/6;
            break;
        case 1:
            corrCoeff = 0.625;
            break;
        case 2:
            corrCoeff = 0.71;
            break;
        default:
            corrCoeff = M_PI/6;
            [sender selectItemAtIndex:0];
            break;
    }
    [self updateResultText];
}

- (IBAction)buttonCreateApRoi:(NSButton *)sender {
    [dot52RoiManager createRoiType:tMesure withName:apRoiName withColor:[NSColor blueColor]];
}

- (IBAction)buttonCreateTrvRoi:(NSButton *)sender {
    [dot52RoiManager createRoiType:tMesure withName:trvRoiName withColor:[NSColor redColor]];
}

- (IBAction)buttonCreateLonRoi:(NSButton *)sender {
    [dot52RoiManager createRoiType:tMesure withName:lonRoiName withColor:[NSColor yellowColor]];
}

- (IBAction)copyResult:(NSButton *)sender {
    if ([[buttonCopyResult title] isEqualToString:@"Copy Result"]) {
        NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
        NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
        [pasteBoard declareTypes:types owner:self];
        [pasteBoard setString:[resultText string] forType:NSStringPboardType];
    }
    if ([[buttonCopyResult title] isEqualToString:@"Save"]) {
        [resultText setEditable:NO];
        [buttonCopyResult setTitle:@"Copy Result"];
        [self updateResultText];
    }
}

- (IBAction)editResultText:(NSButton *)sender {
    [resultText setEditable:YES];
    [buttonCopyResult setTitle:@"Save"];
    [self updateResultText];
}

#pragma mark - Tweaks...
// ---------------------------------------------------------------------------
//  This method was created to get [roi MesureLength] avoiding exceptions.
//
//  * Check the number of points. Theres an exception when the user select and
//  deletes a single point.
//  * In this case we should not call [ROI MesureLength] before the ROI is
//  completely deleted, because the ROI will still exists and this method will
//  not check the number of points - raising an exception.
// ---------------------------------------------------------------------------
- (float) lengthForRoiName: (NSString*) roiName {
    NSDictionary *dot52ManagedRois = [dot52RoiManager dot52ManagedRois];
    ROI *roi = [dot52ManagedRois objectForKey:roiName];
    int numberOfPoints = [[roi points] count];
    float roiLength = 0;
    if (numberOfPoints > 1) { // See comments.
        roiLength = [roi MesureLength:NULL];
    }
    
    return roiLength;
}

@end
