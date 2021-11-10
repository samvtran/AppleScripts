#@osa-lang:AppleScript
(*
	Import Bookends references as rtf documents. This script features a few different behaviors from the
	built-in "References from Bookends..." script:
	- Database and group path are customizable from this script
	- The reference naming and format are customizable
	- Refererences that have been deleted from Bookends can be flagged or moved to the trash (the default)
	- Attachments are added to the end of the rtf document in wiki link format; e.g., [[my attachment.pdf]].
	  This makes an indexed folder of Bookends attachments linkable and Incoming Links on each attachment
	  will show your rtf reference document. Neat!

	A few things to note that you may want to customize:
	- This script will set the user20 field on a Bookends reference to the DEVONthink URL for the reference document
*)

use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions
use dt : script "devonthink"

-- Set this to the DT database that will house your references
property databaseName : POSIX path of (path to home folder as string) & "Databases/Primary.dtBase2"

-- Set this to the DT group for your references. The group will be created for you if it doesn't exist.
property referencesPath : "/Library/References"

-- The format for naming the rtf reference documents. Defaults to a custom format which can be found in this git repo.
property referenceNameFormat : "DT Filename.fmt"

-- The bibliographic format used to populate the rtf document.
property referenceFormat : "DT Summary.fmt"

-- When false, deleted references are flagged. When true, they're moved to the trash.
property moveDeletedToTrash : true

on getName(theRef)
	tell application "Bookends"
		tell front window
			set theCitationName to format theRef using referenceNameFormat
			-- Name formats often include line breaks so just to avoid having to create a new format just
			-- for
			set theCitationName to do shell script "echo " & quoted form of theCitationName & " | sed ':a;N;$!ba;s/\\n/ /g'"
			return theCitationName
		end tell
	end tell
end getName

try
	-- Citations with new entries
	set referencesCreated to 0
	-- Citations that have existing DT entries that were updated
	set referencesUpdated to 0
	-- Citations that were already up-to-date based on the 
	set referencesUpToDate to 0
	
	tell application id "DNtp"
		set theDatabase to open database databaseName
		if not (exists record at referencesPath) then
			set theGroup to create location referencesPath in theDatabase
		else
			set theGroup to get record at referencesPath in theDatabase
		end if
		set citationIds to (dt's getGroupChildrenAsMutableArray(theDatabase, theGroup))
		set exisitingRecords to children of theGroup
	end tell
	
	tell application "Bookends" to tell front library window to set theRefs to publication items
	
	tell application id "DNtp" to set myProgress ¬
		to show progress indicator "Creating/updating citations..." steps count of theRefs
	
	repeat with theRef in theRefs
		repeat 1 times
			tell application "Bookends"
				set {theID, modDate} to {id, date modified} of theRef
			end tell
			
			tell application id "DNtp"
				set theUrl to "bookends://sonnysoftware.com/" & theID
				
				-- Look up existing references in the configured citation path
				set nextRecord to ((children in theGroup) whose URL is theUrl)
				
				if (count of nextRecord) is not 0 then
					-- Modify an existing reference
					set nextRecord to item 1 of nextRecord
					
					-- Now that we've seen this reference, remove it from the list of pending references
					dt's removeFromNSArray(id of nextRecord, citationIds)
					
					if modification date of nextRecord = modDate then
						--log "Skipping up-to-date record: " & theID
						set referencesUpToDate to referencesUpToDate + 1
						step progress indicator (name of nextRecord as string)
						exit repeat
					end if
					set referencesUpdated to referencesUpdated + 1
				else
					-- Create a new reference file
					set referencesCreated to referencesCreated + 1
					set nextRecord to create record with {content:"", type:rtf} in theGroup
					set dtUrl to reference URL of nextRecord
					set URL of nextRecord to theUrl
					tell application "Bookends"
						-- Points the user20 field of a reference to this DT item
						set user20 of theRef to dtUrl & "?reveal=1"
						set modDate to date modified of theRef
					end tell
				end if
			end tell
			
			tell application "Bookends"
				set theAttachments to (name of attachment items) of theRef
				set theCitationText to «event ToySGUID» theID given «class RRTF»:"false", string:referenceFormat
			end tell
			
			if (count of theAttachments) > 0 then
				set theCitationText to theCitationText & "

Attachments:"
			end if
			repeat with theAttachment in theAttachments
				set theCitationText to theCitationText & "
[[" & theAttachment & "]]"
			end repeat
			
			tell application id "DNtp"
				set theTitle to my getName(theRef)
				step progress indicator theTitle
				set name of nextRecord to theTitle
				set rich text of nextRecord to theCitationText
				set modification date of nextRecord to modDate
			end tell
		end repeat
	end repeat
	tell application id "DNtp"
		if moveDeletedToTrash then
			set citationsMissing to (dt's deleteItemsInNSArray(theDatabase, citationIds))
			set citationsMissing to citationsMissing & " moved to trash."
		else
			set citationsMissing to (dt's flagItemsInNSArray(theDatabase, citationIds))
			set citationsMissing to citationsMissing & " flagged as deleted."
		end if
		
		log message "Bookends import" info ((referencesCreated as string) & " added, " & (referencesUpdated as string) & " updated, " & referencesUpToDate & " up to date, " & citationsMissing)
		hide progress indicator
	end tell
on error theErrorMessage
	tell application id "DNtp"
		log message "Bookends import error" info theErrorMessage
		hide progress indicator
	end tell
end try
