#@osa-lang:AppleScript
use AppleScript version "2.4" -- Yosemite (10.10) or later
use framework "Foundation"
use scripting additions

property regexString : "^[[:digit:]]{14}"

on getZettel:theName
	set cA to current application
	set theString to (cA's NSString's stringWithString:theName)
	set regex to cA's NSRegularExpression's regularExpressionWithPattern:regexString options:(cA's NSRegularExpressionCaseInsensitive) |error|:(missing value)
	set matches to regex's matchesInString:theString options:0 range:{0, theString's |length|()}
	
	if (count of matches) > 0 then
		set theMatch to matches's first item
		set matchRange to (theMatch's rangeAtIndex:0) as record
		set theFinalDate to (theString's substringWithRange:matchRange) as text
		set theFinalName to theName
	else
		set theFinalDate to (script "zettel"'s zettelFromDate:(current date))
		set theFinalName to (theFinalDate & " " & theName) as string
	end if
	
	return {zettelId:theFinalDate, zettelName:theFinalName}
end getZettel:

on getGroupChildrenAsMutableArray(theDatabase, theGroup)
	set knownGroups to (its NSMutableArray's alloc())'s init()
	
	tell application id "DNtp"
		if theGroup is not missing value then
			repeat with theItem in (children of theGroup)
				(knownGroups's addObject:id of theItem as integer)
			end repeat
		end if
	end tell
	
	return knownGroups
end getGroupChildrenAsMutableArray

on removeFromNSArray(val, array)
	array's removeObject:(val as integer)
end removeFromNSArray

on flagItemsInNSArray(theDatabase, theArray)
	set flaggedCount to 0
	tell application id "DNtp"
		repeat with recordId in (theArray as list)
			set flaggedItem to get record with id (recordId as integer) in theDatabase
			if flaggedItem is not missing value then
				set state of flaggedItem to true
				set flaggedCount to flaggedCount + 1
			end if
		end repeat
	end tell
	
	return flaggedCount
end flagItemsInNSArray

on deleteItemsInNSArray(theDatabase, theArray)
	set deletedCount to 0
	tell application id "DNtp"
		repeat with recordId in (theArray as list)
			set toDelete to get record with id (recordId as integer) in theDatabase
			if toDelete is not missing value then
				move record toDelete to trash group of theDatabase
				set deletedCount to deletedCount + 1
			end if
		end repeat
	end tell
	
	return deletedCount
end deleteItemsInNSArray