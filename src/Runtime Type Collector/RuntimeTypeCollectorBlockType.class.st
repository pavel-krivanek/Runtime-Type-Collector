"
Describes a block closure
"
Class {
	#name : 'RuntimeTypeCollectorBlockType',
	#superclass : 'SchmidtTypeCollectorType',
	#instVars : [
		'argumentClasses',
		'returnClasses',
		'wasUsed',
		'collector'
	],
	#category : 'Runtime Type Collector',
	#package : 'Runtime Type Collector'
}

{ #category : 'testing' }
RuntimeTypeCollectorBlockType class >> acceptsClass: aClass [ 

	^ aClass = BlockClosure or: [ aClass inheritsFrom: BlockClosure ]
]

{ #category : 'instance creation' }
RuntimeTypeCollectorBlockType class >> fromClass: aClass argumentClasses: argumentClasses nullable: nullable [

	^ self new 
		typeClass: aClass;
		argumentClasses: argumentClasses;
		wasUsed: false;
		nullable: nullable;
		yourself.
]

{ #category : 'instance creation' }
RuntimeTypeCollectorBlockType class >> fromClass: aClass argumentClasses: argumentClasses returnClasses: returnClasses nullable: nullable [

	^ self new 
		typeClass: aClass;
		argumentClasses: argumentClasses;
		returnClasses: returnClasses;
		wasUsed: true;
		nullable: nullable;
		yourself.
]

{ #category : 'instance creation' }
RuntimeTypeCollectorBlockType class >> fromClass: aClass returnClasses: returnClasses nullable: nullable [

	^ self new 
		typeClass: aClass;
		returnClasses: returnClasses;
		wasUsed: true;
		nullable: nullable;
		yourself.
]

{ #category : 'comparing' }
RuntimeTypeCollectorBlockType >> = anObject [

	^ super = anObject
		and: [ argumentClasses = anObject argumentClasses 
			and: [ returnClasses = anObject returnClasses 
				and: [ wasUsed = anObject wasUsed ] ] ]
]

{ #category : 'visiting' }
RuntimeTypeCollectorBlockType >> acceptVisitor: aVisitor [
	^ aVisitor visitBlockType: self
]

{ #category : 'accessing' }
RuntimeTypeCollectorBlockType >> addArgumentClasses: argClasses [ 

	argumentClasses size < argClasses size ifTrue: [
		| old |
		old := argumentClasses.
		argumentClasses := OrderedCollection ofSize: argClasses size.
		old withIndexDo: [ :val :index |
			argumentClasses at: index put: val 
		].
	].

	argClasses withIndexDo: [ :val :index |
		| set |
		set := argumentClasses at: index.
		set ifNil: [ 
			set := Set new.
			argumentClasses at: index put: set ].
		set add: (val asRuntimeTypeCollectorTypeIn: collector)
	]

]

{ #category : 'accessing' }
RuntimeTypeCollectorBlockType >> addReturnClass: aClass [ 

	^ returnClasses add: (aClass asRuntimeTypeCollectorTypeIn: collector)
]

{ #category : 'accessing' }
RuntimeTypeCollectorBlockType >> argumentClasses [

	^ argumentClasses
]

{ #category : 'accessing' }
RuntimeTypeCollectorBlockType >> argumentClasses: anObject [

	argumentClasses := anObject
]

{ #category : 'accessing' }
RuntimeTypeCollectorBlockType >> collector [

	^ collector
]

{ #category : 'accessing' }
RuntimeTypeCollectorBlockType >> collector: anObject [

	collector := anObject
]

{ #category : 'comparing' }
RuntimeTypeCollectorBlockType >> hash [

	^ ((super hash bitXor: argumentClasses hash)
	 bitXor: returnClasses hash)
	 bitXor: wasUsed hash
]

{ #category : 'initialization' }
RuntimeTypeCollectorBlockType >> initialize [ 

	super initialize.
	typeClass := FullBlockClosure.
	returnClasses := Set new.
	argumentClasses := OrderedCollection new.
	wasUsed := false.

]

{ #category : 'serialization' }
RuntimeTypeCollectorBlockType >> isBlockType [

	^ true
]

{ #category : 'accessing' }
RuntimeTypeCollectorBlockType >> markAsUsed [

	wasUsed := true.
]

{ #category : 'accessing' }
RuntimeTypeCollectorBlockType >> preMerge [ 

	| merged |
	
	merged := self copy.
	
	merged argumentClasses: (self argumentClasses collect: [ :arg | (self class mergeAll: arg) ]).
	merged returnClasses: (self class mergeAll: self returnClasses).
	
	^ merged 
]

{ #category : 'accessing' }
RuntimeTypeCollectorBlockType >> returnClasses [

	^ returnClasses
]

{ #category : 'accessing' }
RuntimeTypeCollectorBlockType >> returnClasses: anObject [

	returnClasses := anObject
]

{ #category : 'accessing' }
RuntimeTypeCollectorBlockType >> wasUsed [

	^ wasUsed
]

{ #category : 'accessing' }
RuntimeTypeCollectorBlockType >> wasUsed: anObject [

	wasUsed := anObject
]
