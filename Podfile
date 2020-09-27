# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

target 'Amal' do
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!

    # Pods for Amal
    pod 'Firebase/Core', '6.27.0'
    pod 'Firebase/Storage', '6.27.0'
    pod 'Firebase/Database', '6.27.0'
    pod 'Firebase/Auth', '6.27.0'
    pod 'FirebaseUI/Auth', '8.4.2'

    pod 'Fabric', '1.7.9'
    pod 'Crashlytics', '3.10.5'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
        end
    end
end
