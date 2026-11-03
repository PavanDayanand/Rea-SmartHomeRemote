source 'https://cdn.cocoapods.org/'
source 'https://github.com/TuyaInc/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'

platform :ios, '27.0'
project 'Breeze.xcodeproj'

# Only the basic device SDK. No AI products or vendor UI bundles are requested.
target 'Breeze' do
  pod 'ThingSmartHomeKit', '~> 7.11.0'
  pod 'ThingSmartCryption', :path => './iOS_SDK/ios_core_sdk'
end

# Xcode 27's test planner can omit implicit Pods dependencies. Make this explicit.
post_integrate do |installer|
  app_project = Xcodeproj::Project.open('Breeze.xcodeproj')
  app = app_project.targets.find { |target| target.name == 'Breeze' }
  pods = installer.pods_project.targets.find { |target| target.name == 'Pods-Breeze' }
  unless app_project.reference_for_path(installer.pods_project.path)
    app_project.main_group.new_file('Pods/Pods.xcodeproj')
  end
  app.add_dependency(pods)
  app_project.save
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '27.0'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end
end
