//
//  PlatformMetricsTests.swift
//  GameNetTests
//

@testable import GameNet
import XCTest

final class PlatformMetricsTests: XCTestCase {
    func testDashboardLayout_PhonePortrait_IsCompact() {
        XCTAssertEqual(
            PlatformMetrics.dashboardLayoutStyle(width: 390, isPhone: true, isLandscape: false),
            .compact
        )
    }

    func testDashboardLayout_PhoneLandscape_IsRegular() {
        XCTAssertEqual(
            PlatformMetrics.dashboardLayoutStyle(width: 844, isPhone: true, isLandscape: true),
            .regular
        )
    }

    func testDashboardLayout_IPad_IsRegular() {
        XCTAssertEqual(
            PlatformMetrics.dashboardLayoutStyle(width: 1024, isPhone: false, isLandscape: false),
            .regular
        )
    }

    func testDashboardPairedCards_NarrowWindow_IsStacked() {
        XCTAssertFalse(PlatformMetrics.dashboardUsesPairedCards(width: 640))
        XCTAssertFalse(PlatformMetrics.dashboardUsesPairedCards(width: 844))
    }

    func testDashboardPairedCards_WideWindow_IsPaired() {
        XCTAssertTrue(PlatformMetrics.dashboardUsesPairedCards(width: 900))
        XCTAssertTrue(PlatformMetrics.dashboardUsesPairedCards(width: 1100))
    }

    func testDashboardContentMaxWidth_4K_IsCapped() {
        XCTAssertEqual(PlatformMetrics.dashboardContentMaxWidth(for: 3000), 1440)
    }

    func testDashboardContentMaxWidth_PhonePortrait_UsesFullWidth() {
        XCTAssertEqual(PlatformMetrics.dashboardContentMaxWidth(for: 390), 390)
    }

    func testAnnualChartVisibleDays_IncreasesWithWidth() {
        XCTAssertEqual(PlatformMetrics.annualChartVisibleDays(for: 390), 15)
        XCTAssertGreaterThan(PlatformMetrics.annualChartVisibleDays(for: 1600), 15)
    }

    func testListCardColumns_Wide_HasTwoColumns() {
        XCTAssertEqual(PlatformMetrics.listCardColumns(for: 900).count, 2)
        XCTAssertEqual(PlatformMetrics.listCardColumns(for: 390).count, 1)
    }

    func testGamesByPlatformColumns_ScalesWithWidth() {
        XCTAssertEqual(PlatformMetrics.gamesByPlatformColumns(for: 390).count, 1)
        XCTAssertEqual(PlatformMetrics.gamesByPlatformColumns(for: 900).count, 2)
        XCTAssertEqual(PlatformMetrics.gamesByPlatformColumns(for: 1200).count, 3)
    }

    func testUsesWideDetailLayout_PhonePortrait_IsFalse() {
        XCTAssertFalse(PlatformMetrics.usesWideDetailLayout(width: 390, isLandscape: false))
    }

    func testUsesWideDetailLayout_PhoneLandscape_IsTrue() {
        XCTAssertTrue(PlatformMetrics.usesWideDetailLayout(width: 844, isLandscape: true))
    }
}
