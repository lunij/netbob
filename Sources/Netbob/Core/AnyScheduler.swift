//
//  Copyright © Marc Schultz. All rights reserved.
//

import Combine
import Foundation

class AnyScheduler<S: Scheduler>: AnySchedulerBase<S.SchedulerTimeType, S.SchedulerOptions> {}

class AnySchedulerBase<Time: Strideable, Options>: Scheduler where Time.Stride: SchedulerTimeIntervalConvertible {
    typealias SchedulerTimeType = Time
    typealias SchedulerOptions = Options

    private var _now: () -> Time
    var now: Time { _now() }

    private var _minimumTolerance: () -> Time.Stride
    var minimumTolerance: Time.Stride { _minimumTolerance() }

    private var _schedule: (_ options: Options?, _ action: @escaping () -> Void) -> Void
    func schedule(options: Options?, _ action: @escaping () -> Void) {
        _schedule(options, action)
    }

    private var _scheduleAfter: (_ date: Time, _ tolerance: Time.Stride, _ options: SchedulerOptions?, _ action: @escaping () -> Void) -> Void
    func schedule(after date: Time, tolerance: Time.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        _scheduleAfter(date, tolerance, options, action)
    }

    private var _scheduleAfterCancellable: (_ date: SchedulerTimeType, _ interval: SchedulerTimeType.Stride, _ tolerance: SchedulerTimeType.Stride, _ options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable
    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        _scheduleAfterCancellable(date, interval, tolerance, options, action)
    }

    init<S: Scheduler>(scheduler: S) where S.SchedulerTimeType == Time, S.SchedulerOptions == Options {
        _now = { scheduler.now }
        _minimumTolerance = { scheduler.minimumTolerance }
        _schedule = { options, action in scheduler.schedule(options: options, action) }
        _scheduleAfter = { date, tolerance, options, action in
            scheduler.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        _scheduleAfterCancellable = { date, interval, tolerance, options, action in
            scheduler.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}

extension AnyScheduler where S: DispatchQueue {
    static var main: AnyScheduler<DispatchQueue> {
        DispatchQueue.main.asAnyScheduler()
    }

    static var global: AnyScheduler<DispatchQueue> {
        DispatchQueue.global().asAnyScheduler()
    }
}

extension Scheduler {
    func asAnyScheduler<S: Scheduler>() -> AnyScheduler<S> where S.SchedulerOptions == SchedulerOptions, S.SchedulerTimeType == SchedulerTimeType {
        .init(scheduler: self)
    }
}
