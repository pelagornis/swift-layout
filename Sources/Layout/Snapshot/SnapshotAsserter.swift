import UIKit

/// Helper for snapshot assertions in tests
@MainActor
public final class SnapshotAsserter {
    public let recordMode: Bool
    public let tolerance: CGFloat
    
    public init(recordMode: Bool = false, tolerance: CGFloat = 0.01) {
        self.recordMode = recordMode
        self.tolerance = tolerance
        SnapshotEngine.shared.tolerance = tolerance
    }
    
    /// Asserts that a layout matches its reference snapshot
    @discardableResult
    public func assertSnapshot(
        _ layout: any Layout,
        named name: String,
        config: SnapshotConfig = SnapshotConfig(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> Bool {
        let result = SnapshotEngine.shared.verify(layout, named: name, config: config, record: recordMode)
        
        if !result.matched && !recordMode {
            print("Snapshot mismatch at \(file):\(line)")
            print("Difference: \(result.difference * 100)%")
        }
        
        return result.matched
    }
}

