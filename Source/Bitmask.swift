//
//  Bitmask.swift
//  SwiftBitmask
//
//  Created by bryn austin bellomy on 2014 Nov 21.
//  Copyright (c) 2014 bryn austin bellomy. All rights reserved.
//

import Foundation


public protocol IBitmaskRepresentable: Equatable, Hashable
{
    associatedtype BitmaskRawType: IBitmaskRawType
    var bitmaskValue: BitmaskRawType { get }
}


public protocol IBitmaskRawType: BitwiseOperations, Equatable, Comparable
{
    init(_ v:Int)
    var integerValue: Int { get set }
}


public struct Bitmask <T: IBitmaskRepresentable> : BitwiseOperations
{
    public typealias BitmaskRawType = T.BitmaskRawType

    public fileprivate(set) var bitmaskValue: BitmaskRawType = BitmaskRawType.allZeros
    
    public var hashValue: Int { return bitmaskValue.integerValue }

    public static var allZeros: Bitmask<T> { return Bitmask(T.BitmaskRawType.allZeros)  }
    public var isAllZeros: Bool { return self == Bitmask.allZeros }

    public init() {}
    public init(_ val: T.BitmaskRawType)        { setValue(val) }
    public init(_ val: [T])                     { setValue(val) }
    public init(_ val: T...)                    { setValue(val) }
    public init(_ val: [T.BitmaskRawType])      { setValue(val) }
    public init(_ val1: T.BitmaskRawType, _ val2: T.BitmaskRawType, _ valRest: T.BitmaskRawType...) { setValue([ val1, val2 ] + valRest) }
    public init(_ val: Bitmask<T>...)           { setValue(val) }


    public mutating func setValue(_ val: T)                { bitmaskValue = val.bitmaskValue }
    public mutating func setValue(_ val: T.BitmaskRawType) { bitmaskValue = val }

    public mutating func setValue(_ val: [T]) {
        setValue(
            val.map { $0.bitmaskValue }.reduce(T.BitmaskRawType.allZeros) { $0 | $1 }
        )
    }

    public mutating func setValue(_ val: [T.BitmaskRawType]) {
        setValue(
            val.reduce(T.BitmaskRawType.allZeros) { $0 | $1 }
        )
    }

    public mutating func setValue(_ val: [Bitmask<T>]) {
        setValue(
            val.map { $0.bitmaskValue }
        )
    }

    public func isSet(_ val:T) -> Bool {
        return (self & val) == val
    }
    
    public func areSet(_ options:T...) -> Bool {
        let otherBitmask = Bitmask(options)
        return (self & otherBitmask).bitmaskValue == otherBitmask.bitmaskValue
    }
}


extension Bitmask: IBitmaskRepresentable {
    public init <U: IBitmaskRepresentable> (_ vals: [U]) {
        let arr = vals.map { $0.bitmaskValue as! T.BitmaskRawType }
        self.init(arr)
    }
}



//
// MARK: - Bitmask: Equatable -
//

extension Bitmask: Equatable {}

public func == <T> (lhs:Bitmask<T>, rhs:Bitmask<T>) -> Bool {
    return lhs.bitmaskValue == rhs.bitmaskValue
}

public func == <T> (lhs:Bitmask<T>, rhs:T) -> Bool {
    return lhs.bitmaskValue == rhs.bitmaskValue
}

public func == <T> (lhs:Bitmask<T>, rhs:T.BitmaskRawType) -> Bool {
    return lhs.bitmaskValue == rhs
}



//
// MARK: - Bitmask: Comparable -
//

extension Bitmask: Comparable {}

public func < <T> (lhs:Bitmask<T>, rhs:Bitmask<T>) -> Bool {
    return lhs.bitmaskValue < rhs.bitmaskValue
}



//
// MARK: - Bitmask: NilLiteralConvertible -
//

extension Bitmask: ExpressibleByNilLiteral
{
    public init(nilLiteral: ())
    {
        self.init(BitmaskRawType.allZeros)
    }
}



//
// MARK: - Bitmask: BooleanType -
//

extension Bitmask
{
    /** For bitmasks, `boolValue` is `true` as long as any bit is set. */
    public var boolValue: Bool { return !isAllZeros }
}



//
// MARK: - Operators -
// MARK: - Quick instantiation prefix operator
//

prefix operator |

public prefix func | <T: IBitmaskRepresentable> (val:T) -> Bitmask<T> {
    return Bitmask<T>(val)
}



//
// MARK: - Bitwise OR
//

public func | <T: IBitmaskRepresentable> (lhs:Bitmask<T>, rhs:Bitmask<T>) -> Bitmask<T> { return Bitmask(lhs.bitmaskValue | rhs.bitmaskValue) }
public func | <T: IBitmaskRepresentable> (lhs:Bitmask<T>, rhs:T)          -> Bitmask<T> { return Bitmask(lhs.bitmaskValue | rhs.bitmaskValue) }
public func | <T: IBitmaskRepresentable> (lhs:T, rhs:Bitmask<T>)          -> Bitmask<T> { return rhs | lhs }
public func | <T: IBitmaskRepresentable> (lhs:T, rhs:T)                   -> Bitmask<T> { return Bitmask(lhs.bitmaskValue | rhs.bitmaskValue) }

public func |= <T: IBitmaskRepresentable> (lhs:inout Bitmask<T>, rhs:T)          { lhs.setValue(lhs.bitmaskValue | rhs.bitmaskValue) }
public func |= <T: IBitmaskRepresentable> (lhs:inout Bitmask<T>, rhs:Bitmask<T>) { lhs.setValue(lhs.bitmaskValue | rhs.bitmaskValue) }



//
// MARK: - Bitwise AND
//

public func & <T: IBitmaskRepresentable> (lhs:Bitmask<T>, rhs:Bitmask<T>) -> Bitmask<T> { return Bitmask(lhs.bitmaskValue & rhs.bitmaskValue) }
public func & <T: IBitmaskRepresentable> (lhs:Bitmask<T>, rhs:T)          -> Bitmask<T> { return Bitmask(lhs.bitmaskValue & rhs.bitmaskValue) }
public func & <T: IBitmaskRepresentable> (lhs:T,          rhs:Bitmask<T>) -> Bitmask<T> { return rhs & lhs }
public func & <T: IBitmaskRepresentable> (lhs:T, rhs:T)                   -> Bitmask<T> { return Bitmask(lhs.bitmaskValue & rhs.bitmaskValue) }

public func &= <T: IBitmaskRepresentable> (lhs:inout Bitmask<T>, rhs:T)          { lhs.setValue(lhs.bitmaskValue & rhs.bitmaskValue) }
public func &= <T: IBitmaskRepresentable> (lhs:inout Bitmask<T>, rhs:Bitmask<T>) { lhs.setValue(lhs.bitmaskValue & rhs.bitmaskValue) }



//
// MARK: - Bitwise XOR
//

public func ^ <T: IBitmaskRepresentable> (lhs:Bitmask<T>, rhs:Bitmask<T>) -> Bitmask<T> { return Bitmask(lhs.bitmaskValue ^ rhs.bitmaskValue) }
public func ^ <T: IBitmaskRepresentable> (lhs:Bitmask<T>, rhs:T)          -> Bitmask<T> { return Bitmask(lhs.bitmaskValue ^ rhs.bitmaskValue) }
public func ^ <T: IBitmaskRepresentable> (lhs:T, rhs:Bitmask<T>)          -> Bitmask<T> { return rhs ^ lhs }
public func ^ <T: IBitmaskRepresentable> (lhs:T, rhs:T)                   -> Bitmask<T> { return Bitmask(lhs.bitmaskValue ^ rhs.bitmaskValue) }

public func ^= <T: IBitmaskRepresentable> (lhs:inout Bitmask<T>, rhs:T)          { lhs.setValue(lhs.bitmaskValue ^ rhs.bitmaskValue) }
public func ^= <T: IBitmaskRepresentable> (lhs:inout Bitmask<T>, rhs:Bitmask<T>) { lhs.setValue(lhs.bitmaskValue ^ rhs.bitmaskValue) }



//
// MARK: - Bitwise NOT
//

public prefix func ~ <T: IBitmaskRepresentable> (value:Bitmask<T>) -> Bitmask<T> { return Bitmask(~(value.bitmaskValue)) }
public prefix func ~ <T: IBitmaskRepresentable> (value:T)          -> Bitmask<T> { return Bitmask(~(value.bitmaskValue)) }



//
// MARK: - Pattern matching operator
//

public func ~=<T: IBitmaskRepresentable> (pattern: Bitmask<T>, value: Bitmask<T>) -> Bool { return (pattern & value) == value }
public func ~=<T: IBitmaskRepresentable> (pattern: Bitmask<T>, value: T) -> Bool          { return (pattern & value) == value }
public func ~=<T: IBitmaskRepresentable> (pattern: T, value: Bitmask<T>) -> Bool          { return (pattern & value) == value }



//
// MARK: - Built-in type conformance to IBitmaskRawType
//

extension Int: IBitmaskRepresentable, IBitmaskRawType {
    public var bitmaskValue: Int { return self }
    public var integerValue: Int {
        get { return self }
        set { self = newValue }
    }
}

extension Int8: IBitmaskRepresentable, IBitmaskRawType {
    public var bitmaskValue: Int8 { return self }
    public var integerValue: Int {
        get { return numericCast(self) }
        set { self = numericCast(newValue) }
    }
}
extension Int16: IBitmaskRepresentable, IBitmaskRawType {
    public var bitmaskValue: Int16 { return self }
    public var integerValue: Int {
        get { return numericCast(self) }
        set { self = numericCast(newValue) }
    }
}
extension Int32: IBitmaskRepresentable, IBitmaskRawType {
    public var bitmaskValue: Int32 { return self }
    public var integerValue: Int {
        get { return numericCast(self) }
        set { self = numericCast(newValue) }
    }
}
extension Int64: IBitmaskRepresentable, IBitmaskRawType {
    public var bitmaskValue: Int64 { return self }
    public var integerValue: Int {
        get { return numericCast(self) }
        set { self = numericCast(newValue) }
    }
}
extension UInt: IBitmaskRepresentable, IBitmaskRawType {
    public var bitmaskValue: UInt { return self }
    public var integerValue: Int {
        get { return numericCast(self) }
        set { self = numericCast(newValue) }
    }
}
extension UInt8: IBitmaskRepresentable, IBitmaskRawType {
    public var bitmaskValue: UInt8 { return self }
    public var integerValue: Int {
        get { return numericCast(self) }
        set { self = numericCast(newValue) }
    }
}
extension UInt16: IBitmaskRepresentable, IBitmaskRawType {
    public var bitmaskValue: UInt16 { return self }
    public var integerValue: Int {
        get { return numericCast(self) }
        set { self = numericCast(newValue) }
    }
}
extension UInt32: IBitmaskRepresentable, IBitmaskRawType {
    public var bitmaskValue: UInt32 { return self }
    public var integerValue: Int {
        get { return numericCast(self) }
        set { self = numericCast(newValue) }
    }
}
extension UInt64: IBitmaskRepresentable, IBitmaskRawType {
    public var bitmaskValue: UInt64 { return self }
    public var integerValue: Int {
        get { return numericCast(self) }
        set { self = numericCast(newValue) }
    }
}








