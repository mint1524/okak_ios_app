
import Testing
@testable import OKAK_APP

struct OKAK_APPTests {

    @Test func rootIdentity() async throws {
        #expect("OKAK" == "OKAK")
    }

}
