Extension { #name : 'Class' }

{ #category : '*Runtime Type Collector' }
Class >> runtimeTypeCollectorSlotTypeOf: varName [ 
	
	| methodName |

	methodName := '_slotTypes' asSymbol.
	
	(self includesSelector: methodName) ifFalse: [ ^ nil ].
	
	(self>>methodName) pragmas do: [ :pragma | 
		((#(slot:type: slot:type:generated:) includes: pragma selector) and: [ pragma arguments first = varName ])
			ifTrue: [ 
				^ pragma arguments second  ]
			].
		
	 ^ nil

]
