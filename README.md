# alsong-lyrics-subtitle

알송 가사를 파싱해서 자막 파일인 .smi로 저장하는 모듈입니다. [Ruby 프로그래밍 언어](https://github.com/ruby/ruby)로 작성되었으며, Dogdriip님의 alsong-lyrics-parser를 참고하였습니다.

## 사용법
alsong.rb 모듈을 require하여 사용할 수 있습니다.
```
require '../modules/alsong'
```
## Alsong.get_lyrics(title, artist)
가사를 검색하여 smi 파일로 돌려줍니다.

* title: 가사를 검색하려는 노래의 제목
* artist: 가사를 검색하려는 노래의 아티스트

예제:

```ruby 
puts Alsong.get_lyrics "M@STERPIECE", " "
puts Alsong.get_lyrics "Never gonna give you up", "Rick Astley"
```
> 정확한 아티스트 명을 모를 때에는 공백으로 전달해도 됩니다.

## 참고
* 알송 (http://www.altools.co.kr/Brand/Alsong/)
* alsong-lyrics-parser (https://github.com/Dogdriip/alsong-lyrics-parser)