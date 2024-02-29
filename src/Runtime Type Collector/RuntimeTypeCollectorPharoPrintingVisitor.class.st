Class {
	#name : 'RuntimeTypeCollectorPharoPrintingVisitor',
	#superclass : 'RuntimeTypeCollectorTypePrintingVisitor',
	#instVars : [
		'stream'
	],
	#category : 'Runtime Type Collector-Visitors',
	#package : 'Runtime Type Collector',
	#tag : 'Visitors'
}

{ #category : 'accessing' }
RuntimeTypeCollectorPharoPrintingVisitor >> content [ 

	^ '#', stream contents
]

{ #category : 'accessing' }
RuntimeTypeCollectorPharoPrintingVisitor >> initialize [ 

	super initialize.
	
	stream := WriteStream on: String new.
]

{ #category : 'accessing' }
RuntimeTypeCollectorPharoPrintingVisitor >> nullableEnding [

	^ '::'
]

{ #category : 'accessing' }
RuntimeTypeCollectorPharoPrintingVisitor >> visitAssociationType: aType [ 

	stream << '(' << aType typeClass name << (aType nullable ifTrue: [self nullableEnding] ifFalse: ['']) << ' key '.
	self visitTypeSet: aType keyClasses.
	stream  << ' value '.
	self visitTypeSet: aType valueClasses.
	stream  << ')'.
]

{ #category : 'accessing' }
RuntimeTypeCollectorPharoPrintingVisitor >> visitBlockType: aType [ 

	| hasParentheses |

	hasParentheses := (aType wasUsed not and: [ aType argumentClasses isEmpty ]) not.

	hasParentheses ifTrue: [stream << '('].
	stream << aType typeClass name << (aType nullable ifTrue: [self nullableEnding] ifFalse: ['']).
	aType argumentClasses ifNotEmpty: [ 
		stream << ' arguments ('.
		aType argumentClasses do: [ :eachTypeSet |
			self visitTypeSet: eachTypeSet ]
			betweenDo: [ stream space].	
		stream << ')'
	 ].
	aType wasUsed ifTrue: [  
		aType returnClasses ifNotEmpty: [ 
			stream << ' returning '.
			self visitTypeSet: aType returnClasses.		
		] ].
	hasParentheses ifTrue: [stream << ')'].

]

{ #category : 'accessing' }
RuntimeTypeCollectorPharoPrintingVisitor >> visitCollectionType: aType [ 

	stream << '(' << aType typeClass name << (aType nullable ifTrue: [self nullableEnding] ifFalse: ['']) << ' of '.
	self visitTypeSet: aType itemClasses.
	stream  << ')'.
	
]

{ #category : 'accessing' }
RuntimeTypeCollectorPharoPrintingVisitor >> visitDictionaryType: aType [ 

	stream << '(' << aType typeClass name << (aType nullable ifTrue: [self nullableEnding] ifFalse: ['']) << ' of '.
	self visitTypeSet: aType itemClasses.
	stream  << ' keys '.
	self visitTypeSet: aType keyClasses.
	stream  << ')'.
	
	
]

{ #category : 'accessing' }
RuntimeTypeCollectorPharoPrintingVisitor >> visitSimpleType: aType [ 

	| quotesNeeded |
	quotesNeeded := aType typeClass name includes: Character space.
	
	quotesNeeded ifTrue: [ stream << '''' ].
	stream << aType typeClass name.
	aType nullable 
		ifTrue: [ 
			stream << self nullableEnding ].
	quotesNeeded ifTrue: [ stream << '''' ].

]

{ #category : 'accessing' }
RuntimeTypeCollectorPharoPrintingVisitor >> visitType: aType [ 

	^ aType acceptVisitor: self
]

{ #category : 'accessing' }
RuntimeTypeCollectorPharoPrintingVisitor >> visitTypeSet: aTypeSet [

	| useParentheses |
	
	aTypeSet ifEmpty: [ 
		stream << '()'.
		^ self ].
	
	useParentheses := 	aTypeSet size > 1.

	useParentheses ifTrue: [ stream << '(' ].
	aTypeSet sorted
		do: [ :each | each isCollection 
			ifTrue: [ self visitTypeSet: each] 
			ifFalse: [ self visitType: each ] ] 
		betweenDo: [ stream << ' ' ].
	useParentheses ifTrue: [ stream << ')' ].

]
