//
//  Untitled.swift
//  WidgetApp
//
//  Created by Štěpán Pazderka on 13.08.2024.
//

import CloudKitSyncMonitor
import SwiftUI

struct SyncStatusView: View {
	@available(iOS 15.0, *)
	@ObservedObject var syncMonitor = SyncMonitor.shared
	
	var body: some View {
		// Show sync status if there's a sync error
		if #available(iOS 15.0, *), syncMonitor.syncStateSummary.isBroken {
			Image(systemName: syncMonitor.syncStateSummary.symbolName)
				.foregroundColor(syncMonitor.syncStateSummary.symbolColor)
		}
	}
}
