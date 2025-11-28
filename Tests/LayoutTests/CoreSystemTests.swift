import XCTest
@testable import Layout

@MainActor
final class CoreSystemTests: XCTestCase {
    
    // MARK: - Layout Invalidation Tests
    
    func testLayoutInvalidation() {
        let view = UIView()
        
        // Test invalidation
        view.invalidateLayout(reason: .contentChanged)
        
        XCTAssertTrue(LayoutInvalidationContext.shared.hasPendingInvalidation(for: view))
        
        // Clear invalidation
        LayoutInvalidationContext.shared.clearInvalidation(for: view)
        XCTAssertFalse(LayoutInvalidationContext.shared.hasPendingInvalidation(for: view))
    }
    
    func testInvalidationReasons() {
        let view = UIView()
        
        view.invalidateLayout(reason: .contentChanged)
        view.invalidateLayout(reason: .sizeChanged)
        
        let reasons = LayoutInvalidationContext.shared.pendingReasons(for: view)
        XCTAssertTrue(reasons.contains(.contentChanged))
        XCTAssertTrue(reasons.contains(.sizeChanged))
    }
    
    func testDirtyRegionTracker() {
        let tracker = DirtyRegionTracker()
        
        XCTAssertTrue(tracker.dirtyRect.isNull)
        
        tracker.markDirty(CGRect(x: 0, y: 0, width: 100, height: 100))
        XCTAssertEqual(tracker.dirtyRect, CGRect(x: 0, y: 0, width: 100, height: 100))
        
        tracker.markDirty(CGRect(x: 50, y: 50, width: 100, height: 100))
        XCTAssertEqual(tracker.dirtyRect, CGRect(x: 0, y: 0, width: 150, height: 150))
        
        tracker.clear()
        XCTAssertTrue(tracker.dirtyRect.isNull)
    }
    
    // MARK: - Animation Engine Tests
    
    func testAnimationTimingFunction() {
        // Linear
        let linear = AnimationTimingFunction.linear
        XCTAssertEqual(linear.value(at: 0), 0, accuracy: 0.001)
        XCTAssertEqual(linear.value(at: 0.5), 0.5, accuracy: 0.001)
        XCTAssertEqual(linear.value(at: 1), 1, accuracy: 0.001)
        
        // Ease In
        let easeIn = AnimationTimingFunction.easeIn
        XCTAssertEqual(easeIn.value(at: 0), 0, accuracy: 0.001)
        XCTAssertEqual(easeIn.value(at: 1), 1, accuracy: 0.001)
        XCTAssertLessThan(easeIn.value(at: 0.5), 0.5) // Ease in is slower at start
        
        // Ease Out
        let easeOut = AnimationTimingFunction.easeOut
        XCTAssertEqual(easeOut.value(at: 0), 0, accuracy: 0.001)
        XCTAssertEqual(easeOut.value(at: 1), 1, accuracy: 0.001)
        XCTAssertGreaterThan(easeOut.value(at: 0.5), 0.5) // Ease out is faster at start
    }
    
    func testLayoutAnimation() {
        let defaultAnimation = LayoutAnimation.default
        XCTAssertEqual(defaultAnimation.duration, 0.3)
        XCTAssertEqual(defaultAnimation.delay, 0)
        
        let springAnimation = LayoutAnimation.spring
        XCTAssertEqual(springAnimation.duration, 0.5)
        
        let quickAnimation = LayoutAnimation.quick
        XCTAssertEqual(quickAnimation.duration, 0.15)
    }
    
    func testVectorArithmetic() {
        // CGFloat
        let float1: CGFloat = 10
        let float2: CGFloat = 20
        XCTAssertEqual(float1.interpolated(towards: float2, amount: 0.5), 15)
        
        // CGPoint
        let point1 = CGPoint(x: 0, y: 0)
        let point2 = CGPoint(x: 100, y: 100)
        let midPoint = point1.interpolated(towards: point2, amount: 0.5)
        XCTAssertEqual(midPoint.x, 50)
        XCTAssertEqual(midPoint.y, 50)
        
        // CGSize
        let size1 = CGSize(width: 0, height: 0)
        let size2 = CGSize(width: 100, height: 200)
        let midSize = size1.interpolated(towards: size2, amount: 0.5)
        XCTAssertEqual(midSize.width, 50)
        XCTAssertEqual(midSize.height, 100)
    }
    
    // MARK: - Environment System Tests
    
    func testEnvironmentValues() {
        let env = EnvironmentValues()
        
        // Test default values
        XCTAssertEqual(env.colorScheme, .light)
        XCTAssertTrue(env.isEnabled)
        XCTAssertEqual(env.minimumScaleFactor, 1.0)
        
        // Test setting values
        env.colorScheme = .dark
        XCTAssertEqual(env.colorScheme, .dark)
        
        env.isEnabled = false
        XCTAssertFalse(env.isEnabled)
    }
    
    func testEnvironmentInheritance() {
        let parent = EnvironmentValues()
        parent.colorScheme = .dark
        parent.font = UIFont.boldSystemFont(ofSize: 20)
        
        let child = parent.makeChild()
        
        // Child inherits parent values
        XCTAssertEqual(child.colorScheme, .dark)
        XCTAssertEqual(child.font, UIFont.boldSystemFont(ofSize: 20))
        
        // Child can override
        child.colorScheme = .light
        XCTAssertEqual(child.colorScheme, .light)
        XCTAssertEqual(parent.colorScheme, .dark) // Parent unchanged
    }
    
    func testEnvironmentProvider() {
        let provider = EnvironmentProvider.shared
        let view = UIView()
        
        let env = provider.environment(for: view)
        XCTAssertNotNil(env)
    }
    
    // MARK: - Geometry System Tests
    
    func testGeometryProxy() {
        let proxy = GeometryProxy(
            size: CGSize(width: 100, height: 200),
            safeAreaInsets: UIEdgeInsets(top: 44, left: 0, bottom: 34, right: 0),
            globalFrame: CGRect(x: 0, y: 0, width: 100, height: 200)
        )
        
        XCTAssertEqual(proxy.size.width, 100)
        XCTAssertEqual(proxy.size.height, 200)
        XCTAssertEqual(proxy.safeAreaInsets.top, 44)
        XCTAssertEqual(proxy.bounds, CGRect(x: 0, y: 0, width: 100, height: 200))
    }
    
    func testCoordinateSpaceRegistry() {
        let registry = CoordinateSpaceRegistry.shared
        
        registry.register(name: "TestSpace", frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        
        let frame = registry.frame(for: "TestSpace")
        XCTAssertEqual(frame, CGRect(x: 100, y: 100, width: 200, height: 200))
        
        registry.unregister(name: "TestSpace")
        XCTAssertNil(registry.frame(for: "TestSpace"))
    }
    
    func testUnitPoint() {
        XCTAssertEqual(UnitPoint.zero.x, 0)
        XCTAssertEqual(UnitPoint.zero.y, 0)
        
        XCTAssertEqual(UnitPoint.center.x, 0.5)
        XCTAssertEqual(UnitPoint.center.y, 0.5)
        
        XCTAssertEqual(UnitPoint.bottomTrailing.x, 1)
        XCTAssertEqual(UnitPoint.bottomTrailing.y, 1)
    }
    
    // MARK: - Layout Cache Tests
    
    func testLayoutCache() {
        let cache = LayoutCache.shared
        cache.clearAll()
        cache.resetStatistics()
        
        let key = LayoutCacheKey(bounds: CGRect(x: 0, y: 0, width: 100, height: 100), contentHash: 123)
        let result = LayoutResult(frames: [:], totalSize: CGSize(width: 100, height: 100))
        
        // Cache miss
        XCTAssertNil(cache.get(key))
        XCTAssertEqual(cache.cacheMisses, 1)
        
        // Set and get
        cache.set(result, for: key)
        let cached = cache.get(key)
        XCTAssertNotNil(cached)
        XCTAssertEqual(cache.cacheHits, 1)
    }
    
    func testCacheEviction() {
        let cache = LayoutCache.shared
        cache.clearAll()
        cache.maxCacheSize = 5
        
        // Add more than max size
        for i in 0..<10 {
            let key = LayoutCacheKey(bounds: CGRect(x: 0, y: 0, width: CGFloat(i), height: 100), contentHash: i)
            let result = LayoutResult(frames: [:], totalSize: CGSize(width: CGFloat(i), height: 100))
            cache.set(result, for: key)
        }
        
        XCTAssertLessThanOrEqual(cache.currentSize, 5)
    }
    
    // MARK: - Priority System Tests
    
    func testLayoutPriority() {
        XCTAssertGreaterThan(LayoutPriority.required, LayoutPriority.defaultHigh)
        XCTAssertGreaterThan(LayoutPriority.defaultHigh, LayoutPriority.defaultLow)
        XCTAssertGreaterThan(LayoutPriority.high, LayoutPriority.low)
    }
    
    func testPrioritySizeCalculator() {
        let items: [(minSize: CGFloat, maxSize: CGFloat, priority: LayoutPriority)] = [
            (50, 100, .low),
            (50, 100, .high),
            (50, 100, .medium)
        ]
        
        let sizes = PrioritySizeCalculator.calculateSizes(
            for: items,
            availableSpace: 200,
            spacing: 10
        )
        
        XCTAssertEqual(sizes.count, 3)
        XCTAssertEqual(sizes.reduce(0, +), 200 - 20, accuracy: 1) // Total should be available - spacing
    }
    
    // MARK: - Snapshot Testing Tests
    
    func testSnapshotConfig() {
        let config = SnapshotConfig(size: CGSize(width: 390, height: 844))
        XCTAssertEqual(config.size, CGSize(width: 390, height: 844))
        
        let darkConfig = config.darkMode()
        XCTAssertEqual(darkConfig.backgroundColor, UIColor.black)
        
        let landscapeConfig = config.landscape()
        XCTAssertEqual(landscapeConfig.size, CGSize(width: 844, height: 390))
    }
    
    func testSnapshotComparison() {
        let engine = SnapshotEngine.shared
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .red
        
        let image1 = engine.snapshot(view, config: SnapshotConfig(size: CGSize(width: 100, height: 100)))
        let image2 = engine.snapshot(view, config: SnapshotConfig(size: CGSize(width: 100, height: 100)))
        
        let result = engine.compare(image1, with: image2)
        XCTAssertTrue(result.matched)
        XCTAssertEqual(result.difference, 0, accuracy: 0.01)
    }
    
    // MARK: - Performance Profiler Tests
    
    func testPerformanceProfiler() {
        let profiler = PerformanceProfiler.shared
        profiler.clear()
        
        let token = profiler.beginProfiling("TestOperation")
        
        // Simulate some work
        for _ in 0..<1000 {
            _ = UUID()
        }
        
        token.end(viewCount: 10)
        
        let profiles = profiler.allProfiles
        XCTAssertEqual(profiles.count, 1)
        XCTAssertEqual(profiles.first?.name, "TestOperation")
        XCTAssertEqual(profiles.first?.viewCount, 10)
    }
    
    func testPerformanceThresholds() {
        let defaultThresholds = PerformanceThreshold.default
        XCTAssertEqual(defaultThresholds.maxLayoutTime, 16.67, accuracy: 0.01)
        
        let strictThresholds = PerformanceThreshold.strict
        XCTAssertEqual(strictThresholds.maxLayoutTime, 8)
    }
    
    func testFrameRateMonitor() {
        let monitor = FrameRateMonitor.shared
        
        XCTAssertFalse(monitor.isMonitoring)
        XCTAssertEqual(monitor.currentFPS, 60)
        
        monitor.start()
        XCTAssertTrue(monitor.isMonitoring)
        
        monitor.stop()
        XCTAssertFalse(monitor.isMonitoring)
    }
}

