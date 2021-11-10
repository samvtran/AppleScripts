#@osa-lang:AppleScript
use AppleScript version "2.4" -- Yosemite (10.10) or later
use scripting additions
use framework "Foundation"
use zt : script "zettel"

return zt's zettelFromDate:(current date)