"
Descripbes an association.
"
Class {
	#name : 'RuntimeTypeCollectorAssociationType',
	#superclass : 'RuntimeTypeCollectorType',
	#instVars : [
		'keyClasses',
		'valueClasses'
	],
	#category : 'Runtime Type Collector',
	#package : 'Runtime Type Collector'
}

{ #category : 'instance creation' }
RuntimeTypeCollectorAssociationType class >> acceptsClass: aClass [ 

	^ aClass = Association or: [ aClass inheritsFrom: Association ]
]

{ #category : 'instance creation' }
RuntimeTypeCollectorAssociationType class >> fromClass: aClass keyClasses: keyClasses valueClasses: valueClasses nullable: nullable [

	^ self new 
		typeClass: aClass;
		keyClasses: keyClasses;
		valueClasses: valueClasses;
		nullable: nullable;
		yourself.
]

{ #category : 'comparing' }
RuntimeTypeCollectorAssociationType >> = anObject [

	^ super = anObject
		and: [ valueClasses = anObject valueClasses 
			and: keyClasses = anObject keyClasses ]
]

{ #category : 'comparing' }
RuntimeTypeCollectorAssociationType >> acceptVisitor: aVisitor [
	^ aVisitor visitAssociationType: self
]

{ #category : 'comparing' }
RuntimeTypeCollectorAssociationType >> hash [

	^ (super hash bitXor: valueClasses hash) bitXor: keyClasses hash
]

{ #category : 'serialization' }
RuntimeTypeCollectorAssociationType >> isAssociationType [

	^ true
]

{ #category : 'accessing' }
RuntimeTypeCollectorAssociationType >> keyClasses [

	^ keyClasses
]

{ #category : 'accessing' }
RuntimeTypeCollectorAssociationType >> keyClasses: anObject [

	keyClasses := anObject
]

{ #category : 'accessing' }
RuntimeTypeCollectorAssociationType >> preMerge [ 

	| merged |
	
	merged := self copy.
	
	merged keyClasses: (self class mergeAll: self keyClasses).
	merged valueClasses: (self class mergeAll: self valueClasses).
	
	^ merged 
]

{ #category : 'accessing' }
RuntimeTypeCollectorAssociationType >> valueClasses [

	^ valueClasses
]

{ #category : 'accessing' }
RuntimeTypeCollectorAssociationType >> valueClasses: anObject [

	valueClasses := anObject
]
