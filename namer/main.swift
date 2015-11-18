//
//  main.swift
//  namer
//
//  Created by mikel evins on 11/12/15.
//  Copyright © 2015 mikel evins. All rights reserved.
//

import Swift
import Foundation

// ---------------------------------------------
// utils
// ---------------------------------------------

// accessors for String
// --------------------

func stringLength (s: String) -> Int{
    return s.characters.count
}

func substring (s:String, start: Int, end: Int) -> String{
    let r = Range(start: s.startIndex.advancedBy(start), end: (s.startIndex.advancedBy(end)))
    return s.substringWithRange(r)
}

func take (count: Int,fromString: String) -> String {
    return substring(fromString, start: 0, end: (count))
}

func takeFrom (start: Int, count: Int, fromString: String) -> String {
    return substring(fromString, start: start, end: (start+count))
}

func drop (count: Int, fromString: String) -> String {
    let len = stringLength(fromString)
    return substring(fromString, start: count, end: len)
}

func leave (count: Int, fromString: String) -> String {
    let len = stringLength(fromString)
    return substring(fromString, start: len-count, end: len)
}

// String extensions
// ----------------

extension String {
    func equal(s: String) -> Bool {
        if self.caseInsensitiveCompare(s) == NSComparisonResult.OrderedSame {
            return true
        } else {
            return false
        }
    }
}

// Array extensions
// ----------------

extension Array {
    var head : Element {
        return self[0]
    }
}

extension Array {
    var tail : [Element] {
        return Array(self[1..<count])
    }
}

extension Array {
    var end : Element {
        return self[self.count-1]
    }
}

extension Array {
    var any : Element {
        let count = self.count
        let index = self.startIndex.advancedBy(Int(arc4random_uniform(UInt32(count))))
        return self[index]
    }
}

func findIn(list: [String], string: String) -> Bool{
        for it in list {
            if it.equal(string) {
                return true
            }
        }
        return false
}


// ---------------------------------------------
// namer code
// ---------------------------------------------


func longEnough(s:String) -> Bool{
    return stringLength(s) > 2
}


func triples(s:String) -> [String] {
    let r = Range(start: 0, end: s.characters.count-2)
    var result: [String] = []
    for i in r {
        result += [(takeFrom(i,count: 3,fromString: s))]
    }
    return result
}

func readNames(path : String) -> [String] {
    if let namedata = try? String(contentsOfFile: path, usedEncoding: nil) {
        let names = namedata.componentsSeparatedByString("\n")
        let filteredNames = names.filter({longEnough($0)})
        return filteredNames
    } else {
        return []
    }
}

func isMergeable(left: String, right: String) -> Bool {
    if leave(2, fromString: left) == take(2, fromString: right) {
        return true
    } else {
        return false
    }
}

func mergeParts(left:String, right:String) -> String{
    var result = left
    result += right.substringFromIndex(right.startIndex.advancedBy(2))
    return result
}

func findExtension(start: String, parts: [String]) -> String {
    let candidates = parts.filter({isMergeable(start,right: $0)})
    return candidates.any
}

func extendName (start: String, parts: [String], ends:[String]) -> String {
    let next = findExtension(start, parts: parts)
    let newStart = mergeParts(start, right:next)
    if findIn(ends, string: next) {
        return newStart
    } else {
        return extendName(newStart, parts: parts, ends: ends)
    }
}

func generateNames (rules: String, count: Int) -> [String]{
    let path = rules
    let nameSamples = readNames(path)
    let nameTriples = nameSamples.map(triples)
    let nameStarts = nameTriples.map({$0.head})
    let nameParts = nameTriples.map({$0.tail}).reduce([],combine: {$0 + $1})
    let nameEnds = nameTriples.map({$0.end})
    var result: [String] = []
    for _ in 0..<count {
        let start = nameStarts.any
        result += [extendName(start, parts: nameParts, ends: nameEnds)]
    }
    return result
}

let args = [String](Process.arguments)
let path = args[1]
let count = Int(args[2])!
let nms = generateNames(path, count: count)
print(nms)


