public extension Array {
    /// Splits the array into chunks of the specified size.
    ///
    /// - Parameter size: The maximum size of each chunk
    /// - Returns: An array of arrays, each containing at most `size` elements
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}