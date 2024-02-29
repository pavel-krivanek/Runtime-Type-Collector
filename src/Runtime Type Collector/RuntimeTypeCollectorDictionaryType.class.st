"
Describes a keyed collection type.
"
Class {
	#name : 'RuntimeTypeCollectorDictionaryType',
	#superclass : 'SchmidtTypeCollectorType',
	#instVars : [
		'keyClasses',
		'itemClasses'
	],
	#category : 'Runtime Type Collector',
	#package : 'Runtime Type Collector'
}

{ #category : 'testing' }
RuntimeTypeCollectorDictionaryType class >> acceptsClass: aClass [ 

	^ ((aClass = Dictionary or: [ (aClass inheritsFrom: Dictionary) ])
		or: [ aClass = OrderedDictionary or: [ aClass inheritsFrom: OrderedDictionary ] ])
		or: [ aClass = SmallDictionary or: [ aClass inheritsFrom: SmallDictionary ] ]
]

{ #category : 'instance creation' }
RuntimeTypeCollectorDictionaryType class >> fromClass: aClass itemClasses: itemClasses keyClasses: keyClasses [

	^ self new 
		typeClass: aClass;
		itemClasses: itemClasses;
		keyClasses: keyClasses;
		yourself.
]

{ #category : 'instance creation' }
RuntimeTypeCollectorDictionaryType class >> fromClass: aClass itemClasses: itemClasses keyClasses: keyClasses nullable: nullable [

	^ self new 
		typeClass: aClass;
		itemClasses: itemClasses;
		keyClasses: keyClasses;
		nullable: nullable
		yourself.
]

{ #category : 'instance creation' }
RuntimeTypeCollectorDictionaryType class >> fromDictionary: anObject in: aCollectorForMethod [

	"there are several distinct Dictionary classes so rather make the conversion on one palace"

	| itemClasses keyClasses |
	
	itemClasses := (anObject values collect: [ :each | each class ] as: IdentitySet) collect: [ :cls | cls asRuntimeTypeCollectorTypeIn: aCollectorForMethod ].
	keyClasses := (anObject keys collect: [ :each | each class ] as: IdentitySet) collect: [ :cls | cls asRuntimeTypeCollectorTypeIn: aCollectorForMethod ].

	^ self fromClass: anObject class itemClasses: itemClasses keyClasses: keyClasses nullable: false
]

{ #category : 'comparing' }
RuntimeTypeCollectorDictionaryType >> = anObject [

	^ super = anObject
		and: [ itemClasses = anObject itemClasses 
			and: keyClasses = anObject keyClasses ]
]

{ #category : 'visiting' }
RuntimeTypeCollectorDictionaryType >> acceptVisitor: aVisitor [
	^ aVisitor visitDictionaryType: self
]

{ #category : 'comparing' }
RuntimeTypeCollectorDictionaryType >> hash [

	^ (super hash bitXor: itemClasses hash) bitXor: keyClasses hash
]

{ #category : 'serialization' }
RuntimeTypeCollectorDictionaryType >> isDictionaryType [

	^ true
]

{ #category : 'accessing' }
RuntimeTypeCollectorDictionaryType >> itemClasses [ 

	^ itemClasses
]

{ #category : 'accessing' }
RuntimeTypeCollectorDictionaryType >> itemClasses: anObject [

	itemClasses := anObject
]

{ #category : 'accessing' }
RuntimeTypeCollectorDictionaryType >> keyClasses [

	^ keyClasses
]

{ #category : 'accessing' }
RuntimeTypeCollectorDictionaryType >> keyClasses: anObject [

	keyClasses := anObject
]

{ #category : 'accessing' }
RuntimeTypeCollectorDictionaryType >> preMerge [ 

	| merged |
	
	merged := self copy.
	
	merged keyClasses: (self class mergeAll: self keyClasses).
	merged itemClasses: (self class mergeAll: self itemClasses).
	
	^ merged 
]
