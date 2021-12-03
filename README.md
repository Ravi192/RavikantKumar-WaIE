# Space Pictures
This is an app that displays pictures from the NASA APOD API. It pulls their listing, allows you to submit your own pictures and stores all the data using Core Data. Note, that videos are not shown.

## Installation

To install this app:

1. Ensure you have cocoapods installed using:

        sudo gem install cocoapods
2. Install pods with:

        pod install
3. Open the app in XCode from the generated `Space Pictures.xcworkspace` and run


### 1. Space Pictures
Space Picture screen occurs on load and is a UICollectionView of the pictures from the APOD API. It has pull to refresh and infinite scrolling capabilities and displays the newest photos first. You can tap pictures here to go to the detail screen, or tap the button in the top right to go to the apod submission screen.

### 2. Space Picture Detail
This screen is pushed onto the navigation controller when any cell in the space pictures screen is tapped. It shows extra details of the tapped picture returned from the APOD API.

