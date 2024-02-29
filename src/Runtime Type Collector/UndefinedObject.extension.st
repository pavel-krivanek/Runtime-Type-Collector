Extension { #name : 'UndefinedObject' }

{ #category : '*Runtime Type Collector' }
UndefinedObject >> asRuntimeTypeCollectorTypeIn: aCollectorForMethod [ 

	^ RuntimeTypeCollectorSimpleType fromClass: self class nullable: true
]
