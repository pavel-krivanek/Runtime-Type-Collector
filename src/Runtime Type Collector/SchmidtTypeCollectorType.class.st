"
Collected type description.
"
Class {
	#name : 'SchmidtTypeCollectorType',
	#superclass : 'Object',
	#instVars : [
		'typeClass',
		'nullable'
	],
	#category : 'Runtime Type Collector',
	#package : 'Runtime Type Collector'
}

{ #category : 'private' }
SchmidtTypeCollectorType class >> collectorTypesArrayFrom: aLiteral [

	| coll |
	
	coll := aLiteral isArray
		ifTrue: [ aLiteral ] 
		ifFalse: [ { aLiteral } ].
		
	^ coll collect: [ :each | self fromLiteral: each ]
]

{ #category : 'instance creation' }
SchmidtTypeCollectorType class >> commonSuperclassOf: classes [ 

	| current |
	
	current := classes first.
	
	classes allButFirstDo: [ :eachClass |
		current := eachClass withAllSuperclasses detect: [ :class | (current withAllSuperclasses includes: class) ] ifNone: eachClass
	].

	(current inheritsFrom: Integer) ifTrue: [ ^ Integer ].
	(current inheritsFrom: String) ifTrue: [ ^ String ].
	(current inheritsFrom: Boolean) ifTrue: [ ^ Boolean ].
	(current inheritsFrom: PdmDirectSystem) ifTrue: [ ^ IPdmSystem ].
	(current inheritsFrom: PdmDirectDatabase) ifTrue: [ ^ IDatabaseSubsystem ].
	(current inheritsFrom: PdmStandardNames) ifTrue: [ ^ INamesResolver ].
	(current inheritsFrom: PdmProjectDictionary) ifTrue: [ ^ IProjectDictionary ].
	(current inheritsFrom: PdmStatusTracker) ifTrue: [ ^ IStatusTracker ].

	^ current
	

]

{ #category : 'instance creation' }
SchmidtTypeCollectorType class >> fromLiteral: aLiteral [

	^ (self fromLiteralAsArray: aLiteral) asSet
]

{ #category : 'instance creation' }
SchmidtTypeCollectorType class >> fromLiteralAsArray: aLiteral [

	| typeClass nullable |
		

	aLiteral isArray ifFalse: [ 
		typeClass := (Smalltalk classNamed: (aLiteral withoutSuffix: '::') asSymbol) ifNil: [ self error: 'Unknown class "', aLiteral asString, '"'].
		nullable := aLiteral endsWith: '::'.
		(typeClass = BlockClosure or: [typeClass inheritsFrom: BlockClosure ])
			ifTrue: [ 
				^  { RuntimeTypeCollectorBlockType fromClass: typeClass argumentClasses: #() nullable: nullable} asSet 
			].
		^ { RuntimeTypeCollectorSimpleType fromClass: typeClass nullable: nullable} asSet
	].

	(aLiteral notEmpty and: [ aLiteral first isArray not ]) ifTrue: [ 

		typeClass := (Smalltalk classNamed: (aLiteral first withoutSuffix: '::') asSymbol) ifNil: [ self error: 'Unknown class "', aLiteral asString, '"'].
		nullable := aLiteral first endsWith: '::'.

		(aLiteral size = 1 and: [typeClass = FullBlockClosure]) ifTrue: [ ^ { RuntimeTypeCollectorBlockType fromClass: FullBlockClosure argumentClasses: #() nullable: nullable} asSet ].

		"collection"
		(aLiteral size = 3 and: [ (aLiteral second = #of) ])
			ifTrue: [  ^ { RuntimeTypeCollectorCollectionType fromClass: typeClass itemClasses:  (self fromLiteral: aLiteral third) nullable: nullable}  ].

		"dictionary"		
		(aLiteral size = 5 and: [ (aLiteral second = #of) and: [aLiteral fourth = #keys] ])
			ifTrue: [ ^ { RuntimeTypeCollectorDictionaryType fromClass: typeClass itemClasses:  (self fromLiteral: aLiteral third) keyClasses: (self fromLiteral: aLiteral fifth) nullable: nullable}  ].

		"association"		
		(aLiteral size = 5 and: [ (aLiteral second = #key) and: [aLiteral fourth = #value] ])
			ifTrue: [ ^ { RuntimeTypeCollectorAssociationType fromClass: typeClass keyClasses:  (self fromLiteral: aLiteral third) valueClasses: (self fromLiteral: aLiteral fifth) nullable: nullable} ].
			
		"blocks"
		(aLiteral size = 5 and: [ (aLiteral second = #arguments) and: [aLiteral fourth = #returning] ])
			ifTrue: [ ^ { RuntimeTypeCollectorBlockType fromClass: typeClass argumentClasses:  (self collectorTypesArrayFrom: aLiteral third) returnClasses: (self fromLiteral: aLiteral fifth) nullable: nullable}  asSet ].

		(aLiteral size = 3 and: [ (aLiteral second = #arguments) ])
			ifTrue: [ ^ { RuntimeTypeCollectorBlockType fromClass: typeClass argumentClasses:  (self collectorTypesArrayFrom: aLiteral third) nullable: nullable}  ].

		(aLiteral size = 3 and: [ aLiteral second = #returning])
			ifTrue: [ ^ { RuntimeTypeCollectorBlockType fromClass: typeClass returnClasses: (self fromLiteral: aLiteral third) nullable: nullable} ].
		
	].

	^ aLiteral flatCollect: [ :each |
		self fromLiteral: each.
	] as: Array

]

{ #category : 'utilities' }
SchmidtTypeCollectorType class >> mergeAll: typesCollection [ 

	| merged array |
	
	typesCollection ifEmpty: [ ^ typesCollection ].
	
	array := typesCollection collect: [ :each | each preMerge ] as: Array.
	merged := array first.
	array allButFirstDo: [ :each | 
		merged := merged mergeWith: each ].
	
	^ Set with: merged
	
]

{ #category : 'utilities' }
SchmidtTypeCollectorType class >> mergeAll: typesCollection with: anotherCollection [ 

	^ self mergeAll: typesCollection, anotherCollection.
	
]

{ #category : 'comparing' }
SchmidtTypeCollectorType >> <= b [ 

	^ typeClass name <= b typeClass name
]

{ #category : 'comparing' }
SchmidtTypeCollectorType >> = anObject [

	^ self class = anObject class
		and: [ typeClass = anObject typeClass ]
]

{ #category : 'visiting' }
SchmidtTypeCollectorType >> acceptVisitor: aVisitor [
	self subclassResponsibility
]

{ #category : 'accessing' }
SchmidtTypeCollectorType >> beNullable [ 

	self nullable: true
]

{ #category : 'comparing' }
SchmidtTypeCollectorType >> hash [

	^ self class hash bitXor: typeClass hash
]

{ #category : 'serialization' }
SchmidtTypeCollectorType >> initialize [ 
	super initialize.
	self nullable: false.
]

{ #category : 'serialization' }
SchmidtTypeCollectorType >> isAssociationType [

	^ false
]

{ #category : 'serialization' }
SchmidtTypeCollectorType >> isBlockType [

	^ false
]

{ #category : 'serialization' }
SchmidtTypeCollectorType >> isCollectionType [

	^ false
]

{ #category : 'serialization' }
SchmidtTypeCollectorType >> isDictionaryType [

	^ false
]

{ #category : 'serialization' }
SchmidtTypeCollectorType >> isSimpleType [

	^ false
]

{ #category : 'accessing' }
SchmidtTypeCollectorType >> mergedSimplyOrNilWith: collectorType [

	"returns association:
	  key: merge result or nil if we can try to merge further
	  value: common superclass or nil"
	
	| commonSuperclass |

	(self typeClass = UndefinedObject) ifTrue: [ ^ (collectorType nullable: true)->nil ].
	(collectorType typeClass = UndefinedObject) ifTrue: [ ^ (self nullable: true)->nil ].

	commonSuperclass := self class commonSuperclassOf: {self typeClass. collectorType typeClass}.
	
	(self class acceptsClass: commonSuperclass) 
		ifFalse: [ 
			^ (RuntimeTypeCollectorSimpleType fromClass: commonSuperclass nullable: (self nullable or: collectorType nullable)) -> nil ].
			
	^ nil->commonSuperclass
]

{ #category : 'accessing' }
SchmidtTypeCollectorType >> nullable [

	^ nullable
]

{ #category : 'accessing' }
SchmidtTypeCollectorType >> nullable: anObject [

	nullable := anObject
]

{ #category : 'serialization' }
SchmidtTypeCollectorType >> preMerge [ 

	"merge own subtypes"
	
	^ self copy
]

{ #category : 'accessing' }
SchmidtTypeCollectorType >> typeClass [

	^ typeClass
]

{ #category : 'accessing' }
SchmidtTypeCollectorType >> typeClass: anObject [

	typeClass := anObject
]
