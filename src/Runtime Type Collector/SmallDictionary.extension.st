Extension { #name : 'SmallDictionary' }

{ #category : '*Runtime Type Collector' }
SmallDictionary >> asRuntimeTypeCollectorTypeIn: aCollectorForMethod [ 

	^ RuntimeTypeCollectorDictionaryType fromDictionary: self in: aCollectorForMethod 
]
