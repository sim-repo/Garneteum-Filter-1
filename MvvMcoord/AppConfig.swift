import UIKit



// MARK: -TIMEOUT POLICIES:
var defDelayBeforeWaitShownInSec = 2

var netRequestLimitRerunTask = 2 // max limit to rerun net task

var defDelayBeforeRerunTask = 1

var waitForFiltersTimeoutInSec: Double = 12
// waitForSubfiltersTimeoutInSec <= waitForFiltersTimeoutInSec
var waitForSubfiltersTimeoutInSec: Double  = 10
// waitForSubfiltersApplySetInSec <= waitForSubfiltersTimeoutInSec
var waitForSubfiltersApplySetInSec: Double  = 10

var waitForStartPrefetchInSec: Double = 10

var netErrorLimitBeforeCleanDB = 2 // max count of net error



// MARK: -PREFETCH POLICIES:

let imgBatchLoad = 50
let imgSleepBetweenRequestsInMS = 10
let imgStartLoadWhenScrollTo = imgBatchLoad * 50 / 100 // in percents
