require 'net/smtp'

smtp = Net::SMTP.new('h02.azdigimail.com', 465)
smtp.enable_tls
begin
  smtp.start('mme.vn', 'admin@mme.vn', 'MPf@AoO?,r1X', :plain) do |s|
    puts "✅ Authentication successful via Port 465 (TLS/SSL)!"
  end
rescue => e
  puts "❌ Port 465 failed: #{e.message}"
end

puts "---"

smtp587 = Net::SMTP.new('h02.azdigimail.com', 587)
smtp587.enable_starttls_auto
begin
  smtp587.start('mme.vn', 'admin@mme.vn', 'MPf@AoO?,r1X', :plain) do |s|
    puts "✅ Authentication successful via Port 587 (STARTTLS)!"
  end
rescue => e
  puts "❌ Port 587 failed: #{e.message}"
end
