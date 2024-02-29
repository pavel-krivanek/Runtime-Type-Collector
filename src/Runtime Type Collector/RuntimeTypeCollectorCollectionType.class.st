"
Describes a non-keyed collection type.
"
Class {
	#name : 'RuntimeTypeCollectorCollectionType',
	#superclass : 'SchmidtTypeCollectorType',
	#instVars : [
		'itemClasses'
	],
	#category : 'Runtime Type Collector',
	#package : 'Runtime Type Collector'
}

{ #category : 'instance creation' }
RuntimeTypeCollectorCollectionType class >> acceptsClass: aClass [ 

	^ aClass = Collection or: [ (aClass inheritsFrom: Collection) and: [ (RuntimeTypeCollectorDictionaryType acceptsClass: aClass) not ]]
]

{ #category : 'instance creation' }
RuntimeTypeCollectorCollectionType class >> fromClass: aClass itemClasses: itemClasses nullable: nullable [

	^ self new 
		typeClass: aClass;
		itemClasses: itemClasses;
		nullable: nullable
		yourself.
]

{ #category : 'comparing' }
RuntimeTypeCollectorCollectionType >> = anObject [

	^ super = anObject
		and: [ itemClasses = anObject itemClasses ]
]

{ #category : 'visiting' }
RuntimeTypeCollectorCollectionType >> acceptVisitor: aVisitor [
	^ aVisitor visitCollectionType: self
]

{ #category : 'comparing' }
RuntimeTypeCollectorCollectionType >> hash [

	^ super hash bitXor: itemClasses hash
]

{ #category : 'serialization' }
RuntimeTypeCollectorCollectionType >> isCollectionType [

	^ true
]

{ #category : 'accessing' }
RuntimeTypeCollectorCollectionType >> itemClasses [

	^ itemClasses
]

{ #category : 'accessing' }
RuntimeTypeCollectorCollectionType >> itemClasses: anObject [

	itemClasses := anObject
]
