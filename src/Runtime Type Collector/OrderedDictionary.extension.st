Extension { #name : 'OrderedDictionary' }

{ #category : '*Runtime Type Collector' }
OrderedDictionary >> asRuntimeTypeCollectorTypeIn: aCollectorForMethod [ 

	^ RuntimeTypeCollectorDictionaryType fromDictionary: self in: aCollectorForMethod 
]
