Extension { #name : 'Dictionary' }

{ #category : '*Runtime Type Collector' }
Dictionary >> asRuntimeTypeCollectorTypeIn: aCollectorForMethod [ 

	^ RuntimeTypeCollectorDictionaryType fromDictionary: self in: aCollectorForMethod 
]
