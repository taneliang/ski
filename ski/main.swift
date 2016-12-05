//
//  main.swift
//  ski
//
//  Created by E-Liang Tan on 12/5/16.
//  Copyright © 2016 E-Liang Tan. All rights reserved.
//

import Foundation

/// A node represents a number on the grid, which can be linked to adjacent nodes to form a tree
class Node: CustomStringConvertible {
    let value: Int
    var childNodes = [(Node, Int)]() // node, elevationChange
    var isRoot = true
    
    init(value: Int) {
        self.value = value
    }
    
    private var cachedMaxPathLength: (length: Int, elevationChange: Int)? = nil
    
    /// Recursively calculates the maximum path length, and elevation change.
    func maxPathLength() -> (length: Int, elevationChange: Int) {
        // Use cached value if possible
        if cachedMaxPathLength != nil {
            return cachedMaxPathLength!
        }
        
        // Get the maxPathLength of every child node, and add the delta to this node
        var mpls = childNodes.map { (child: (Node, Int)) -> (Int, Int) in
            let mpl = child.0.maxPathLength();
            return (mpl.length + 1, mpl.elevationChange + child.1)
        }
        
        // If the path lengths are equal, sort by elevation. Otherwise just sort by path length
        mpls.sort { (a: (Int, Int), b: (Int, Int)) -> Bool in
            if a.0 == b.0 {
                return a.1 > b.1
            }
            return a.0 > b.0
        }
        
        // Cache the return value
        cachedMaxPathLength = mpls.first ?? (0,0) // If there aren't any child nodes, return 0 length and 0 elevation change.
        return cachedMaxPathLength!
    }
    
    // For easy debugging
    var description: String {
        let rootString = (isRoot ? "root" : "child")
        return "Node \(value) \(rootString) \(childNodes.count) children"
    }
}

/// Adds a child node to a parent node if the child is lower than the parent. Does nothing otherwise.
func parentNodeAddChildIfPossible(parent: Node, child: Node) {
    if child.value >= parent.value {
        return
    }
    child.isRoot = false
    parent.childNodes.append((child, parent.value - child.value))
}

// ----------------------------------------------------

// Read data into memory
let file = try String(contentsOfFile: "/Users/E-Liang/Desktop/ski/ski/10001000.txt") // Change the path
//let file = try String(contentsOfFile: "/Users/E-Liang/Desktop/ski/ski/44test.txt")

let fileLines = file.components(separatedBy: "\n").dropFirst()

// Create nodes from the grid
var nodes = [[Node]]()
for line in fileLines {
    var nodeRow = [Node]()
    let lineValues = line.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: " ")
    for val in lineValues {
        nodeRow.append(Node(value: Int(val)!))
    }
    nodes.append(nodeRow)
}

// Link adjacent nodes to form a tree
for i in 0..<nodes.count {
    let nodeLine = nodes[i]
    for j in 0..<nodeLine.count {
        let parent = nodeLine[j]
        
        // Add node before if this isn't the first node in the line
        if j > 0 {
            parentNodeAddChildIfPossible(parent: parent, child: nodeLine[j-1])
        }
        
        // Add node after if this isn't the last node in the line
        if j < nodeLine.count - 1 {
            parentNodeAddChildIfPossible(parent: parent, child: nodeLine[j+1])
        }
        
        // Add node above if this line isn't the first line
        if i > 0 {
            parentNodeAddChildIfPossible(parent: parent, child: nodes[i-1][j])
        }

        // Add node below if this line isn't the last line
        if i < nodes.count - 1 {
            parentNodeAddChildIfPossible(parent: parent, child: nodes[i+1][j])
        }
    }
}

// Make a new superroot node with only roots as its children
let superRootNode = Node(value: 9001)
for nodeLine in nodes {
    for node in nodeLine {
        if node.isRoot {
            superRootNode.childNodes.append((node, 0))
        }
    }
}

// Get result
let maxPathLength = superRootNode.maxPathLength()
print(maxPathLength)
print("\(maxPathLength.0)\(maxPathLength.1)@redmart.com")
