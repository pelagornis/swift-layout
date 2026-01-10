import XCTest
import UIKit
@testable import Layout

@MainActor
final class LayoutNodeTests: XCTestCase, @unchecked Sendable {
    
    var testView1: UIView!
    var testView2: UIView!
    var testView3: UIView!
    var label1: UILabel!
    var label2: UILabel!
    var label3: UILabel!
    
    override func setUp() {
        super.setUp()
        // @MainActor class, so setUp() already runs on MainActor
        testView1 = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        testView1.backgroundColor = .red
        
        testView2 = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        testView2.backgroundColor = .blue
        
        testView3 = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        testView3.backgroundColor = .green
        
        label1 = UILabel()
        label1.text = "Label 1"
        
        label2 = UILabel()
        label2.text = "Label 2"
        
        label3 = UILabel()
        label3.text = "Label 3"
    }
    
    override func tearDown() {
        // @MainActor class, so tearDown() already runs on MainActor
        testView1 = nil
        testView2 = nil
        testView3 = nil
        label1 = nil
        label2 = nil
        label3 = nil
        super.tearDown()
    }
    
    // MARK: - LayoutNode Initialization Tests
    
    func testLayoutNodeInitialization() {
        let layout = testView1.layout()
        let node = LayoutNode(layout: layout)
        
        XCTAssertNotNil(node)
        XCTAssertTrue(node.isDirty)
        XCTAssertNil(node.parent)
        XCTAssertEqual(node.children.count, 0)
    }
    
    func testLayoutNodeWithVStack() {
        let vstack = VStack(spacing: 10) {
            testView1.layout().size(width: 100, height: 50)
            testView2.layout().size(width: 80, height: 40)
        }
        
        let node = LayoutNode(layout: vstack)
        XCTAssertNotNil(node)
        XCTAssertTrue(node.isDirty)
    }
    
    // MARK: - Dirty State Tests
    
    func testMarkDirty() {
        let layout = testView1.layout()
        let node = LayoutNode(layout: layout)
        
        // Initially dirty
        XCTAssertTrue(node.isDirty)
        
        // Calculate layout to mark as clean
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        _ = node.calculateLayout(in: bounds)
        
        // Should be clean after calculation
        XCTAssertFalse(node.isDirty)
        
        // Mark as dirty again
        node.markDirty()
        XCTAssertTrue(node.isDirty)
    }
    
    func testMarkDirtyPropagation() {
        let vstack = VStack(spacing: 10) {
            testView1.layout().size(width: 100, height: 50)
            testView2.layout().size(width: 80, height: 40)
        }
        
        let parentNode = LayoutNode(layout: vstack)
        parentNode.buildTree()
        
        // Calculate to mark as clean
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        _ = parentNode.calculateLayout(in: bounds)
        
        XCTAssertFalse(parentNode.isDirty)
        XCTAssertEqual(parentNode.children.count, 2)
        
        // Mark child as dirty
        if let childNode = parentNode.children.first {
            childNode.markDirty()
            // Parent should be marked dirty due to propagation
            XCTAssertTrue(parentNode.isDirty)
        }
    }
    
    func testInvalidate() {
        let vstack = VStack(spacing: 10) {
            testView1.layout().size(width: 100, height: 50)
            testView2.layout().size(width: 80, height: 40)
        }
        
        let node = LayoutNode(layout: vstack)
        node.buildTree()
        
        // Calculate to mark as clean
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        _ = node.calculateLayout(in: bounds)
        
        XCTAssertFalse(node.isDirty)
        XCTAssertEqual(node.children.count, 2)
        
        // Invalidate should mark node and all children as dirty
        node.invalidate()
        
        XCTAssertTrue(node.isDirty)
        for child in node.children {
            XCTAssertTrue(child.isDirty)
        }
    }
    
    // MARK: - Layout Calculation Tests
    
    func testCalculateLayout() {
        let layout = testView1.layout().size(width: 100, height: 50)
        let node = LayoutNode(layout: layout)
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        let result = node.calculateLayout(in: bounds)
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result.frames.count, 0)
        XCTAssertTrue(result.frames.keys.contains(testView1))
    }
    
    func testCalculateLayoutCaching() {
        let layout = testView1.layout().size(width: 100, height: 50)
        let node = LayoutNode(layout: layout)
        
        let bounds = CGRect(x: 0, y: 0, width: 400, height: 300)
        
        // First calculation
        let result1 = node.calculateLayout(in: bounds)
        XCTAssertFalse(node.isDirty)
        
        // Second calculation with same bounds should use cache
        let result2 = node.calculateLayout(in: bounds)
        XCTAssertFalse(node.isDirty)
        
        // Results should be the same
        XCTAssertEqual(result1.frames.count, result2.frames.count)
    }
    
    func testCalculateLayoutWithBoundsChange() {
        let layout = testView1.layout().size(width: 100, height: 50)
        let node = LayoutNode(layout: layout)
        
        let bounds1 = CGRect(x: 0, y: 0, width: 400, height: 300)
        _ = node.calculateLayout(in: bounds1)
        XCTAssertFalse(node.isDirty)
        
        // Change bounds should trigger recalculation
        let bounds2 = CGRect(x: 0, y: 0, width: 500, height: 400)
        _ = node.calculateLayout(in: bounds2)
        // Should recalculate even if not dirty (bounds changed)
    }
    
    // MARK: - Tree Building Tests
    
    func testBuildTreeForVStack() {
        let vstack = VStack(spacing: 10) {
            testView1.layout().size(width: 100, height: 50)
            testView2.layout().size(width: 80, height: 40)
        }
        
        let node = LayoutNode(layout: vstack)
        node.buildTree()
        
        // Should have 2 children (one for each view)
        XCTAssertEqual(node.children.count, 2)
        
        // Each child should have parent reference
        for child in node.children {
            XCTAssertTrue(child.parent === node)
        }
    }
    
    func testBuildTreeForHStack() {
        let hstack = HStack(spacing: 10) {
            testView1.layout().size(width: 100, height: 50)
            testView2.layout().size(width: 80, height: 40)
            testView3.layout().size(width: 60, height: 30)
        }
        
        let node = LayoutNode(layout: hstack)
        node.buildTree()
        
        XCTAssertEqual(node.children.count, 3)
        
        for child in node.children {
            XCTAssertTrue(child.parent === node)
        }
    }
    
    func testBuildTreeForNestedStacks() {
        let vstack = VStack(spacing: 10) {
            HStack(spacing: 5) {
                testView1.layout().size(width: 50, height: 30)
                testView2.layout().size(width: 50, height: 30)
            }
            testView3.layout().size(width: 100, height: 40)
        }
        
        let rootNode = LayoutNode(layout: vstack)
        rootNode.buildTree()
        
        // Root should have 2 children (HStack and testView3)
        XCTAssertEqual(rootNode.children.count, 2)
        
        // HStack child should have 2 children
        if let hstackNode = rootNode.children.first {
            XCTAssertEqual(hstackNode.children.count, 2)
        }
    }
    
    // MARK: - View Finding Tests
    
    func testFindNodeContainingView() {
        let vstack = VStack(spacing: 10) {
            testView1.layout().size(width: 100, height: 50)
            testView2.layout().size(width: 80, height: 40)
        }
        
        let rootNode = LayoutNode(layout: vstack)
        rootNode.buildTree()
        
        // Find node containing testView1
        let foundNode = rootNode.findNode(containing: testView1)
        XCTAssertNotNil(foundNode)
        
        // Should be one of the child nodes
        XCTAssertTrue(rootNode.children.contains { $0 === foundNode })
    }
    
    func testFindNodeContainingNestedView() {
        let vstack = VStack(spacing: 10) {
            HStack(spacing: 5) {
                testView1.layout().size(width: 50, height: 30)
                testView2.layout().size(width: 50, height: 30)
            }
            testView3.layout().size(width: 100, height: 40)
        }
        
        let rootNode = LayoutNode(layout: vstack)
        rootNode.buildTree()
        
        // Find node containing testView1 (nested in HStack)
        let foundNode = rootNode.findNode(containing: testView1)
        XCTAssertNotNil(foundNode)
        
        // Should be a child of the HStack node
        if let hstackNode = rootNode.children.first {
            XCTAssertTrue(hstackNode.children.contains { $0 === foundNode })
        }
    }
    
    func testFindNodeWithNonExistentView() {
        let vstack = VStack(spacing: 10) {
            testView1.layout().size(width: 100, height: 50)
        }
        
        let rootNode = LayoutNode(layout: vstack)
        rootNode.buildTree()
        
        // Try to find a view that doesn't exist in the tree
        let nonExistentView = UIView()
        let foundNode = rootNode.findNode(containing: nonExistentView)
        
        XCTAssertNil(foundNode)
    }
    
    // MARK: - Collect Views Tests
    
    func testCollectAllViews() {
        let vstack = VStack(spacing: 10) {
            testView1.layout().size(width: 100, height: 50)
            testView2.layout().size(width: 80, height: 40)
        }
        
        let node = LayoutNode(layout: vstack)
        node.buildTree()
        
        let allViews = node.collectAllViews()
        
        // Should collect views from root and all children
        XCTAssertGreaterThanOrEqual(allViews.count, 2)
        XCTAssertTrue(allViews.contains(testView1))
        XCTAssertTrue(allViews.contains(testView2))
    }
    
    func testCollectAllViewsNested() {
        let vstack = VStack(spacing: 10) {
            HStack(spacing: 5) {
                testView1.layout().size(width: 50, height: 30)
                testView2.layout().size(width: 50, height: 30)
            }
            testView3.layout().size(width: 100, height: 40)
        }
        
        let rootNode = LayoutNode(layout: vstack)
        rootNode.buildTree()
        
        let allViews = rootNode.collectAllViews()
        
        // Should collect all views from nested structure
        XCTAssertGreaterThanOrEqual(allViews.count, 3)
        XCTAssertTrue(allViews.contains(testView1))
        XCTAssertTrue(allViews.contains(testView2))
        XCTAssertTrue(allViews.contains(testView3))
    }
    
    // MARK: - Parent-Child Relationship Tests
    
    func testAddChild() {
        let parentLayout = testView1.layout()
        let childLayout = testView2.layout()
        
        let parentNode = LayoutNode(layout: parentLayout)
        let childNode = LayoutNode(layout: childLayout)
        
        parentNode.addChild(childNode)
        
        XCTAssertEqual(parentNode.children.count, 1)
        XCTAssertTrue(parentNode.children.first === childNode)
        XCTAssertTrue(childNode.parent === parentNode)
    }
    
    func testRemoveChild() {
        let parentLayout = testView1.layout()
        let childLayout = testView2.layout()
        
        let parentNode = LayoutNode(layout: parentLayout)
        let childNode = LayoutNode(layout: childLayout)
        
        parentNode.addChild(childNode)
        XCTAssertEqual(parentNode.children.count, 1)
        
        parentNode.removeChild(childNode)
        
        XCTAssertEqual(parentNode.children.count, 0)
        XCTAssertNil(childNode.parent)
    }
    
    func testRemoveAllChildren() {
        let parentLayout = testView1.layout()
        
        let parentNode = LayoutNode(layout: parentLayout)
        let child1 = LayoutNode(layout: testView2.layout())
        let child2 = LayoutNode(layout: testView3.layout())
        
        parentNode.addChild(child1)
        parentNode.addChild(child2)
        XCTAssertEqual(parentNode.children.count, 2)
        
        parentNode.removeAllChildren()
        
        XCTAssertEqual(parentNode.children.count, 0)
        XCTAssertNil(child1.parent)
        XCTAssertNil(child2.parent)
    }
}

