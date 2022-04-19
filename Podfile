# Uncomment the next line to define a global platform for your project
 platform :ios, '9.0'

target 'Amal' do
    # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
    use_frameworks!

    # Pods for Amal
    pod 'Firebase/Core'
    pod 'Firebase/Storage'
    pod 'Firebase/Database'
    pod 'Firebase/Auth'
    pod 'FirebaseUI/Auth'
    pod 'FirebaseUI/Email'
    pod 'Firebase/Crashlytics'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
        end
    end
end
