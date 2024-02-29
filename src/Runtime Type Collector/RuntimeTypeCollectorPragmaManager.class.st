"
Manages pragmas in a method. Determines if a pragma can be rewritten and performs it.
"
Class {
	#name : 'RuntimeTypeCollectorPragmaManager',
	#superclass : 'Object',
	#instVars : [
		'method'
	],
	#category : 'Runtime Type Collector',
	#package : 'Runtime Type Collector'
}

{ #category : 'instance creation' }
RuntimeTypeCollectorPragmaManager class >> for: aCompiledMethod [ 

	^ self new
		method: aCompiledMethod;
		yourself
]

{ #category : 'instance creation' }
RuntimeTypeCollectorPragmaManager class >> generatePlaceholdersFor: packageName [

	packageName asPackage methods do: [ :m |
		self generatePlaceholdersForMethod: m].


]

{ #category : 'instance creation' }
RuntimeTypeCollectorPragmaManager class >> generatePlaceholdersForMethod: aCompiledMethod [

	| c pm undefined includes definesReturn hasExplicitReturn m |

	m := aCompiledMethod.

	EpMonitor disableDuring: [ 
		c := RuntimeTypeCollectorForMethod forMethod: m.
		pm := RuntimeTypeCollectorPragmaManager for: m.

		"args"
		undefined := c availableArgNames select: [ :name |
			includes := m pragmas anySatisfy: [ :pragma |
				(#(arg:type: arg:type:generated:) includes: pragma selector) and: [ pragma arguments first = name asSymbol ] ].
			includes not 
		].
		undefined do: [ :name |
			pm replacePragma: #arg:type:generated: argument: name with: ('<arg: #{1} type: #Unknown generated: true>' format: { name }) 
		]. 
	
		"temps"
		undefined := c availableTempNames select: [ :name |
			includes := m pragmas anySatisfy: [ :pragma |
				(#(var:type: var:type:generated:) includes: pragma selector) and: [ pragma arguments first = name asSymbol ] ].
			includes not 
		].
		undefined do: [ :name |
			pm replacePragma: #var:type:generated: argument: name with: ('<var: #{1} type: #Unknown generated: true>' format: { name }) 
		]. 

		"blockargs"
		undefined := (c allBlocks flatCollect: [ :e | e arguments collect: #name ]) select: [ :name |
			includes := m pragmas anySatisfy: [ :pragma |
				(#(blockArg:type: blockArg:type:generated:) includes: pragma selector) and: [ pragma arguments first = name asSymbol ] ].
			includes not 
		].
		undefined do: [ :name |
			pm replacePragma: #blockArg:type:generated: argument: name with: ('<blockArg: #{1} type: #Unknown generated: true>' format: { name }) 
		]. 
	
		definesReturn := m pragmas anySatisfy: [ :pragma |
				(#(returns: returns:generated:) includes: pragma selector) ].
		hasExplicitReturn := m ast allChildren anySatisfy: #isReturn.
		(definesReturn not and: [ hasExplicitReturn ]) ifTrue: [ 
			pm replacePragma: #returns:generated: argument: name with: '<returns: #Unknown generated: true>' 
		 ].
	].



]

{ #category : 'instance creation' }
RuntimeTypeCollectorPragmaManager class >> solidify: packageName [

	packageName asPackage methods do: [ :m |
		(self for: m) solidify ].


]

{ #category : 'private' }
RuntimeTypeCollectorPragmaManager >> canRegenerate: aName [

	| pragmaName name argsCount matchingPragmaOrNil |
	
	pragmaName := (aName withoutSuffix: #generated:) asSymbol.
	
	(method hasPragmaNamed: pragmaName) 
		ifTrue: [
			(method pragmas anySatisfy: [ :pragma | 
				(pragma selector = pragmaName 
				and: [ pragma arguments notEmpty ])])
					ifTrue: [ ^ false ].
	].
	
	argsCount := pragmaName  count: [:e | e = $:].
	
	name := (pragmaName, #generated:) asSymbol.

	matchingPragmaOrNil := method pragmas 
		detect: [ :pragma | 
			(pragma selector = name 
			and: [ pragma arguments notEmpty ]) ] 
		ifNone: [ nil ].
		
	matchingPragmaOrNil ifNil: [ ^ true ].

	^ (matchingPragmaOrNil arguments at: argsCount + 1) == true
]

{ #category : 'private' }
RuntimeTypeCollectorPragmaManager >> canRegenerate: aName argument: firstArgName [ 

	| pragmaName name argsCount matchingPragmaOrNil |
	
	pragmaName := (aName withoutSuffix: #generated:) asSymbol.
	
	(method hasPragmaNamed: pragmaName) 
		ifTrue: [
			(method pragmas anySatisfy: [ :pragma | 
				(pragma selector = pragmaName 
				and: [ pragma arguments notEmpty ])
				and: [ pragma arguments first = firstArgName ]])
					ifTrue: [ ^ false ].
	].
	
	argsCount := pragmaName  count: [:e | e = $:].
	
	name := (pragmaName, #generated:) asSymbol.

	matchingPragmaOrNil := method pragmas 
		detect: [ :pragma | 
			(pragma selector = name 
			and: [ pragma arguments notEmpty ])
			and: [ pragma arguments first = firstArgName ] ] 
		ifNone: [ nil ].
		
	matchingPragmaOrNil ifNil: [ ^ true ].

	^ (matchingPragmaOrNil arguments at: argsCount + 1) == true
]

{ #category : 'API - pragmas' }
RuntimeTypeCollectorPragmaManager >> ensureDeletePragma: pragmaName argument: arg [

	(self canRegenerate: pragmaName argument: arg) 
		ifTrue: [ 
			(self hasPragmaNamed: pragmaName argument: arg)
				ifTrue: [ self privDeletePragma: pragmaName argument: arg ].
		]
]

{ #category : 'private' }
RuntimeTypeCollectorPragmaManager >> hasPragmaNamed: pragmaName argument: firstArgName [

	^ (method ast pragmas 
		detect: [ :pragma | 
			(pragma selector = pragmaName 
			and: [ pragma arguments notEmpty ])
			and: [ pragma arguments first value = firstArgName ] ] 
		ifNone: [ nil ]) notNil
]

{ #category : 'accessing' }
RuntimeTypeCollectorPragmaManager >> method [

	^ method
]

{ #category : 'accessing' }
RuntimeTypeCollectorPragmaManager >> method: anObject [

	method := anObject.
	self refresh.
]

{ #category : 'API - pragmas' }
RuntimeTypeCollectorPragmaManager >> pragmaThatCanBeSolidifiedOrNil: src [

	| selectors ast |
	
	ast := RBParser parseMethod: src. 
	selectors := #(arg:type:generated: var:type:generated: blockArg:type:generated:).
	(ast pragmas 
		detect: [ :each | (selectors includes: each selector) and: [ (each arguments second value = #Unknown or: [each arguments second value = #(Unknown)]) not ] ]
		ifNone: [ ])
			ifNotNil: [ :p | ^ p ].
		
	selectors := #(returns:generated:).
	(ast pragmas 
		detect: [ :each | (selectors includes: each selector) and: [ (each arguments first value = #Unknown or: [each arguments first value = #(Unknown)]) not] ]
		ifNone: [ ])
			ifNotNil: [ :p | ^ p ].

	^ nil

		
	

]

{ #category : 'private' }
RuntimeTypeCollectorPragmaManager >> privAddPragmaString: aString [ 

	| source start newSource |
	source := method sourceCode.
	start := method ast body start - 1.
	start = 0 "the method was empty"
		ifTrue: [ start := source size ].
	newSource := (source first: start), aString, '
	', (source allButFirst: start).
	newSource.
	method methodClass compile: newSource.
	self refresh.
]

{ #category : 'private' }
RuntimeTypeCollectorPragmaManager >> privDeletePragma: pragmaName argument: firstArgName [

	| matchingPragmaNodeOrNil source newSource start end |

	matchingPragmaNodeOrNil := method ast pragmas 
		detect: [ :pragma | 
			(pragma selector = pragmaName 
			and: [ pragma arguments notEmpty ])
			and: [ pragma arguments first value = firstArgName ] ] 
		ifNone: [ nil ].

	matchingPragmaNodeOrNil ifNil: [ ^ self ].
	
	source := method sourceCode.
	start := matchingPragmaNodeOrNil start.
	end := matchingPragmaNodeOrNil stop.
	
	newSource := source copyReplaceFrom: start to: end  with: ''.
	method methodClass compile: newSource.
	self refresh.	
	
	
]

{ #category : 'private' }
RuntimeTypeCollectorPragmaManager >> privReplacePragma: pragmaName argument: firstArgName with: aString [

	| matchingPragmaNodeOrNil source newSource start end |

	matchingPragmaNodeOrNil := method ast pragmas 
		detect: [ :pragma | 
			(pragma selector = pragmaName 
			and: [ pragma arguments notEmpty ])
			and: [ pragma arguments first value = firstArgName ] ] 
		ifNone: [ nil ].

	matchingPragmaNodeOrNil ifNil: [ ^ self ].
	
	source := method sourceCode.
	start := matchingPragmaNodeOrNil start.
	end := matchingPragmaNodeOrNil stop.
	
	newSource := source copyReplaceFrom: start to: end  with: aString.
	method methodClass compile: newSource.
	self refresh.	
	
	
]

{ #category : 'private' }
RuntimeTypeCollectorPragmaManager >> privReplacePragma: pragmaName with: aString [

	| matchingPragmaNodeOrNil source newSource start end |

	matchingPragmaNodeOrNil := method ast pragmas 
		detect: [ :pragma | 
			pragma selector = pragmaName ] 
		ifNone: [ nil ].

	matchingPragmaNodeOrNil ifNil: [ ^ self ].
	
	source := method sourceCode.
	start := matchingPragmaNodeOrNil start.
	end := matchingPragmaNodeOrNil stop.
	
	newSource := source copyReplaceFrom: start to: end  with: aString.
	method methodClass compile: newSource.
	self refresh.	
	
	
]

{ #category : 'private' }
RuntimeTypeCollectorPragmaManager >> refresh [ 

	method := method methodClass >> method selector.
]

{ #category : 'API - pragmas' }
RuntimeTypeCollectorPragmaManager >> replacePragma: pragmaName argument: arg with: aString [ 

	(self canRegenerate: pragmaName argument: arg) 
		ifTrue: [ 
			(self hasPragmaNamed: pragmaName argument: arg)
				ifTrue: [ self privReplacePragma: pragmaName argument: arg with: aString ]
				ifFalse: [ self privAddPragmaString: aString ].
		]
]

{ #category : 'API - pragmas' }
RuntimeTypeCollectorPragmaManager >> replacePragma: pragmaName with: aString [ 

	(self canRegenerate: pragmaName) 
		ifTrue: [ 
			(method hasPragmaNamed: pragmaName)
				ifTrue: [ self privReplacePragma: pragmaName with: aString ]
				ifFalse: [ self privAddPragmaString: aString ].
		]
]

{ #category : 'API - pragmas' }
RuntimeTypeCollectorPragmaManager >> solidifiedSourceCode [

	| src pragma start end newPrgmaSrc |
	src := method sourceCode.

	[
		pragma := self pragmaThatCanBeSolidifiedOrNil: src.
		pragma notNil.
	] whileTrue: [ 
		start := pragma start.
		end := pragma stop.
		(pragma selector = #arg:type:generated:)
			ifTrue: [ 
				newPrgmaSrc := '<arg: {1} type: {2}>' format: { 
					pragma arguments first sourceCode.
					pragma arguments second  sourceCode.
				}.
				src := src copyReplaceFrom: start to: end  with: newPrgmaSrc.
			 ].
		(pragma selector = #var:type:generated:)
			ifTrue: [ 
				newPrgmaSrc := '<var: {1} type: {2}>' format: { 
					pragma arguments first sourceCode.
					pragma arguments second  sourceCode.
				}.
				src := src copyReplaceFrom: start to: end  with: newPrgmaSrc.
			 ].
		(pragma selector = #blockArg:type:generated:)
			ifTrue: [ 
				newPrgmaSrc := '<blockArg: {1} type: {2}>' format: { 
					pragma arguments first sourceCode.
					pragma arguments second  sourceCode.
				}.
				src := src copyReplaceFrom: start to: end  with: newPrgmaSrc.
			 ].
		(pragma selector = #returns:generated:)
			ifTrue: [ 
				newPrgmaSrc := '<returns: {1}>' format: { 
					pragma arguments first sourceCode.
				}.
				src := src copyReplaceFrom: start to: end  with: newPrgmaSrc.
			 ].
		].
		
	^ src		
	

]

{ #category : 'API - pragmas' }
RuntimeTypeCollectorPragmaManager >> solidify [ 

	method methodClass compile: self solidifiedSourceCode.
	self refresh.	
]
