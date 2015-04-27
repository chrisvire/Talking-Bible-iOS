#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

// Wait to load, then take a landing screen shot
target.delay(3)
captureLocalizedScreenshot("0-LandingScreen")

// Language screen
target.frontMostApp().mainWindow().buttons()[1].tap();
target.delay(1)
captureLocalizedScreenshot("1-LanguageSelection")
target.frontMostApp().navigationBar().leftButton().tap();
target.delay(1)

// Book screen
target.frontMostApp().mainWindow().buttons()[2].tap();
target.delay(1)
captureLocalizedScreenshot("2-BookSelection")

// Player screen
target.frontMostApp().mainWindow().tableViews()[0].cells()[0].tap();
target.delay(1)
captureLocalizedScreenshot("3-ChapterSelection")