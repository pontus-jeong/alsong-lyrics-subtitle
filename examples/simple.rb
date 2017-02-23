require '../modules/alsong'

=begin
mp3_file = File.open('/mnt/c/Users/wxg12/Music/im@s/03 天と海の島.mp3', "rb")
tag = ID3Tag.read(mp3_file)
puts "#{tag.title} - #{tag.artist}"
=end
title = ""
artist = ""
num = ""

puts "음악 제목을 입력하세요."
title = gets

puts "가수를 입력하세요."
artist = gets

puts "번호를 입력하세요."
num = gets

puts "잠시만 기다리세요."
puts Alsong.get_lyrics title, artist, num
puts "끝났습니다. 한번 확인해보세요."