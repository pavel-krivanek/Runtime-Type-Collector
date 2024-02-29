Class {
	#name : 'BaselineOfRuntimeTypeCollector',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfRuntimeTypeCollector',
	#package : 'BaselineOfRuntimeTypeCollector'
}

{ #category : 'baselines' }
BaselineOfRuntimeTypeCollector >> baseline: spec [ 
	<baseline>
	spec for: #common
		do: [			
			spec package: 'Runtime Type Collector'.
			spec package: 'Runtime Type Collector-Examples'.
			spec package: 'Runtime Type Collector-Tests'.
	]
]
