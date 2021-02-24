import Foundation

/*
    Making a functional map function
    1. Array
 */


let array = [1,2,3,4,5]
let originalMap = array.map { "\($0)" }

print(originalMap)

func myMap(_ array:[Int]) -> [String] {
    
    var output: [String] = []
    
    for item in array {
        output.append("\(item)")
    }
    
    return output
}

print(myMap(array))


extension Collection {

    func myMap<T, O>(_ transform: ((T) -> O)) -> [O] where Element == T {
        var output:[O] = []

        for item in self {
            let transformed = transform(item)
            output.append(transformed)
        }

        return output
    }
}

let rewrittenMap = array.myMap { "\($0)" }
print(rewrittenMap)

////////////////////////////


/*
 2. Dictionary
 */

print("     Dictionary")
let dict = [1: "hello", 2: "wOrlD", 3: "fROm", 4: "Space"]
let dictMap = dict.map({ "\($0.key) - \($0.value.uppercased())"})

print(dictMap)


extension Dictionary {
    
    func myMap<O>(_ transform: ((_ key: Key, _ value: Value ) -> O)) -> [O] {
        
        var output: [O] = []
        
        for item in self {
            let transformed = transform(item.key, item.value)
            output.append(transformed)
        }
        
        return output
    }
}

let rewrittenDictMap = dict.myMap({ "\($0.key) - \($0.value.uppercased())"})
print(rewrittenDictMap)


/*
 3.Filter
 */

print("     filter")
let originalFilter = array.filter { $0 > 3 }
print(originalFilter)

extension Collection {
    
    func myFilter<T>(_ isIncluded: ((T) -> Bool)) -> [T] where Element == T {
     
        var output: [T] = []
        
        for item in self where isIncluded(item) == true {
            output.append(item)
        }
        
        return output
    }
}
let myFilter = array.myFilter { $0 > 3 }
print(myFilter)


/*
 4. Reduce
 */

print("     Reduce")
let originalReduce = array.reduce(0, { $0 + $1 })
print(originalReduce)

extension Collection {
    
    func myReduce<T>(_ initial: T, _ next: ((T, T) -> T)) -> T where Element == T{
        
        var runningTotal: T = initial
        
        for item in self {
            runningTotal = next(runningTotal, item)
        }
        
        return runningTotal
    }
}

let myReduce = array.myReduce(0, { $0 + $1 })
print(myReduce)

let stringsArray = ["Hello", "World", "From", "Me"]
print(stringsArray.reduce("", { $0 + " " + $1 }))
print(stringsArray.myReduce("", { $0 + " " + $1 }))
/*
 5. chained functions
 */

print("     Chained Functions")
let chainedOutput = array.myMap({ $0 * 3 })
    .myFilter({ $0 > 10 })
    .myMap({ "\($0)"})
print(chainedOutput)
