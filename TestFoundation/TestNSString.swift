// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//


#if DEPLOYMENT_RUNTIME_OBJC || os(Linux)
import Foundation
import XCTest
#else
import SwiftFoundation
import SwiftXCTest
#endif


class TestNSString : XCTestCase {
    
    var allTests : [(String, () -> ())] {
        return [
            ("test_BridgeConstruction", test_BridgeConstruction ),
            ("test_isEqualToStringWithSwiftString", test_isEqualToStringWithSwiftString ),
            ("test_FromASCIIData", test_FromASCIIData ),
            ("test_FromUTF8Data", test_FromUTF8Data ),
            ("test_FromMalformedUTF8Data", test_FromMalformedUTF8Data ),
            ("test_FromASCIINSData", test_FromASCIINSData ),
            ("test_FromUTF8NSData", test_FromUTF8NSData ),
            ("test_FromMalformedUTF8NSData", test_FromMalformedUTF8NSData ),
            ("test_FromNullTerminatedCStringInASCII", test_FromNullTerminatedCStringInASCII ),
            ("test_FromNullTerminatedCStringInUTF8", test_FromNullTerminatedCStringInUTF8 ),
            ("test_FromMalformedNullTerminatedCStringInUTF8", test_FromMalformedNullTerminatedCStringInUTF8 ),
            ("test_uppercaseString", test_uppercaseString ),
            ("test_lowercaseString", test_lowercaseString ),
            ("test_capitalizedString", test_capitalizedString ),
        ]
    }
    
    func test_BridgeConstruction() {
        let literalConversion: NSString = "literal"
        XCTAssertEqual(literalConversion.length, 7)
        
        let nonLiteralConversion: NSString = "test\(self)".bridge()
        XCTAssertTrue(nonLiteralConversion.length > 4)
        
        let nonLiteral2: NSString = String(4).bridge()
        let t = nonLiteral2.characterAtIndex(0)
        XCTAssertTrue(t == 52)
        
        let externalString: NSString = String.localizedNameOfStringEncoding(String.defaultCStringEncoding()).bridge()
        XCTAssertTrue(externalString.length > 4)
        
        let cluster: NSString = "✌🏾"
        XCTAssertEqual(cluster.length, 3)
    }

    func test_isEqualToStringWithSwiftString() {
        let string: NSString = "literal"
        let swiftString = "literal"
        XCTAssertTrue(string.isEqualToString(swiftString))
    }

    internal let mockASCIIStringBytes: [UInt8] = [0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x53, 0x77, 0x69, 0x66, 0x74, 0x21]
    internal let mockASCIIString = "Hello Swift!"
    internal let mockUTF8StringBytes: [UInt8] = [0x49, 0x20, 0xE2, 0x9D, 0xA4, 0xEF, 0xB8, 0x8F, 0x20, 0x53, 0x77, 0x69, 0x66, 0x74]
    internal let mockUTF8String = "I ❤️ Swift"
    internal let mockMalformedUTF8StringBytes: [UInt8] = [0xFF]

    func test_FromASCIIData() {
        let bytes = mockASCIIStringBytes
        let string = NSString(bytes: bytes, length: bytes.count, encoding: NSASCIIStringEncoding)
        XCTAssertNotNil(string)
        XCTAssertTrue(string?.isEqualToString(mockASCIIString) ?? false)
    }

    func test_FromUTF8Data() {
        let bytes = mockUTF8StringBytes
        let string = NSString(bytes: bytes, length: bytes.count, encoding: NSUTF8StringEncoding)
        XCTAssertNotNil(string)
        XCTAssertTrue(string?.isEqualToString(mockUTF8String) ?? false)
    }

    func test_FromMalformedUTF8Data() {
        let bytes = mockMalformedUTF8StringBytes
        let string = NSString(bytes: bytes, length: bytes.count, encoding: NSUTF8StringEncoding)
        XCTAssertNil(string)
    }

    func test_FromASCIINSData() {
        let bytes = mockASCIIStringBytes
        let data = NSData(bytes: bytes, length: bytes.count)
        let string = NSString(data: data, encoding: NSASCIIStringEncoding)
        XCTAssertNotNil(string)
        XCTAssertTrue(string?.isEqualToString(mockASCIIString) ?? false)
    }

    func test_FromUTF8NSData() {
        let bytes = mockUTF8StringBytes
        let data = NSData(bytes: bytes, length: bytes.count)
        let string = NSString(data: data, encoding: NSUTF8StringEncoding)
        XCTAssertNotNil(string)
        XCTAssertTrue(string?.isEqualToString(mockUTF8String) ?? false)
    }

    func test_FromMalformedUTF8NSData() {
        let bytes = mockMalformedUTF8StringBytes
        let data = NSData(bytes: bytes, length: bytes.count)
        let string = NSString(data: data, encoding: NSUTF8StringEncoding)
        XCTAssertNil(string)
    }

    func test_FromNullTerminatedCStringInASCII() {
        let bytes = mockASCIIStringBytes + [0x00]
        let string = NSString(CString: bytes.map { Int8(bitPattern: $0) }, encoding: NSASCIIStringEncoding)
        XCTAssertNotNil(string)
        XCTAssertTrue(string?.isEqualToString(mockASCIIString) ?? false)
    }

    func test_FromNullTerminatedCStringInUTF8() {
        let bytes = mockUTF8StringBytes + [0x00]
        let string = NSString(CString: bytes.map { Int8(bitPattern: $0) }, encoding: NSUTF8StringEncoding)
        XCTAssertNotNil(string)
        XCTAssertTrue(string?.isEqualToString(mockUTF8String) ?? false)
    }

    func test_FromMalformedNullTerminatedCStringInUTF8() {
        let bytes = mockMalformedUTF8StringBytes + [0x00]
        let string = NSString(CString: bytes.map { Int8(bitPattern: $0) }, encoding: NSUTF8StringEncoding)
        XCTAssertNil(string)
    }

    func test_uppercaseString() {
        XCTAssertEqual(NSString(stringLiteral: "abcd").uppercaseString, "ABCD")
        XCTAssertEqual(NSString(stringLiteral: "абВГ").uppercaseString, "АБВГ")
        XCTAssertEqual(NSString(stringLiteral: "たちつてと").uppercaseString, "たちつてと")

        // Special casing (see swift/validation-tests/stdlib/NSStringAPI.swift)
        XCTAssertEqual(NSString(stringLiteral: "\u{0069}").uppercaseStringWithLocale(NSLocale(localeIdentifier: "en")), "\u{0049}")
        XCTAssertEqual(NSString(stringLiteral: "\u{0069}").uppercaseStringWithLocale(NSLocale(localeIdentifier: "tr")), "\u{0130}")
        XCTAssertEqual(NSString(stringLiteral: "\u{00df}").uppercaseString, "\u{0053}\u{0053}")
        XCTAssertEqual(NSString(stringLiteral: "\u{fb01}").uppercaseString, "\u{0046}\u{0049}")
    }

    func test_lowercaseString() {
        XCTAssertEqual(NSString(stringLiteral: "abCD").lowercaseString, "abcd")
        XCTAssertEqual(NSString(stringLiteral: "aБВГ").lowercaseString, "aбвг")
        XCTAssertEqual(NSString(stringLiteral: "たちつてと").lowercaseString, "たちつてと")

        // Special casing (see swift/validation-tests/stdlib/NSStringAPI.swift)
        XCTAssertEqual(NSString(stringLiteral: "\u{0130}").lowercaseStringWithLocale(NSLocale(localeIdentifier: "en")), "\u{0069}\u{0307}")
        XCTAssertEqual(NSString(stringLiteral: "\u{0130}").lowercaseStringWithLocale(NSLocale(localeIdentifier: "tr")), "\u{0069}")
        XCTAssertEqual(NSString(stringLiteral: "\u{0049}\u{0307}").lowercaseStringWithLocale(NSLocale(localeIdentifier: "en")), "\u{0069}\u{0307}")
        XCTAssertEqual(NSString(stringLiteral: "\u{0049}\u{0307}").lowercaseStringWithLocale(NSLocale(localeIdentifier: "tr")), "\u{0069}")
    }

    func test_capitalizedString() {
        XCTAssertEqual(NSString(stringLiteral: "foo Foo fOO FOO").capitalizedString, "Foo Foo Foo Foo")
        XCTAssertEqual(NSString(stringLiteral: "жжж").capitalizedString, "Жжж")
    }
}