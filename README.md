## iTunesToTrakt
Applescript for marking your latest seen TV shows and movies in iTunes as seen on Trakt. 

I use iTunes to watch my favorite TV shows, and I wanted to automatically mark seen episodes on <http://trakt.tv> so I wrote this applescript to get that done. 

I'm no Applescript guru but it works for me.

### Usage:
I made it as a command line script so I can put it in crontab to run every hour. 
It need 4 arguments, in the correct order 

- number of hours from now to search for (last played date in iTunes) 
- your trakt.tv apikey 
- your trakt.tv username 
- sha1 of your trakt.tv password 

example:
`osascript iTunesToTrakt.applescript 1 apikey username sha1password`
