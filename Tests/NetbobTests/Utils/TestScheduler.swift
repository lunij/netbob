//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import Foundation
@testable import Netbob

class TestScheduler: Scheduler {
    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    typealias SchedulerOptions = DispatchQueue.SchedulerOptions

    init() {}

    var now: SchedulerTimeType { .init(.now()) }

    var minimumTolerance: SchedulerTimeType.Stride {
        .zero
    }

    func schedule(
        options _: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        action()
    }

    func schedule(
        after _: SchedulerTimeType,
        tolerance _: SchedulerTimeType.Stride,
        options _: SchedulerOptions?,
        _ action: @escaping () -> Void
    ) {
        action()
    }

    func schedule(
        after _: SchedulerTimeType,
        interval _: SchedulerTimeType.Stride,
        tolerance _: SchedulerTimeType.Stride,
        options _: SchedulerOptions?,
        _: @escaping () -> Void
    ) -> Cancellable {
        AnyCancellable {}
    }
}

extension AnyScheduler where S: DispatchQueue {
    static var test: AnyScheduler<DispatchQueue> {
        TestScheduler().asAnyScheduler()
    }
}
