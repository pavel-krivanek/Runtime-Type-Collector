Extension { #name : 'Metaclass' }

{ #category : '*Runtime Type Collector' }
Metaclass >> isInClassHierarchyOf: aClass [

	^ (self includesBehavior: aClass) or: [
		  aClass includesBehavior: self ]
]
