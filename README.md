# Rewriting the Map To Better Appreciate Generics


One thing I'm often asked rhetorically by imaginary colleagues with the sole purpose of providing a blog post with context is

> Generics? They're super complicated, aren't they?

And my answer is most definitely

> You bet!  
> Well, kinda.  
> Well, maybe.  
> Well, not strictly, but I can see what you mean.

One of the ways that it can be useful to understand and appreciate the value (_some may even dare to say beauty_) of generics is by taking a look at some of the built in generic functions in Swift and attempting to duplicate that same functionality ourselves.  

This may seem daunting, but the principles we will adopt can be applied in many wider contexts in your own applications.

## Map
Ah, Map! Good old Map! Friendly, simple, harmless old Mappy Mappy Map Map!

The map function is probably one of the first ones developers encounter when writing Swift code. 
It has the basic premises of "Turn *this* into *that*". 

And how **neatly** it does it! If you are unfamiliar with what the map function looks like, it works like this

```
let items = [1,2,3,4,5]
let output = items.map { "\($0)" }
print(output)
// output is ["1", "2", "3", "4", "5"]
```

The map function takes one parameter, in this case a closure (basically  a mini function) and applies that closure to _each element_ in that collection. 
It finally returns a **new** collection containing the _transformation_ of those items.  

If we were to break this down into a numbered sequence, it would be: 
1. Take an element from the original array
2. Turn it into a string
3. Add it to a new array
4. Repeat until original array is empty
5. Return the new array

What this approach helps to demonstrate, is that there isn't anything particularly _magical_ going on with this function. 
Syntactically it can be strange, but it's simply iterating over the collection, doing..."stuff"...and then popping out a new collection at the end.  

In the above example, the syntax of `$0` is just shorthand for "the object passed into this closure. There is a longer format for this which looks like

```
let output = items.map { currentItem in
	return "\(currentItem)"
}
```

But functionally they are exactly the same and the use of either option is dependent on how simple or complex the code within your closure is and whether the extra clarity of naming the object is necessary.

## My Map
If we can understand the _what_ of the map function, then we can replicate this and build our own version of Map.

First, taking the "generic" out from the equation, we can focus on the what. If we were to write this as a more typical function, then it could look something like the below

```
let items = [1,2,3,4,5]
func myMap(_ array:[Int]) -> [String] {
    
    var output: [String] = []
    
    for item in array {
        output.append("\(item)")
    }
    
    return output
}
// output is ["1", "2", "3", "4", "5"]
```

### Generificationism
To turn the above into a generic function, we have to think not about the content of the array, but the array itself.  
As a _collection_, the array can contain elements of any type - strings, ints, bools, structs, etc.  
And as an _object_ we can add functionality through extensions.

Let's iterate over the process of writing this in a generic way.

Firstly, add an empty `myMap` function in an extension on **Collection**.  
We can ignore any input parameters for the time being, but one thing we _do_ know is that it will return an array. An array of _what_ doesn't matter right now.  
Adding that in the function signature but without specifying the Type, and taking the code above as an example, the structure of the extension starts to take shape.

```
extension Collection {
	func myMap() -> [] {
		var output: [] = []
		
		// Do __something__ here
		
		return output
	}
}
```

Seeing all of these empty brackets everywhere is a bit confusing. 
How about we put a placeholder in for now to say that the array will be of some _Type_. Maybe an _OutputType_

```
extension Collection {
	func myMap() -> [OutputType] {
		var output: [OutputType] = []
		
		// Do __something__ here
		
		return output
	}
}
```

We can see now that this can be called on any collection and will return an array of type _"OutputType"_.

Functionally, it creates an empty starting array, will do _something_ in the middle and at the end return an array with stuff inside. How do we handle the _something_ in the middle?  

## Needing Closure
The _something_ in this case is a closure. A closure is a piece of code, basically a self contained function, that is passed in as if it was a parameter. 
The calling function, in our case `myMap()`, can then execute this closure (function) when it needs to and return a result. 
In our non-generic function above, we wrote this

```    
for item in array {
	output.append("\(item)")
}
```

Where `("\(item)")` turns the item, an Integer in this example, into a String. 

To make things more generic, the specifics of the closure (function) aren't important, only what the closure (function) wants to take *in* and what it will *return*.

Defining a closure (function) that takes in **no** parameters, and return **no** result would look like this

```
( () -> Void )
```

To define a closure that takes in a **String** parameter, and returns a **String** result, would look like this

```
( (String) -> String )
```

To define a closure that takes in an **Int** parameter and returns a **String** result would look like this

```
( (Int) -> String )
```

So following this chain of thought, to specify a Generic Type would look like

```
( (InputType) -> (OutputType) )
```

Transplanting this into our myMap function, it now looks something like this

```
func myMap(_ transformation: ((InputType) -> OutputType) -> [OutputType] {

	var output:[OutputType] = []

	// do _something_ here

	return output
}
```


## Transformers in Disguise

Finally onto the _something_ in our function.

This bit is relatively simple compared to the rest. All we want to do is iterate over the collection, pass the current item into our closure and save the result.

Calling a closure is done as you would a normal function call

```
var output:[OutputType] = []

	for item in self {
		let transformedItem = transformation(item)
		output.append(transformedItem)
	}

return output
```

simple :)


## Conforming to Type

The last piece of the puzzle in all of this, is how does the compiler know what all of these types are? We've said _InputType_ and _OutputType_, but what do they mean? How does Swift know how to relate them to anything?

We need to use some interesting syntax.

If we want to use Type placeholders in a generic function, we need to _declare_ them before we use them. 
The way this is done is by placing them within angled braces (< >) **after** the function name, but **before** the parameters. 

```
func myMap<InputType, OutputType>(_ transformation: ((InputType) -> OutputType) -> [OutputType] 
```

All we have left to do is _constrain_ this extension to only be for objects within that collection that conform to that specific type. Otherwise the compiler can't process what type it should be dealing with and will throw an error.

This is done with a slight modification to our function, using the `where` keyword. 
Using `where` allows us to constrain the availability of this extension's function to only places where the array matches our criteria.

```
func myMap<InputType, OutputType>(_ transformation: ((InputType) -> OutputType) -> [OutputType] where Element == InputType
```

This says "Only allow `myMap()` to be used on Collections where the items inside are of the type that I've specified.".

In practical usage, this wouldn't have much of an impact since heterogeneous collections aren't allowed unless you force them into the `Any` type...in which case this _does_ work as you've now specified the type to be `Any`!

### The Finished Article

With all of these pieces put together we end up with a function that looks like the following

```
func myMap<InputType, OutputType>(_ transformation: ((InputType) -> OutputType) -> [OutputType] where Element == InputType {

	var output:[OutputType] = []
	
		for item in self {
			let transformedItem = transformation(item)
			output.append(transformedItem)
		}
	
	return output
}
```

If you copy this into a Swift Playground and call it alongside the built-in version of Map, you should see exactly the same result.

```
let array = [1,2,3,4,5]
let originalMap = array.map { "\($0)" }
let rewrittenMap = array.myMap { "\($0)" }
print(originalMap) //["1", "2", "3", "4", "5"]
print(rewrittenMap) //["1", "2", "3", "4", "5"]
```



## Wrap Up

Hopefully this helps to get a bit of a better insight to what a generic function is and how it can be incredibly powerful. 
The above will work for all object types, either built in or your own Structs/Classes, and without requiring _any_ code changes to handle the specifics of those objects.

Writing our own generic functions takes a slightly different approach to how we would normally write code, but it can give a flexible, clean and reusable set of tools to use alongside your more traditional techniques.

Of course, the topic of Generics goes much deeper and further than this, with The **Swift Programming Language eBook** ( [https://swift.org/documentation/#the-swift-programming-language](https://swift.org/documentation/#the-swift-programming-language) ) providing a useful chapter on this subject.

As a further exercise, you could look into how to adapt this generic function to be able to map `Dictionary` objects. Perhaps I'll write that as a follow up in the upcoming months.
