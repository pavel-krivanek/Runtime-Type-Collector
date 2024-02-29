"
Manages Type Collector Metalinks for a single class.
"
Class {
	#name : 'RuntimeTypeCollectorForMethod',
	#superclass : 'Object',
	#instVars : [
		'mode',
		'collector',
		'targetMethod',
		'tempLinks',
		'argLink',
		'argNames',
		'returnLink',
		'blockArgLinks',
		'instVarLinks',
		'collectedTempClasses',
		'collectedArgClasses',
		'collectedReturnClasses',
		'collectedBlockArgClasses',
		'sequenceNodes',
		'originalSource',
		'blockInformation'
	],
	#category : 'Runtime Type Collector',
	#package : 'Runtime Type Collector'
}

{ #category : 'instance creation' }
RuntimeTypeCollectorForMethod class >> forMethod: aCompiledMethod [
	^ self new
		method: aCompiledMethod
]

{ #category : 'utility' }
RuntimeTypeCollectorForMethod >> allBlocks [ 

	^ (targetMethod ast allChildren select: [ :each | each isBlock ]) sorted: [ :a :b | a left <= b left ].
]

{ #category : 'utility' }
RuntimeTypeCollectorForMethod >> availableArgNames [

	^ targetMethod temporaryVariables select: [ :temp | temp isArgumentVariable ] thenCollect: [ :each | each name ]
]

{ #category : 'utility' }
RuntimeTypeCollectorForMethod >> availableTempNames [

	^ targetMethod temporaryVariables select: [ :temp | temp isTempVariable ] thenCollect: [ :each | each name ]
]

{ #category : 'metalink methods' }
RuntimeTypeCollectorForMethod >> blockArgInContext: aContext node: aNode [ 

	| index |
	index := (sequenceNodes indexOf: aNode).

	aNode parent argumentNames do: [ :argName | 
		| key value | 
		value := aContext tempNamed: argName.
		value _assigned.
		key := collector useBlockArgPrefix 
			ifTrue: [  ('_', index asString, '_', argName) asSymbol ]
			ifFalse: [ argName asSymbol ].
		(collectedBlockArgClasses at: key ifAbsentPut: [ self newTypesSet ])
				add: (value asRuntimeTypeCollectorTypeIn: self).
	]


]

{ #category : 'utility' }
RuntimeTypeCollectorForMethod >> blockNumber: blockNumber returnsValue: aBoolean [

	| blockNode type |
	blockNode := (self detectBlockWithNumber: blockNumber).
	type := RuntimeTypeCollectorBlockType new wasUsed: aBoolean. "stub"
	
	blockInformation at: blockNode put: type.
]

{ #category : 'collected values' }
RuntimeTypeCollectorForMethod >> collectedArgClasses [

	^ collectedArgClasses
]

{ #category : 'collected values' }
RuntimeTypeCollectorForMethod >> collectedBlockArgClasses [

	^ collectedBlockArgClasses
]

{ #category : 'collected values' }
RuntimeTypeCollectorForMethod >> collectedReturnClasses [ 

	^ collectedReturnClasses
]

{ #category : 'collected values' }
RuntimeTypeCollectorForMethod >> collectedTempClasses [

	^ collectedTempClasses
]

{ #category : 'accessing' }
RuntimeTypeCollectorForMethod >> collector [

	^ collector
]

{ #category : 'accessing' }
RuntimeTypeCollectorForMethod >> collector: anObject [

	collector := anObject
]

{ #category : 'blocks' }
RuntimeTypeCollectorForMethod >> compiledBlock: aCompiledBlock type: type [

	blockInformation at: aCompiledBlock put: type
]

{ #category : 'utility' }
RuntimeTypeCollectorForMethod >> detectBlockWithNumber: blockNumber [

	^ self allBlocks at: blockNumber
]

{ #category : 'initialization' }
RuntimeTypeCollectorForMethod >> initialize [

	super initialize.
	collectedTempClasses := IdentityDictionary new.
	collectedArgClasses := IdentityDictionary new.
	collectedBlockArgClasses := IdentityDictionary new.
	collectedReturnClasses := self newTypesSet.
	
	tempLinks := OrderedCollection new.
	instVarLinks := OrderedCollection new.
	sequenceNodes := OrderedCollection new.
	blockArgLinks := OrderedCollection new.
	blockInformation := Dictionary new.
	
	mode := #variables.
]

{ #category : 'metalink methods' }
RuntimeTypeCollectorForMethod >> instVarWriteInContext: aContext node: aNode [ 

	| varName value |

	varName := aNode variable name asSymbol.
	value := aContext receiver instVarNamed: varName.
	value _assigned.

	collector 
		recordSlotWrite: varName 
		inClass: targetMethod methodClass 
		type: (value asRuntimeTypeCollectorTypeIn: self).

]

{ #category : 'API' }
RuntimeTypeCollectorForMethod >> install [

	"Transcript show: 'Installing collector to '; show: targetMethod name; cr.
	World doOneCycle."
	
	originalSource := targetMethod sourceCode.

	collector merging ifTrue: [ 
		self readCurrentTypesFromPragmas ].
	
	mode = #variables 
		ifTrue: [ 
			self installTempLinks.
			self installArgLink.
			self installBlockArgLinks.
			self installInstVarLinks.
		].
	
	mode = #returnValues
		ifTrue: [ 		
			self installLeaveLink.
		]

]

{ #category : 'installing' }
RuntimeTypeCollectorForMethod >> installArgLink [

	argNames := self availableArgNames.
	
	argLink := self newArgLink.
	targetMethod ast link: argLink

]

{ #category : 'installing' }
RuntimeTypeCollectorForMethod >> installBlockArgLinks [

	targetMethod ast allSequenceNodes allButFirst do: [ :seqNode |
		| link |
		sequenceNodes add: seqNode.
		link := self newBlockArgLink.
		seqNode link: link.
	].
]

{ #category : 'installing' }
RuntimeTypeCollectorForMethod >> installInstVarLinks [

	targetMethod methodClass instanceVariables do: [ :var |
		| link varName |
		varName := var name.
		link := self newInstVarLink.
		targetMethod
			link: link
			toVariableNamed: varName
			option: #write.
		instVarLinks add: link
	].
	
]

{ #category : 'installing' }
RuntimeTypeCollectorForMethod >> installLeaveLink [

	returnLink := self newLeaveLink.
	targetMethod ast link: returnLink

]

{ #category : 'installing' }
RuntimeTypeCollectorForMethod >> installReturnLink [

	returnLink := self newLeaveLink.
	targetMethod ast link: returnLink

]

{ #category : 'installing' }
RuntimeTypeCollectorForMethod >> installTempLinks [

	| link |

	self availableTempNames do: [ :tempName |
		link := self newTempVarLink.
		targetMethod
			link: link
			toVariableNamed: tempName
			option: #write.
		tempLinks add: link
	].
		
			

]

{ #category : 'blocks' }
RuntimeTypeCollectorForMethod >> isWellKnownBlock: aBlockNode [

	^ aBlockNode parent isMessage and: [ 
		(RuntimeTypeCollector wellKnownReturningBlockMessages includes: aBlockNode parent selector) 
		or: [RuntimeTypeCollector wellKnownNotReturningBlockMessages includes: aBlockNode parent selector ]]
]

{ #category : 'metalink methods' }
RuntimeTypeCollectorForMethod >> leaveInContext: aContext node: aNode [ 

	| value |
	value := aContext top.
	value _assigned.

	collectedReturnClasses add: (value asRuntimeTypeCollectorTypeIn: self).
	
	"store types of all temporaries because collections may be changed in lifetime of the method"	

"	aContext method tempNames do: [ :tempName |
		(collectedTempClasses at: tempName ifAbsentPut: [ Set new ])
			add: (aContext tempNamed: tempName) asPdmTypeCollectorType.
	]
"	
]

{ #category : 'API' }
RuntimeTypeCollectorForMethod >> mergeAll [ 

	collectedReturnClasses := SchmidtTypeCollectorType mergeAll: collectedReturnClasses.
	
	collectedArgClasses := collectedArgClasses collect: [ :types |
		SchmidtTypeCollectorType mergeAll: types. ].
	
	collectedTempClasses := collectedTempClasses collect: [ :types |
		SchmidtTypeCollectorType mergeAll: types. ].
	
	collectedBlockArgClasses := collectedBlockArgClasses collect: [ :types |
		SchmidtTypeCollectorType mergeAll: types. ].
	
	

]

{ #category : 'accessing' }
RuntimeTypeCollectorForMethod >> method [ 

	^ targetMethod
]

{ #category : 'accessing' }
RuntimeTypeCollectorForMethod >> method: anObject [
	targetMethod := anObject
]

{ #category : 'accessing' }
RuntimeTypeCollectorForMethod >> mode [

	^ mode
]

{ #category : 'accessing' }
RuntimeTypeCollectorForMethod >> mode: anObject [

	mode := anObject
]

{ #category : 'links' }
RuntimeTypeCollectorForMethod >> newArgLink [
	"for now it should just halt in base level"

	^ MetaLink new
		  metaObject: self;
		  selector: #valueInContext:node:;
		  arguments: #(#context #node)
]

{ #category : 'links' }
RuntimeTypeCollectorForMethod >> newBlockArgLink [
	"for now it should just halt in base level"

	^ MetaLink new
		  metaObject: self;
		  selector: #blockArgInContext:node:;
		  options: #(+ optionCompileOnLinkInstallation);
		  arguments: #(#context #node);
		  control: #before
]

{ #category : 'links' }
RuntimeTypeCollectorForMethod >> newInstVarLink [

	^ MetaLink new
		  metaObject: self;
		  selector: #instVarWriteInContext:node:;
		  arguments: #(#context #node);
		  control: #after
]

{ #category : 'links' }
RuntimeTypeCollectorForMethod >> newLeaveLink [
	"for now it should just halt in base level"

	^ MetaLink new
		  metaObject: self;
		  selector: #leaveInContext:node:;
		  arguments: #(#context #node);
		  control: #after		
]

{ #category : 'links' }
RuntimeTypeCollectorForMethod >> newLink [
	"for now it should just halt in base level"

	^ MetaLink new
		  metaObject: self;
		  selector: #writeInContext:node:;
		  options: #(+ optionCompileOnLinkInstallation);
		  arguments: #(#context #node);
		  control: #after
]

{ #category : 'links' }
RuntimeTypeCollectorForMethod >> newTempVarLink [

	^ MetaLink new
		  metaObject: self;
		  selector: #writeInContext:node:;
		  options: #(+ optionCompileOnLinkInstallation);
		  arguments: #(#context #node);
		  control: #after
]

{ #category : 'metalink methods' }
RuntimeTypeCollectorForMethod >> newTypesSet [ 

	^ IdentitySet new.
]

{ #category : 'utility' }
RuntimeTypeCollectorForMethod >> orderedBlocks [

	| allBlocks |
	
	allBlocks := self allBlocks.
	
	^ (blockInformation associations collect: [ :assoc |
		(self isWellKnownBlock: assoc key) ifFalse: [ 
			(allBlocks indexOf: assoc key) -> assoc value ].
	]) sorted: [ :a :b | a key <= b key ]
]

{ #category : 'API' }
RuntimeTypeCollectorForMethod >> readCurrentTypesFromPragmas [

	targetMethod pragmas do: [ :pragma | 
		(#(arg:type: arg:type:generated:) includes: pragma selector) 
			ifTrue: [ 
				collectedArgClasses at: pragma arguments first asSymbol put: (self typeSetWith: (SchmidtTypeCollectorType fromLiteral: pragma arguments second))  ].
			
		(#(var:type: var:type:generated:) includes: pragma selector) 
			ifTrue: [ 
				collectedTempClasses at: pragma arguments first asSymbol put: (self typeSetWith: (SchmidtTypeCollectorType fromLiteral: pragma arguments second))  ].
			
		(#(blockArg:type: blockArg:type:generated:) includes: pragma selector) 
			ifTrue: [ 
				collectedBlockArgClasses at: pragma arguments first asSymbol put: (self typeSetWith: (SchmidtTypeCollectorType fromLiteral: pragma arguments second))  ].

		(#(returns: returns:generated:) includes: pragma selector) 
			ifTrue: [ 
				collectedReturnClasses addAll: (self typeSetWith: (SchmidtTypeCollectorType fromLiteral: pragma arguments first))  ].

		(#(block:returnsValue: block:returnsValue:generated:) includes: pragma selector) 
			ifTrue: [ 
				self blockNumber: pragma arguments first returnsValue: pragma arguments second.  ].			

	]
]

{ #category : 'API' }
RuntimeTypeCollectorForMethod >> rebuildSets [

	| new |
	new := IdentityDictionary new.
	collectedTempClasses keysAndValuesDo: [ :key :value |
		new at: key put: value asArray asSet ].
	collectedTempClasses := new.

	collectedReturnClasses := collectedReturnClasses asArray asSet. 
	
	new := IdentityDictionary new.
	collectedBlockArgClasses keysAndValuesDo: [ :key :value |
		new at: key put: value asArray asSet ].
	collectedBlockArgClasses := new.	
	
	new := IdentityDictionary new.
	collectedArgClasses keysAndValuesDo: [ :key :value |
		new at: key put: value asArray asSet ].
	collectedArgClasses := new.	
]

{ #category : 'API' }
RuntimeTypeCollectorForMethod >> remove [

	"Transcript show: 'Removing collector from '; show: targetMethod name; cr.
	World doOneCycle."

	mode = #variables 
		ifTrue: [ 
			tempLinks, {argLink}, {returnLink}, blockArgLinks, instVarLinks do: [ :metalink | 
			metalink ifNotNil: [ 
				metalink uninstall ]
			].
		].
	
	mode = #returnValues
		ifTrue: [ 		
			{returnLink} do: [ :metalink | 
				metalink ifNotNil: [ 
					metalink uninstall ]
				].
		].

	targetMethod methodClass compile: originalSource.

	self rebuildSets.	
]

{ #category : 'API' }
RuntimeTypeCollectorForMethod >> typeSetWith: typeOrTypes [

	| set |
	
	set := self newTypesSet.
	
	typeOrTypes isCollection 
		ifTrue: [ set addAll: typeOrTypes ]
		ifFalse: [ set add: typeOrTypes ].
	
	^ set
		
]

{ #category : 'metalink methods' }
RuntimeTypeCollectorForMethod >> valueInContext: aContext node: aNode [ 

	argNames do: [ :argName |
		| value |
		value := aContext tempNamed: argName.
		argName _assigned.
		(collectedArgClasses at: argName ifAbsentPut: [ self newTypesSet ])
			add: (value asRuntimeTypeCollectorTypeIn: self) ] 
]

{ #category : 'metalink methods' }
RuntimeTypeCollectorForMethod >> writeInContext: aContext node: aNode [
	
	| varName value |
	
	varName := aNode variable name asSymbol.
	value := aContext tempNamed: varName.
	value _assigned.
	
	(collectedTempClasses at: varName ifAbsentPut: [ self newTypesSet ])
		add: (value asRuntimeTypeCollectorTypeIn: self).
	
]
