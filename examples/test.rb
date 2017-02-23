require 'tk'
require 'tkextlib/tile'
require 'net/http'
require 'uri'
require 'active_support/core_ext/object/try'

Tk::TK_PATCHLEVEL

root = TkRoot.new {title "알송 가사 자막 변환 프로그램"}
content = Tk::Tile::Frame.new(root) {padding "3 3 12 12"}.grid( :sticky => 'nsew')
TkGrid.columnconfigure root, 0, :weight => 1; TkGrid.rowconfigure root, 0, :weight => 1

$song_title = TkVariable.new; $song_artist = TkVariable.new; $result = TkVariable.new

#f = Tk::Tile::Entry.new(content) {width 7; textvariable $feet}.grid( :column => 2, :row => 1, :sticky => 'we' )
t = Tk::Tile::Entry.new(content) {width 20; textvariable $song_title}.grid( :column => 2, :row => 1, :sticky => 'we' )
a = Tk::Tile::Entry.new(content) {width 20; textvariable $song_artist}.grid( :column => 2, :row => 2, :sticky => 'we' )
Tk::Tile::Label.new(content) {textvariable $result}.grid( :column => 2, :row => 3, :sticky => 'we');
Tk::Tile::Button.new(content) {text '자막 추출'; command {calculate}}.grid( :column => 3, :row => 4, :sticky => 'w')

Tk::Tile::Label.new(content) {text '노래 제목'}.grid( :column => 1, :row => 1, :sticky => 'w')
Tk::Tile::Label.new(content) {text '가수'}.grid( :column => 1, :row => 2, :sticky => 'w')


TkWinfo.children(content).each {|w| TkGrid.configure w, :padx => 5, :pady => 5}
t.focus
root.bind("Return") {calculate}

def calculate
  begin
     $result.value = Alsong.get_lyrics $song_title, $song_artist
  rescue
     
  end
end

module Alsong
  $alsong_uri = URI.parse 'http://lyrics.alsong.co.kr/alsongwebservice/service1.asmx'

  def Alsong.get_lyrics title, artist


    xml_string = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://www.w3.org/2003/05/soap-envelope" xmlns:SOAP-ENC="http://www.w3.org/2003/05/soap-encoding" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:ns2="ALSongWebServer/Service1Soap" xmlns:ns1="ALSongWebServer" xmlns:ns3="ALSongWebServer/Service1Soap12"><SOAP-ENV:Body><ns1:GetResembleLyric2><ns1:stQuery><ns1:strTitle>' + title + '</ns1:strTitle><ns1:strArtistName>' + artist + '</ns1:strArtistName><ns1:nCurPage>0</ns1:nCurPage></ns1:stQuery></ns1:GetResembleLyric2></SOAP-ENV:Body></SOAP-ENV:Envelope>'
    req = Net::HTTP::Post.new $alsong_uri.request_uri
    # Content-Type := type "/" subtype *[";" parameter] 
    req.content_type = "text/xml;charset=utf-8"
    req.body = xml_string

    res = Net::HTTP.start $alsong_uri.hostname, $alsong_uri.port do |session|
      session.request req
    end


    begin
      case res
      when Net::HTTPSuccess
        raise "Empty response" if res.body.nil? or res.body.empty?

        resarr = Array.new
        form = ""
        
        song_title = res.body.try(:split, "<strTitle>")[1] || ""
        song_title = song_title.try(:split, "</strTitle>")[0] || ""
        song_artist = res.body.try(:split, "<strArtistName>")[1] || ""
        song_artist = song_artist.try(:split, "</strArtistName>")[0] || ""
        song_album = res.body.try(:split, "<strAlbumName>")[1] || ""
        song_album = song_album.try(:split, "</strAlbumName>")[0] || ""
        # Hash for to_json
        song_info = {"title" => song_title.force_encoding('UTF-8'), "artist" => song_artist.force_encoding('UTF-8'), "album" => song_album.force_encoding('UTF-8')}
        resarr.push song_info

        title = "<Title>#{song_title}</Title>"
                
        lyrics = res.body.try(:split, "<strLyric>")[1] || ""
        lyrics = lyrics.try(:split, "</strLyric>")[0] || ""
        lyrics = lyrics.try(:split, "br") || ""
        # debugging

        lyrics.pop

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
          lyric_arr = {"time" => mil_sec, "text" => lyric_text.force_encoding('UTF-8')}
          aaa = "<SYNC Start=#{mil_sec}><P Class=KRCC>
#{lyric_text.force_encoding('UTF-8')}
"
		  form = form + aaa
          resarr.push lyric_arr

#         puts lyric_time_ + " / " + i.to_s
        end

        if title == ""
        	return "검색 결과가 없습니다."
        end

        open("#{song_title.force_encoding('UTF-8')}.smi", 'w') { |f|
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


        #resarr.to_json
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


Tk.mainloop