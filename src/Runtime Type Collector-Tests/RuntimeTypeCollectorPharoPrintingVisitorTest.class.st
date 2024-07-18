Class {
	#name : 'RuntimeTypeCollectorPharoPrintingVisitorTest',
	#superclass : 'TestCase',
	#category : 'Runtime Type Collector-Tests',
	#package : 'Runtime Type Collector-Tests'
}

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testAssociation [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(Association key #String value #Integer).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(Association key String value Integer)'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testAssociationNullable [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(Association:: key #String value #Integer).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(Association:: key String value Integer)'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testBlock1 [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(FullBlockClosure returning Integer).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(FullBlockClosure returning Integer)'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testBlock1Nullable [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(FullBlockClosure:: returning Integer).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(FullBlockClosure:: returning Integer)'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testBlock2 [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(FullBlockClosure arguments #(#(String Symbol) Object) returning Integer).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(FullBlockClosure arguments ((String Symbol) Object) returning Integer)'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testBlock2Nullable [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(FullBlockClosure:: arguments #(#(String Symbol) Object) returning Integer).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(FullBlockClosure:: arguments ((String Symbol) Object) returning Integer)'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testBlock3 [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(FullBlockClosure arguments #(#(String Symbol) Object)).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(FullBlockClosure arguments ((String Symbol) Object))'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testBlock3Nullable [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(FullBlockClosure:: arguments #(#(String Symbol) Object)).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(FullBlockClosure:: arguments ((String Symbol) Object))'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testBlock4 [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(FullBlockClosure).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#FullBlockClosure'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testBlock4Nullable [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(FullBlockClosure::).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#FullBlockClosure::'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testBlock5Nullable [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(FullBlockClosure:: arguments #(#(String:: Symbol::) (Object::)) returning (Integer::)).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(FullBlockClosure:: arguments ((String:: Symbol::) Object::) returning Integer::)'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testDictionary [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(Dictionary of String keys Integer).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(Dictionary of String keys Integer)'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testDictionary2 [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(Dictionary of () keys ()).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(Dictionary of () keys ())'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testDictionary3 [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(Dictionary of (Integer String) keys Object).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(Dictionary of (Integer String) keys Object)'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testDictionaryNullable [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(Dictionary:: of String keys Integer).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(Dictionary:: of String keys Integer)'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testEmpty [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #().
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#()'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testExtraParentheses [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #((String)).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#String'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testMultipleSimple [ 

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(String Symbol).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(String Symbol)'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testMultipleSimpleNullable1 [ 

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(String:: Symbol).
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#(String:: Symbol)'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testSimple [ 

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #String.
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#String'.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testSimpleMetaclass [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #'String class'.
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#''String class'''.
]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testSimpleNullable [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #(String::).
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#String::'.
	

]

{ #category : 'tests' }
RuntimeTypeCollectorPharoPrintingVisitorTest >> testSimpleNullable2 [

	| typeSet visitor  |
	
	typeSet := RuntimeTypeCollectorType fromLiteral: #('String::').
	
	visitor := RuntimeTypeCollectorPharoPrintingVisitor new.
	visitor visitTypeSet: typeSet.
	
	self assert: visitor content equals: '#String::'.
]
