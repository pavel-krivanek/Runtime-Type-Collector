Extension { #name : 'ProtoObject' }

{ #category : '*Runtime Type Collector' }
ProtoObject >> _assigned [
]

{ #category : '*Runtime Type Collector' }
ProtoObject >> asRuntimeTypeCollectorTypeIn: aCollectorForMethod [ 

	^ RuntimeTypeCollectorSimpleType fromClass: self class nullable: false
]
