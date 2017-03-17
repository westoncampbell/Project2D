logError( text, from, severity )
{
	static errorLog := fileOpen( "error.log", "w", "Utf-8" )
	errorLog.writeLine( [ "Hint", "Warning", "Error", "Fatal ERROR" ][ severity ] . "; from:" . from . "; description:" . text . "`r`n" )
	if ( severity = 4 )
		ExitApp, 1
}