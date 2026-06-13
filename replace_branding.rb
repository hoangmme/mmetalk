require 'fileutils'
require 'base64'

def replace_in_file(path, search, replace)
  return unless File.exist?(path)
  content = File.read(path)
  new_content = content.gsub(search, replace)
  if content != new_content
    File.write(path, new_content)
    puts "Updated: #{path}"
  end
end

puts "Replacing Chatwoot with MMe Talk..."

# Update backend locales
Dir.glob('config/locales/*.yml').each do |file|
  next unless file.end_with?('en.yml') || file.end_with?('vi.yml')
  replace_in_file(file, "Chatwoot", "MMe Talk")
end

# Update frontend locales
Dir.glob('app/javascript/dashboard/i18n/locale/**/*.{json,js}').each do |file|
  next unless file.include?('/en/') || file.include?('/vi/')
  replace_in_file(file, "Chatwoot", "MMe Talk")
  replace_in_file(file, "chatwoot", "mmetalk")
end

puts "Replacing logos..."

png_data = File.read('/tmp/mme-logo.png')
base64_png = Base64.strict_encode64(png_data)

svg_content = <<~SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="100%" height="100%">
  <image href="data:image/png;base64,#{base64_png}" width="512" height="512"/>
</svg>
SVG

# Replace standard logos
['app/javascript/dashboard/assets/images/logo.svg', 
 'app/javascript/dashboard/assets/images/logo-dark.svg', 
 'app/javascript/dashboard/assets/images/logo-thumbnail.svg',
 'public/logo.svg',
 'public/brand.svg'].each do |logo|
   if File.exist?(logo)
     File.write(logo, svg_content)
     puts "Replaced logo: #{logo}"
   end
end

# Copy PNG
FileUtils.cp('/tmp/mme-logo.png', 'public/logo.png') if File.exist?('public/logo.png')
FileUtils.cp('/tmp/mme-logo.png', 'public/logo-thumbnail.png') if File.exist?('public/logo-thumbnail.png')
FileUtils.cp('/tmp/mme-logo.png', 'public/apple-touch-icon.png') if File.exist?('public/apple-touch-icon.png')

puts "Done!"
