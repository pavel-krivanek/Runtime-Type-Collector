"
Runtime Type Collector.
"
Class {
	#name : 'RuntimeTypeCollector',
	#superclass : 'Object',
	#instVars : [
		'methodCollectors',
		'slotTypes',
		'useBlockArgPrefix',
		'merging'
	],
	#category : 'Runtime Type Collector',
	#package : 'Runtime Type Collector'
}

{ #category : 'as yet unclassified' }
RuntimeTypeCollector class >> wellKnownNotReturningBlockMessages [

	^ #(do:)
]

{ #category : 'as yet unclassified' }
RuntimeTypeCollector class >> wellKnownReturningBlockMessages [

	^ #(select: collect: reject:)
]

{ #category : 'API' }
RuntimeTypeCollector >> finish [ 

	methodCollectors do: [ :each | each remove ].
	MetaLink uninstallAll.
	self rebuildSets.
]

{ #category : 'API' }
RuntimeTypeCollector >> generate [ 

	methodCollectors do: [ :collector |
		| pragmaManager orderedBlocks |
		pragmaManager := (RuntimeTypeCollectorPragmaManager for: collector method).
		orderedBlocks := collector orderedBlocks.

		self generateReturnTypesIn: collector manager: pragmaManager.
		self generateArgTypesIn: collector manager: pragmaManager.
		self generateTempTypesIn: collector manager: pragmaManager.
		self generateBlockArgTypesIn: collector manager: pragmaManager.
		self generateBlockInformationIn: collector manager: pragmaManager blocks: orderedBlocks.
	].

	self generateSlotTypes.
]

{ #category : 'generation' }
RuntimeTypeCollector >> generateArgTypesIn: collector manager: pragmaManager [

	"keep the order"
	collector method argumentNames do: [ :argName |
		collector collectedArgClasses at: argName ifPresent: [ :types |
			pragmaManager replacePragma: #arg:type:generated: argument: argName with: ('<arg: {1} type: {2} generated: true>' format: { argName storeString. self typeStringFor: types  }).
		] 
	].
]

{ #category : 'generation' }
RuntimeTypeCollector >> generateBlockArgTypesIn: collector manager: pragmaManager [

	collector collectedBlockArgClasses keys sorted do: [ :argName |
		| types |
		types := collector collectedBlockArgClasses at: argName.
		pragmaManager replacePragma: #blockArg:type:generated: argument: argName with: ('<blockArg: {1} type: {2} generated: true>' format: { argName storeString. self typeStringFor: types  }).
	] 

]

{ #category : 'generation' }
RuntimeTypeCollector >> generateBlockInformationIn: collector manager: pragmaManager blocks: orderedBlocks [.

	orderedBlocks do: [ :assoc |
		| num type |
		num := assoc key.
		type := assoc value.
		type wasUsed 
			ifTrue: [ 
				pragmaManager replacePragma: #block:returnsValue:generated: argument: num with: ('<block: {1} returnsValue: {2} generated: true>' format: { num storeString. type wasUsed storeString}) ]
			ifFalse: [ 
				pragmaManager ensureDeletePragma: #block:returnsValue:generated: argument: num.
			]
		]
]

{ #category : 'generation' }
RuntimeTypeCollector >> generateReturnTypesIn: collector manager: pragmaManager [

	collector collectedReturnClasses ifNotEmpty: [ 		
		pragmaManager replacePragma: #returns:generated: with: ('<returns: {1} generated: true>' format: { self typeStringFor: collector collectedReturnClasses  }).
	]
]

{ #category : 'generation' }
RuntimeTypeCollector >> generateSlotTypes [

	slotTypes keysAndValuesDo: [ :class :slotDict |
		| descriptionMethod pragmaManager | 
		descriptionMethod := self typeDescriptionMethodIn: class.
		pragmaManager := (RuntimeTypeCollectorPragmaManager for: descriptionMethod).
		slotDict keysAndValuesDo: [ :key :types |
			pragmaManager replacePragma: #slot:type:generated: argument: key with: ('<slot: {1} type: {2} generated: true>' format: { key storeString. self typeStringFor: types  }).			
		]
	].
	
]

{ #category : 'generation' }
RuntimeTypeCollector >> generateTempTypesIn: collector manager: pragmaManager [

	collector method tempNames do: [ :tempName |
		collector collectedTempClasses at: tempName ifPresent: [ :types |
			pragmaManager replacePragma: #var:type:generated: argument: tempName with: ('<var: {1} type: {2} generated: true>' format: { tempName storeString. self typeStringFor: types  }).
		] 
	].

]

{ #category : 'initialization' }
RuntimeTypeCollector >> initialize [ 

	super initialize.
	
	slotTypes := Dictionary new.
	useBlockArgPrefix := false.
	merging := true.
]

{ #category : 'API' }
RuntimeTypeCollector >> installOnPackageNamed: packageName mode: mode [

	"mode: #variables, #returnValues"
	
	self prepareOnPackageNamed: packageName mode: mode.

	methodCollectors do: [ :each | each install ].
	
	

	
]

{ #category : 'utility' }
RuntimeTypeCollector >> mergeAll [ 

	methodCollectors do: [ :each | each mergeAll. ].
	
	slotTypes := slotTypes collect: [ :slotDict |
		slotDict collect: [ :types | RuntimeTypeCollectorType mergeAll: types. ] ]
]

{ #category : 'accessing' }
RuntimeTypeCollector >> merging [

	^ merging
]

{ #category : 'accessing' }
RuntimeTypeCollector >> merging: anObject [

	merging := anObject
]

{ #category : 'utility' }
RuntimeTypeCollector >> newTypesSet [ 

	^ IdentitySet new.
]

{ #category : 'API' }
RuntimeTypeCollector >> prepareOnPackageNamed: packageName mode: mode [

	"mode: #variables, #returnValues"
	
	| methods |
	
	methods := packageName asPackage methods.
	methods := methods reject: [ :each | each methodClass = Context ].

	methodCollectors := methods collect: [ :method |
		(RuntimeTypeCollectorForMethod forMethod: method)
			collector: self;
			mode: mode;
			yourself
	].

	merging ifTrue: [ 
		"not only defined classes but all classes"
		packageName asPackage classes do: [ :aClass |
		self readCurrentSlotTypesFromPragmasFor: aClass ]
	].

	
]

{ #category : 'utility' }
RuntimeTypeCollector >> readAllCurrentTypesFromPragmas [ 

	methodCollectors do: [ :each | each readCurrentTypesFromPragmas. ]
]

{ #category : 'method collector cooperation' }
RuntimeTypeCollector >> readCurrentSlotTypesFromPragmasFor: aClass [

	| methodName |
	
	methodName := self typeDescriptionMethodName.
		
	(aClass includesSelector: methodName)
		ifFalse: [ ^ self ].
	
	(aClass >> methodName) pragmas do: [ :pragma | 
		(#(slot:type: slot:type:generated:) includes: pragma selector) 
			ifTrue: [ 
				((slotTypes at: aClass ifAbsentPut: [ Dictionary new ])
					at: pragma arguments first asSymbol ifAbsentPut: [ self newTypesSet ])
					addAll: (self typeSetWith: (RuntimeTypeCollectorType fromLiteral: pragma arguments second)).
		].
	]
]

{ #category : 'utility' }
RuntimeTypeCollector >> rebuildSets [

	| new |
	new := Dictionary new.
	slotTypes keysAndValuesDo: [ :aClass :slots |
		| slotsDict |
		slotsDict := Dictionary new.
		slots keysAndValuesDo: [ :slot :value |
			| newSet |
			newSet := Set new.
			slotsDict at: slot put: value asArray asSet ].
		new at: aClass put: slotsDict.
	].

	slotTypes := new.
]

{ #category : 'method collector cooperation' }
RuntimeTypeCollector >> recordSlotWrite: slotName inClass: aClass type: aType [ 

	((slotTypes at: aClass ifAbsentPut: [ Dictionary new ])
		at: slotName ifAbsentPut: [ self newTypesSet ])
			add: aType
]

{ #category : 'type description methods' }
RuntimeTypeCollector >> typeDescriptionMethodIn: aClass [

	| methodName |
	
	methodName := self typeDescriptionMethodName.
		
	(aClass includesSelector: methodName)
		ifFalse: [
			aClass compile: methodName, '
	' classified: '_TYPES'].

	 ^ aClass >> methodName  
]

{ #category : 'type description methods' }
RuntimeTypeCollector >> typeDescriptionMethodName [

	^ '_slotTypes' asSymbol
]

{ #category : 'utility' }
RuntimeTypeCollector >> typeSetWith: typeOrTypes [

	| set |
	
	set := self newTypesSet.
	
	typeOrTypes isCollection 
		ifTrue: [ set addAll: typeOrTypes ]
		ifFalse: [ set add: typeOrTypes ].
	
	^ set
		
]

{ #category : 'utility' }
RuntimeTypeCollector >> typeStringFor: aTypeOrTypes [ 

	| visitor |
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: aTypeOrTypes.
	^ visitor content
]

{ #category : 'accessing' }
RuntimeTypeCollector >> useBlockArgPrefix [

	^ useBlockArgPrefix
]

{ #category : 'accessing' }
RuntimeTypeCollector >> useBlockArgPrefix: anObject [

	useBlockArgPrefix := anObject
]
