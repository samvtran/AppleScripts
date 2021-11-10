#@osa-lang:AppleScript

(*
	Sets a custom metadata item called zettelkastenid to the 14 digit epoch time used for my
	unique Zettelkasten ids.
*)

use dt : script "devonthink"

on performSmartRule(theRecords)
	tell application id "DNtp"
		repeat with theRecord in theRecords
			set theName to (name of theRecord) as string
			set zettel to (dt's getZettel:theName)
			set theRecord's name to zettelName of zettel
			set theRecord's aliases to zettelId of zettel
			add custom meta data (zettelId of zettel) for "zettelkastenid" to theRecord
			log message "Set Zettelkasten id" info (zettelName of zettel)
		end repeat
	end tell
end performSmartRule