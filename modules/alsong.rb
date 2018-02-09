require 'net/http'
require 'uri'
require 'active_support/core_ext/object/try'
require 'nokogiri'
module Alsong
  $alsong_uri = URI.parse 'http://lyrics.alsong.co.kr/alsongwebservice/service1.asmx'

  def Alsong.get_lyrics title, artist
    puts(title)
    puts(artist)

    xml_string = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope" xmlns:SOAP-ENC="http://www.w3.org/2003/05/soap-encoding" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns2="ALSongWebServer/Service1Soap" xmlns:ns1="ALSongWebServer" xmlns:ns3="ALSongWebServer/Service1Soap12"><SOAP-ENV:Body><ns1:GetResembleLyric2><ns1:stQuery><ns1:strTitle>' + title + '</ns1:strTitle><ns1:strArtistName>' + artist + '</ns1:strArtistName><ns1:nCurPage>0</ns1:nCurPage></ns1:stQuery></ns1:GetResembleLyric2></SOAP-ENV:Body></SOAP-ENV:Envelope>'
    req = Net::HTTP::Post.new $alsong_uri.request_uri
    # Content-Type := type "/" subtype *[";" parameter] 
    req.content_type = "text/xml;charset=utf-8"
    req.body = xml_string

    res = Net::HTTP.start $alsong_uri.hostname, $alsong_uri.port do |session|
      session.request req
    end
    puts("test-2")

    begin
      case res
      when Net::HTTPSuccess
        raise "Empty response" if res.body.nil? or res.body.empty?

        doc = Nokogiri.XML(res.body, nil, 'UTF-8')

        al_titles = doc.xpath('//alsong:strTitle', 'alsong' => 'ALSongWebServer')
        al_artists = doc.xpath('//alsong:strArtistName', 'alsong' => 'ALSongWebServer')
        al_albums = doc.xpath('//alsong:strAlbumName', 'alsong' => 'ALSongWebServer')
        al_lyrics = doc.xpath('//alsong:strLyric', 'alsong' => 'ALSongWebServer')

        al_titles.each_with_index do |c, i|
          print((i+1).to_s + " " + c.content + " " + al_artists[i] + " " + al_albums[i])
          puts
          puts("--------------------")
          al_lyrics[i].content.split('<br>').each do |l|
            puts l
          end
          puts("=============================================")
        end
        puts("자막으로 변환할 자막 선택")
        m = gets().chomp.to_i
        puts(m)
        song_info = {"title" => al_titles[m-1].content, "artist" => al_artists[m-1], "album" => al_albums[m-1]}
        puts(al_titles[m-1].content)
        title = "<Title>#{al_titles[m-1].content}</Title>"
        lyrics = al_lyrics[m-1].content.split('<br>')

        form = ""
        lyrics.each do |lyric|
          lyric_time = lyric.try(:split, "[")[1] || ""
          lyric_time = lyric_time.try(:split, "]")[0] || ""
          a = lyric_time.try(:split, ":")[0].to_i
          a_r = lyric_time.try(:split, ":")[1]
          b = a_r.try(:split, ".")[0].to_i
          c = a_r.try(:split, ".")[1].to_i
          mil_sec = a*60000+b*1000+c*10
          lyric_text = lyric.try(:split, "]")[1] || ""
          lyric_text = lyric_text.try(:split, "&")[0] || ""
          lyric_arr = {"time" => mil_sec, "text" => lyric_text}
          aaa = "<SYNC Start=#{mil_sec}><P Class=KRCC>
#{lyric_text}
"
          form = form + aaa
        end
        puts(form)
        open("#{al_titles[m-1].content}.smi", 'w') { |f|
		f.puts "<SAMI>
		<HEAD>"
		f.puts title
		f.puts"</HEAD>
		<BODY>"
		f.puts form
		f.puts "
		</BODY>
		</SAMI>
		"
		}
        return "완료되었습니다. 한번 확인해보세요."
      else
        raise "Cannot post"
      end
    rescue Exception => e
      return "Error occured at #{e.backtrace.inspect}: #{e.message}"
    end
#   return res.body
  end
end
