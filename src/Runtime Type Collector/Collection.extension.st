Extension { #name : 'Collection' }

{ #category : '*Runtime Type Collector' }
Collection >> asRuntimeTypeCollectorTypeIn: aCollectorForMethod [ 

	| itemClasses |
	
	itemClasses := (self collect: [ :each | each class ] as: IdentitySet) collect: [ :cls | cls asRuntimeTypeCollectorTypeIn: aCollectorForMethod ].

	^ RuntimeTypeCollectorCollectionType fromClass: self class itemClasses: itemClasses nullable: false
]
