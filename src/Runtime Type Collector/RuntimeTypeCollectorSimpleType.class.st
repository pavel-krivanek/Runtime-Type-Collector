"
Describes a simple type
"
Class {
	#name : 'RuntimeTypeCollectorSimpleType',
	#superclass : 'RuntimeTypeCollectorType',
	#category : 'Runtime Type Collector',
	#package : 'Runtime Type Collector'
}

{ #category : 'instance creation' }
RuntimeTypeCollectorSimpleType class >> acceptsClass: aClass [ 

	^ true
]

{ #category : 'instance creation' }
RuntimeTypeCollectorSimpleType class >> fromClass: aClass [ 

	^ self new 
		typeClass: aClass;
		yourself.
]

{ #category : 'instance creation' }
RuntimeTypeCollectorSimpleType class >> fromClass: aClass nullable: nullable [

	^ self new 
		typeClass: aClass;
		nullable: nullable;
		yourself.
]

{ #category : 'visiting' }
RuntimeTypeCollectorSimpleType >> acceptVisitor: aVisitor [
	^ aVisitor visitSimpleType: self
]

{ #category : 'testing' }
RuntimeTypeCollectorSimpleType >> isSimpleType [ 

	^ true
]
