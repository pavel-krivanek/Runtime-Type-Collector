Extension { #name : 'FullBlockClosure' }

{ #category : '*Runtime Type Collector' }
FullBlockClosure >> asRuntimeTypeCollectorTypeIn: aCollectorForMethod [ 

	| collectorType newClosure |
	
	collectorType := RuntimeTypeCollectorBlockType new.
	collectorType collector: aCollectorForMethod.
	
	aCollectorForMethod compiledBlock: self compiledBlock ast type: collectorType.
	
	newClosure := ShiftClassInstaller basicNew
		oldClass: FullBlockClosure;
		copyObject: self to: RuntimeCollectingFullBlockClosure.
		
	newClosure addCollectorType: collectorType.
		
	newClosure become: self.
	
	^ collectorType
	


]
