Class {
	#name : 'RuntimeCollectingFullBlockClosure',
	#superclass : 'FullBlockClosure',
	#type : 'variable',
	#instVars : [
		'collectorTypes'
	],
	#category : 'Runtime Type Collector',
	#package : 'Runtime Type Collector'
}

{ #category : 'instance creation' }
RuntimeCollectingFullBlockClosure class >> from: aFullBlockClosure [
]

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosure >> addCollectorType: aCollectorType [ 

	^ self collectorTypes add: aCollectorType 
]

{ #category : 'evaluating' }
RuntimeCollectingFullBlockClosure >> asRuntimeTypeCollectorTypeIn: aCollectorForMethod [ 

	"only register a new collector type"
	
	| collectorType |
	
	collectorType := RuntimeTypeCollectorBlockType new.
	collectorTypes add: collectorType.
	
	^ collectorType
	
]

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosure >> collectorTypes [

	^ collectorTypes ifNil: [ collectorTypes := OrderedCollection new ]
]

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosure >> collectorTypes: anObject [

	collectorTypes := anObject
]

{ #category : 'evaluating' }
RuntimeCollectingFullBlockClosure >> returnProxyFor: result [
	
	| proxy |

	collectorTypes do: [ :type | type addReturnClass: result class ].
	proxy := RuntimeCollectingFullBlockClosureResult basicNew _initialize 
		_collectorTypes: collectorTypes;
		_realValue: result.
	^ proxy 
]

{ #category : 'evaluating' }
RuntimeCollectingFullBlockClosure >> value [ 

	| result |
	result := super value.
	^ self returnProxyFor: result
]

{ #category : 'evaluating' }
RuntimeCollectingFullBlockClosure >> value: arg [

	| result |
	result := super value: arg.
	collectorTypes do: [ :type | type addArgumentClasses: { arg class } ].
	^ self returnProxyFor: result
]
