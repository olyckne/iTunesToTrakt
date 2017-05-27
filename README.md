## iTunesToTrakt
Applescript for marking your latest seen TV shows and movies in iTunes as seen on Trakt. 

I use iTunes to watch my favorite TV shows, and I wanted to automatically mark seen episodes on <http://trakt.tv> so I wrote this applescript to get that done. 

I'm no Applescript guru but it works for me.

### Installation:
* First you need to create an app over at trakt.tv: https://trakt.tv/oauth/applications
* `cp .env.example .env`
* Edit `.env` with your credentials
* Run `osascript -l JavaScript iTunesToTrakt.applescript` to create token
* It will ask you to open an url in your browser and copy the shown pin code into the promp

### Usage:
`osascript -l JavaScript iTunesToTrakt.applescript`
