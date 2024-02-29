Extension { #name : 'String' }

{ #category : '*Runtime Type Collector' }
String >> asRuntimeTypeCollectorTypeIn: aCollectorForMethod [ 

	^ RuntimeTypeCollectorSimpleType fromClass: self class
]
