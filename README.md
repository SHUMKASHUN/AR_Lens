# AR_Lens
When an object is detected , ARkit will call the 
``` swift
renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor). 
```

And the latency detection is in this function.
Also, ARkit will update the position of the object by calling 
``` swift
renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor)
```
Both function is under  
> SpokenWord/ViewController.swift
