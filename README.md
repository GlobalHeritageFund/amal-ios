# Amal iOS

[Amal](http://amal.global/) is a mobile and web application designed for the rapid impact assessment of damaged heritage areas, buildings, or artifacts. By collecting data in the immediate aftermath of a disaster, AMAL preserves crucial information that can be used to repair or reconstruct damaged heritage.

This repository hosts the code for running the Amal iOS app.

## Requirements

* Xcode
* iOS 9

## How to build the app

1. Clone the repository.
2. Get the `GoogleService-Info.plist` file from a developer and move it to the `Aml` folder. It should be gitignored.
3. Get the `Secrets.plist` file from a developer and move it to the `Aml` folder. It should be gitignored.
5. Build the app.

## Animating Principles

### Backward compatibility

The Amal app is designed to run on as many iPhones as possible. Because iPhones are expensive relative to the competition, users in target regions may use them for a long time and they may be using handed-down devices. The deployment target for this app is set as low as the App Store will allow.

While this creates some small limitations for the developers of the app, being able to use the app on old devices allows for maximal adoption.

### Small binary size

Because the target regions may have slower internet access than users of more typical iPhone apps, the app and any updates should be as small as possible. Using Swift with such old versions of iOS can double or triple the size of the delivered binary, and so Swift was intentionally not used in any of the app's code. Images should be compressed and optimized, and other assets should be minimized where possible.

### User friendliness

Because the app is able to be used by laypeople in addition to professionals, the app should be user friendly. Where training is provided, it should be focused on the data gathering techniques, rather than the incidental complexity of the app. Apple's HIG is a good guideline; the rules and conventions should only be broken for very good reasons.

## Notes

* This project does not use bitcode