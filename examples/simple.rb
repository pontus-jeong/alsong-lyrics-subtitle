require '../modules/alsong'

=begin
mp3_file = File.open('/mnt/c/Users/wxg12/Music/im@s/03 天と海の島.mp3', "rb")
tag = ID3Tag.read(mp3_file)
puts "#{tag.title} - #{tag.artist}"
=end

print "음악 제목 : "
title = gets.chomp
print "음악 가수 : "
artist = gets.chomp
puts(title)
puts(artist)
puts Alsong.get_lyrics title, artist
puts "끝났습니다. 한번 확인해보세요."