//
//  Coordinator.swift
//  Back App iOS
//
//  Created by Moritz Schaub on 09.10.22.
//  Copyright © 2022 Moritz Schaub. All rights reserved.
//

import Foundation

/// Protocol describing a [Coordinator](http://khanlou.com/2015/10/coordinators-redux/).
/// Coordinators are the objects which control the navigation flow of the application.
/// It helps to isolate and reuse view controllers and pass dependencies down the navigation hierarchy.
@MainActor
protocol Coordinator: AnyObject {
    /// Starts job of the coordinator.
    func start()

    /// Child coordinators to retain. Prevent them from getting deallocated.
    var childCoordinators: [Coordinator] { get set }

    /// navigation controller of the coordinator
    var navigationController: UINavigationController { get set }

    /// Stores coordinator to the `childCoordinators` array.
    ///
    /// - Parameter childCoordinator: Child coordinator to store.
    func add(childCoordinator: Coordinator)

    /// Remove coordinator from the `childCoordinators` array.
    ///
    /// - Parameter childCoordinator: Child coordinator to remove.
    func remove(childCoordinator: Coordinator)

    /// Stops job of the coordinator. Can be used to clear some resources. Will be automatically called when the coordinator removed.
    func stop()
}

// `Coordinator` default implementation
extension Coordinator {

    func add(childCoordinator coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }

    func remove(childCoordinator: Coordinator) {
        childCoordinator.stop()
        childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
    }
}
