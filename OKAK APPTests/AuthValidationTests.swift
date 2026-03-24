
import Testing
import Foundation
@testable import OKAK_APP

struct AuthValidationTests {
    @Test func acceptsValidEmail() {
        #expect(AuthValidation.isValidEmail("user.name+tag@okak.club"))
        #expect(AuthValidation.isValidEmail("a@b.io"))
    }

    @Test func rejectsInvalidEmail() {
        #expect(!AuthValidation.isValidEmail(""))
        #expect(!AuthValidation.isValidEmail("plain"))
        #expect(!AuthValidation.isValidEmail("missing@dot"))
        #expect(!AuthValidation.isValidEmail("@nouser.io"))
    }

    @Test func passwordTooShort() {
        #expect(AuthValidation.passwordIssue("Short1") != nil)
    }

    @Test func passwordNeedsLettersAndDigits() {
        #expect(AuthValidation.passwordIssue("1234567890") != nil)
        #expect(AuthValidation.passwordIssue("abcdefghij") != nil)
        #expect(AuthValidation.passwordIssue("Strong1Password!") == nil)
    }

    @Test func ageGate() {
        let now = Date()
        let cal = Calendar.current
        let teen = cal.date(byAdding: .year, value: -13, to: now)!
        let adult = cal.date(byAdding: .year, value: -18, to: now)!
        #expect(!AuthValidation.isAdult(teen))
        #expect(AuthValidation.isAdult(adult))
    }
}
