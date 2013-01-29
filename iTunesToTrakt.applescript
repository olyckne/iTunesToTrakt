#!/usr/bin/osascript

on run argv
	set interval to item 1 of argv as number
	set apiKey to item 2 of argv as string
	set username to item 3 of argv as string
	set pass to item 4 of argv as string
	set baseUrl to "http://api.trakt.tv/"
	set episodeUrl to baseUrl & "show/episode/seen/" & apiKey
	set movieUrl to baseUrl & "movie/seen/" & apiKey
	set currDate to current date
	set currDate to currDate - (interval * hours)
	set userPass to "{\"username\" : \"" & username & "\", \"password\" : \"" & pass & "\","
	set sendUrl to ""
	tell application "iTunes"
		set theLists to every playlist whose special kind is TV Shows or special kind is Movies
		repeat with theList in theLists
			set allTracks to (every track of theList whose played date > currDate)
			repeat with aTrack in allTracks
				set played to played date of aTrack
				set typeOfTrack to video kind of aTrack
				set theYear to year of aTrack
				if played > currDate then
					if typeOfTrack = movie then
						set sendUrl to movieUrl
						set theMovieName to name of aTrack
						set nrOfPlays to played count of aTrack
						set lastPlayed to played date of aTrack
						set lastPlayed to do shell script "date -j -f \"%A %d %B %Y %H:%M:%S\" \"" & lastPlayed & "\" +%s"
						set sendData to userPass & "\"movies\" : [{\"title\" : \"" & theMovieName & "\", \"year\" : " & theYear & ", \"plays\" : " & nrOfPlays & ", \"last_played\" : " & lastPlayed & "}]"
					else if typeOfTrack is TV show then
						set sendUrl to episodeUrl
						set theShow to show of aTrack
						set theSeason to season number of aTrack
						set theEpisode to episode number of aTrack
						set sendData to userPass & "\"title\" : \"" & theShow & "\", \"year\" : " & theYear & ", \"episodes\" : [{ \"season\" : " & theSeason & ", \"episode\": " & theEpisode & "}]"
						
					end if
					set sendData to sendData & "}"
					
					set cmd to "curl " & sendUrl & " -X POST --data '" & sendData & "' -H 'Content-type: application/json'"
					tell me to do shell script cmd
				else
					return "No new movies or TV show episodes watched." as string
				end if
			end repeat
		end repeat
	end tell
end run