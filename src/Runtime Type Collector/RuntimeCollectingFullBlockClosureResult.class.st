Class {
	#name : 'RuntimeCollectingFullBlockClosureResult',
	#superclass : 'ProtoObject',
	#instVars : [
		'collectorTypes',
		'realValue'
	],
	#category : 'Runtime Type Collector',
	#package : 'Runtime Type Collector'
}

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosureResult >> = anObject [

	^ realValue = anObject 
]

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosureResult >> _addCcollectorType: anObject [

	collectorTypes add: anObject
]

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosureResult >> _assigned [

	collectorTypes do: [ :each | each markAsUsed ].
	^ realValue isReadOnlyObject  
		ifFalse: [ self becomeForward: realValue. ]
		ifTrue: [ self becomeForward: realValue copyHash: false ]
	

]

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosureResult >> _collectorTypes [

	^ collectorTypes
]

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosureResult >> _collectorTypes: anObject [

	collectorTypes := anObject
]

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosureResult >> _initialize [ 

	super initialize.
	collectorTypes := OrderedCollection new.
]

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosureResult >> _realValue [

	^ realValue
]

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosureResult >> _realValue: anObject [

	realValue := anObject
]

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosureResult >> doesNotUnderstand: aMessage [

	| oldSelf |
	oldSelf := self.
	self _assigned.
	"oldSelf become realValue"
	^ oldSelf perform: aMessage selector withArguments: aMessage arguments
	
]

{ #category : 'accessing' }
RuntimeCollectingFullBlockClosureResult >> hash [

	^ realValue hash
]
