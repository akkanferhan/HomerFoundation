import Foundation
import Testing
@testable import HomerFoundation

@Suite("HTTPRetryPolicy")
struct HTTPRetryPolicyTests {

    // MARK: - shouldRetry

    @Test("retries 429/408/503 within budget")
    func retriesDefaultStatusesWithinBudget() {
        let policy = HTTPRetryPolicy(maxAttempts: 3)
        for status in [408, 429, 503] {
            #expect(policy.shouldRetry(statusCode: status, attempt: 0))
            #expect(policy.shouldRetry(statusCode: status, attempt: 1))
            #expect(!policy.shouldRetry(statusCode: status, attempt: 2),
                    "Last attempt must not retry further (status \(status))")
        }
    }

    @Test("does not retry non-retryable statuses")
    func skipsNonRetryableStatuses() {
        let policy = HTTPRetryPolicy()
        for status in [200, 301, 400, 401, 404, 500, 502, 504] {
            #expect(!policy.shouldRetry(statusCode: status, attempt: 0))
        }
    }

    @Test("custom retryableStatuses overrides defaults")
    func customRetryableStatusSet() {
        let policy = HTTPRetryPolicy(retryableStatuses: [502])
        #expect(policy.shouldRetry(statusCode: 502, attempt: 0))
        #expect(!policy.shouldRetry(statusCode: 429, attempt: 0))
    }

    @Test("maxAttempts clamps to at least 1")
    func clampsMaxAttemptsLowerBound() {
        let policy = HTTPRetryPolicy(maxAttempts: 0)
        #expect(policy.maxAttempts == 1)
        #expect(!policy.shouldRetry(statusCode: 429, attempt: 0))
    }

    // MARK: - delay (without Retry-After)

    @Test("backoff grows exponentially when jitter is disabled")
    func deterministicExponentialBackoff() {
        let policy = HTTPRetryPolicy(
            baseDelay: 0.5,
            minDelay: 0,
            maxDelay: 100,
            jitterFactor: 0
        )
        #expect(policy.delay(forAttempt: 0) == 0.5)
        #expect(policy.delay(forAttempt: 1) == 1.0)
        #expect(policy.delay(forAttempt: 2) == 2.0)
        #expect(policy.delay(forAttempt: 3) == 4.0)
    }

    @Test("delay is clamped by minDelay floor")
    func clampsToMinDelay() {
        let policy = HTTPRetryPolicy(
            baseDelay: 0.1,
            minDelay: 0.5,
            maxDelay: 100,
            jitterFactor: 0
        )
        #expect(policy.delay(forAttempt: 0) == 0.5)
    }

    @Test("delay is clamped by maxDelay ceiling")
    func clampsToMaxDelay() {
        let policy = HTTPRetryPolicy(
            baseDelay: 1,
            minDelay: 0,
            maxDelay: 3,
            jitterFactor: 0
        )
        #expect(policy.delay(forAttempt: 5) == 3)
    }

    @Test("jitter keeps delay within ±factor band")
    func jitterStaysWithinBand() {
        let policy = HTTPRetryPolicy(
            baseDelay: 1,
            minDelay: 0,
            maxDelay: 100,
            jitterFactor: 0.3
        )
        for _ in 0..<200 {
            let delay = policy.delay(forAttempt: 0)
            #expect(delay >= 0.7)
            #expect(delay <= 1.3)
        }
    }

    @Test("jitterFactor outside [0,1] is clamped")
    func clampsJitterFactor() {
        #expect(HTTPRetryPolicy(jitterFactor: -1).jitterFactor == 0)
        #expect(HTTPRetryPolicy(jitterFactor: 5).jitterFactor == 1)
    }

    // MARK: - delay (Retry-After: seconds)

    @Test("Retry-After delay-seconds value wins over backoff")
    func retryAfterSecondsWins() {
        let policy = HTTPRetryPolicy(
            baseDelay: 1,
            minDelay: 0,
            maxDelay: 100,
            jitterFactor: 0
        )
        let delay = policy.delay(forAttempt: 5, retryAfterHeader: "7")
        #expect(delay == 7)
    }

    @Test("Retry-After whitespace is tolerated")
    func retryAfterTolerantToWhitespace() {
        let policy = HTTPRetryPolicy(jitterFactor: 0)
        #expect(policy.delay(forAttempt: 0, retryAfterHeader: "  4  ") == 4)
    }

    @Test("Retry-After value is clamped by minDelay")
    func retryAfterClampedToMin() {
        let policy = HTTPRetryPolicy(
            baseDelay: 1,
            minDelay: 0.5,
            maxDelay: 100,
            jitterFactor: 0
        )
        #expect(policy.delay(forAttempt: 0, retryAfterHeader: "0") == 0.5)
    }

    @Test("Retry-After value is clamped by maxDelay")
    func retryAfterClampedToMax() {
        let policy = HTTPRetryPolicy(
            baseDelay: 1,
            minDelay: 0,
            maxDelay: 5,
            jitterFactor: 0
        )
        #expect(policy.delay(forAttempt: 0, retryAfterHeader: "300") == 5)
    }

    @Test("Retry-After unparseable garbage falls back to backoff")
    func retryAfterFallsBackOnGarbage() {
        let policy = HTTPRetryPolicy(
            baseDelay: 1,
            minDelay: 0,
            maxDelay: 100,
            jitterFactor: 0
        )
        let delay = policy.delay(forAttempt: 1, retryAfterHeader: "not-a-number")
        #expect(delay == 2)
    }

    // MARK: - delay (Retry-After: HTTP-date)

    @Test("Retry-After HTTP-date in the future returns offset")
    func retryAfterHTTPDateFuture() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let target = now.addingTimeInterval(6)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        let header = formatter.string(from: target)

        let policy = HTTPRetryPolicy(
            baseDelay: 1,
            minDelay: 0,
            maxDelay: 100,
            jitterFactor: 0
        )
        let delay = policy.delay(forAttempt: 0, retryAfterHeader: header, now: now)
        #expect(abs(delay - 6) < 0.001)
    }

    @Test("Retry-After HTTP-date in the past clamps to minDelay")
    func retryAfterHTTPDatePast() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let target = now.addingTimeInterval(-30)
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        let header = formatter.string(from: target)

        let policy = HTTPRetryPolicy(
            baseDelay: 1,
            minDelay: 0.5,
            maxDelay: 100,
            jitterFactor: 0
        )
        let delay = policy.delay(forAttempt: 0, retryAfterHeader: header, now: now)
        #expect(delay == 0.5)
    }

    // MARK: - parseRetryAfter (static)

    @Test("parseRetryAfter recognises seconds and HTTP-date")
    func parseRetryAfterRecognisesBothForms() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        #expect(HTTPRetryPolicy.parseRetryAfter("3") == 3)
        #expect(HTTPRetryPolicy.parseRetryAfter("0") == 0)
        #expect(HTTPRetryPolicy.parseRetryAfter("not-valid", now: now) == nil)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        let header = formatter.string(from: now.addingTimeInterval(10))
        let parsed = HTTPRetryPolicy.parseRetryAfter(header, now: now)
        #expect(parsed.map { abs($0 - 10) < 0.001 } == true)
    }
}
