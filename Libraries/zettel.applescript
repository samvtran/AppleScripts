#@osa-lang:AppleScript
use AppleScript version "2.4" -- Yosemite (10.10) or later
use framework "Foundation"
use scripting additions

on zettelFromDate:aDate
	set theFormatter to current application's NSDateFormatter's new()
	theFormatter's setLocale:(current application's NSLocale's localeWithLocaleIdentifier:"en_US_POSIX")
	--theFormatter's setTimeZone:(current application's NSTimeZone's timeZoneWithAbbreviation:"GMT") -- skip for local time
	theFormatter's setDateFormat:"yyyyMMddHHmmss"
	return (theFormatter's stringFromDate:aDate) as text
end zettelFromDate: