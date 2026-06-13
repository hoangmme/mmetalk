require 'fileutils'
require 'base64'

png_data = File.read('/tmp/mme-logo.png')
base64_png = Base64.strict_encode64(png_data)

svg_content = <<~SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="100%" height="100%">
  <image href="data:image/png;base64,#{base64_png}" width="512" height="512"/>
</svg>
SVG

[
  'app/javascript/widget/assets/images/logo.svg',
  'app/javascript/dashboard/assets/images/bubble-logo.svg',
  'app/javascript/design-system/images/logo-thumbnail.svg',
  'public/brand-assets/logo_thumbnail.svg',
  'public/brand-assets/logo.svg',
  'public/brand-assets/logo_dark.svg'
].each do |logo|
   if File.exist?(logo)
     File.write(logo, svg_content)
     puts "Replaced SVG logo: #{logo}"
   end
end

[
  'app/javascript/design-system/images/logo-dark.png',
  'app/javascript/design-system/images/logo.png'
].each do |logo|
   if File.exist?(logo)
     FileUtils.cp('/tmp/mme-logo.png', logo)
     puts "Replaced PNG logo: #{logo}"
   end
end
