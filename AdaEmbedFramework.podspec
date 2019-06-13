Pod::Spec.new do |spec|

  spec.name         = "AdaEmbedFramework"
  spec.version      = "0.1.4"
  spec.summary      = "Embed the Ada Support SDK in your app."
  spec.description  = <<-DESC
  Use the Ada Support SDK to inject the Ada support experience into your app. Visit https://ada.support to learn more.
                   DESC

  spec.homepage     = "https://github.com/AdaSupport/EmbedFramework"
  
  spec.license         = { :type => "COMMERCIAL", :text => "" }

  spec.author       = { "Aaron Vegh" => "aaron@innoveghtive.com" }
   
  spec.platform     = :ios, "10.0"

  spec.source       = { :git => "git@github.com:AdaSupport/EmbedFramework.git", :branch => 'master', :tag => spec.version.to_s }

  spec.source_files = "EmbedFramework/**/*.swift"

  spec.resources    = ['EmbedFramework/**/*.xcassets', 'EmbedFramework/AdaWebHostViewController.storyboard']

end
