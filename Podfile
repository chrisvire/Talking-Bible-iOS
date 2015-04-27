# Uncomment this line to define a global platform for your project
platform :ios, '8.0'

link_with "TalkingBible"

target 'TalkingBible' do
  pod "Parse", "~> 1.7.1"
  pod "ParseCrashReporting", "~> 1.7.1"
  # pod "Stripe", "~> 3.1.0"
  # pod "Stripe/ApplePay", "~> 3.1.0"
  # pod "XLForm", "~> 2.1.0"
  pod "MDMCoreData/MDMPersistenceController", "~> 1.5.0"
  pod "MDMCoreData/MDMFetchedResultsTableDataSource", "~> 1.5.0"
  pod "SSZipArchive", "~> 0.3.2"
  pod "FlatUIKit", "~> 1.6"
  pod "GoogleAnalytics-iOS-SDK", "~> 3.10"
  pod "Reachability", "~> 3.2"
  pod "NullSafe", "~> 1.2.1"
  pod "Branch"
end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-TalkingBible/Pods-TalkingBible-Acknowledgements.plist', 'TalkingBible/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
