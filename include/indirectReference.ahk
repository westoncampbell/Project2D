class indirectReference
{
	
	/*
		CLASS indirectReference
		author:			nnnik
		
		description:	A class that is able to create safe indirect references that allow access to an object without creating a reference.
		This allows AutoHotkey to perform deletion of Object once all direct references are freed.
		You can use this to avoid circular references.
		
		usage:				newIndirectReference := new indirectReference( object, modes := { __Set:0, __Get:0, __Delete:0 } )
		
		newIndirectReference:	The indirect reference towards the objects passed to the constructor
		
		object:				The object you want to refer to indirectly
	*/
	
	__New( Object, modes = "" )
	{
		if !( modes )
		{
			if !indirectReference.storage.hasKey( &Object )
			{
				This.base                            := { __Call:indirectReference.connectBase.__Call, __Delete:indirectReference.removeFromStorage , base:{ __Delete: indirectReference.__Delete } }
				indirectReference.storage[ &Object ] :=	This
				indirectReference.storage2[ &This ]  := &Object
				directReference.enter( This, Object )
			}
			return indirectReference.storage[ &Object ]
		}
		for each, value in modes
			modes[ each ] := indirectReference.connectBase[ each ]
		modes.base := { __Delete:indirectReference.__Delete }
		This.base  := modes
		directReference.enter( This, Object )
	}
	
	static storage 	:= {}
	static storage2	:= {}
	static connectBase	:= { __Call:indirectReference.Call, __Set:indirectReference.Set, __Get:indirectReference.Get, __New:indirectReference.New, __Delete:indirectReference.Delete }
	
	Call( functionName = "", parameters* )
	{
		if !indirectReference.connectBase.hasKey( functionName )
			return ( new directReference( This ) )[ functionName ]( parameters* )
	}
	
	Set( keyAndValue* )
	{
		Value := keyAndValue.Pop()
		return ( new directReference( This ) )[ keyAndValue* ] := Value 
	}
	
	Get( key* )
	{
		return ( new directReference( This ) )[ key* ]
	}
	
	New( parameters* )
	{
		newIndirectReference := This.base
		This.base := ""
		return new ( new directReference( newIndirectReference ) )( parameter* )
	}
	
	Delete()
	{
		ret := ( new directReference( This ) ).__Delete()
		continueChain( This, "__Delete", A_ThisFunc )
		return ret
	}
	
	__Delete()
	{
		This.base := ""
	}
	
	removeFromStorage()
	{
		pObj := indirectReference.storage2[ &This ]
		indirectReference.storage2.Delete( &This )
		indirectReference.storage.Delete( pObj )
		continueChain( This, "__Delete", A_ThisFunc )
	}
	
}

class directReference
{
	
	
	/*
		CLASS directReference
		description:		creates direct References from indirect ones.
		
		usage:			object := new directReference( newIndirectReference )
		
		object:			The inderect Reference you want to resolve
	*/
	
	static storage  := {}
	static storage2 := {}
	
	__New( newIndirectReference )
	{
		if directReference.storage.hasKey( &newIndirectReference )
			return Object( directReference.storage[ &newIndirectReference ] )
	}
	
	enter( newIndirectReference, Object )
	{
		if !This.storage.hasKey( &newIndirectReference )
			newIndirectReference.base		   := { __Delete:This.leaveIndirectReference, base:newIndirectReference.base }
		if !This.storage2.hasKey( &Object )
			Object.base					   := { __Delete:This.leaveObject, base:Object.base }
		This.storage[ &newIndirectReference ] := &Object
		This.storage2[ &Object, &newIndirectReference ] := &newIndirectReference
	}
	
	leaveObject()
	{
		ret := continueChain( This, "__Delete", A_ThisFunc )
		storage := directReference.storage2[ &This ]
		loop
		{
			each := ""
			for each,val in storage
			{
				Object( val ).__Delete()
				if storage.hasKey( each )
					storage.Delete( each )
			}
		}Until !each
		return ret
	}
	
	leaveIndirectReference()
	{
		ret := continueChain( This, "__Delete", A_ThisFunc )
		pObj := directReference.storage[ &This ]
		directReference.storage.Delete( &This )
		directReference.storage2[ pObj ].Delete( &This )
		return ret
	}
	
}

continueChain( object, methodName, functionName, parameters* )
{
	obj := object
	While ( isObject( obj ) && !( obj.hasKey( methodName ) && obj[ methodName ].name = functionName ) )
		obj := obj.base
	obj := obj.base
	While ( isObject( obj ) && !( obj.hasKey( methodName ) && isFunc( obj[ methodName ] ) ) )
		obj := obj.base
	if isFunc( obj[ methodName ] )
		return obj[ methodName ].Call( object, parameters* )
}