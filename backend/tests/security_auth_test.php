<?php
// backend/tests/security_auth_test.php
// Automated Test Suite for Picky X Backend Security & Authentication

$testCount = 0;
$passCount = 0;

function runTest(string $description, callable $fn) {
    global $testCount, $passCount;
    $testCount++;
    try {
        $result = $fn();
        if ($result === true) {
            echo "  [PASS] $description\n";
            $passCount++;
        } else {
            echo "  [FAIL] $description: $result\n";
        }
    } catch (Throwable $e) {
        echo "  [FAIL] $description: Exception - " . $e->getMessage() . "\n";
    }
}

echo "====================================================\n";
echo "🛡️  Running Picky X Security & Auth Verification Suite\n";
echo "====================================================\n";

// Test 1: Direct request to header.php redirects when unauthenticated
runTest("Header.php directly blocks unauthenticated access with HTTP 302 redirect", function() {
    $url = 'http://localhost/pickyx_api/admin/header.php';
    $ctx = stream_context_create([
        'http' => [
            'follow_location' => 0,
            'ignore_errors' => true,
            'timeout' => 5
        ]
    ]);
    $headers = @get_headers($url, true, $ctx);
    if (!$headers) {
        return "Could not connect to local server at $url";
    }

    $statusLine = is_array($headers[0]) ? $headers[0][0] : $headers[0];
    $location = $headers['Location'] ?? ($headers['location'] ?? '');
    if (is_array($location)) $location = end($location);

    if (str_contains($statusLine, '302') && str_contains($location, 'index.php')) {
        return true;
    }
    return "Expected HTTP 302 redirect to index.php, got Status: $statusLine, Location: $location";
});

// Test 2: Unauthenticated HTTP request to admin dashboard receives redirect to index.php
runTest("Admin Dashboard blocks unauthenticated HTTP access with HTTP 302 redirect", function() {
    $url = 'http://localhost/pickyx_api/admin/dashboard.php';
    $ctx = stream_context_create([
        'http' => [
            'follow_location' => 0,
            'ignore_errors' => true,
            'timeout' => 5
        ]
    ]);
    $headers = @get_headers($url, true, $ctx);
    if (!$headers) {
        return "Could not connect to local server at $url";
    }

    $statusLine = is_array($headers[0]) ? $headers[0][0] : $headers[0];
    $location = $headers['Location'] ?? ($headers['location'] ?? '');
    if (is_array($location)) $location = end($location);

    if (str_contains($statusLine, '302') && str_contains($location, 'index.php')) {
        return true;
    }
    return "Expected HTTP 302 redirect to index.php, got Status: $statusLine, Location: $location";
});

// Test 3: Unauthenticated HTTP request to players.php receives redirect to index.php
runTest("Player Management blocks unauthenticated HTTP access with HTTP 302 redirect", function() {
    $url = 'http://localhost/pickyx_api/admin/players.php';
    $ctx = stream_context_create([
        'http' => [
            'follow_location' => 0,
            'ignore_errors' => true,
            'timeout' => 5
        ]
    ]);
    $headers = @get_headers($url, true, $ctx);
    if (!$headers) {
        return "Could not connect to local server at $url";
    }

    $statusLine = is_array($headers[0]) ? $headers[0][0] : $headers[0];
    $location = $headers['Location'] ?? ($headers['location'] ?? '');
    if (is_array($location)) $location = end($location);

    if (str_contains($statusLine, '302') && str_contains($location, 'index.php')) {
        return true;
    }
    return "Expected HTTP 302 redirect to index.php, got Status: $statusLine, Location: $location";
});

// Test 4: State mutation on players.php without valid session/CSRF token is rejected
runTest("Player action rejects unauthenticated POST mutation", function() {
    $url = 'http://localhost/pickyx_api/admin/players.php';
    $postData = http_build_query([
        'action' => 'grant_resources',
        'user_id' => '1',
        'add_coins' => '500',
        'add_gems' => '25'
    ]);

    $opts = [
        'http' => [
            'method' => 'POST',
            'header' => "Content-Type: application/x-www-form-urlencoded\r\n",
            'content' => $postData,
            'follow_location' => 0,
            'ignore_errors' => true,
            'timeout' => 5
        ]
    ];
    $ctx = stream_context_create($opts);
    $response = @file_get_contents($url, false, $ctx);
    $responseHeaders = $http_response_header ?? [];

    $statusLine = $responseHeaders[0] ?? '';
    if (str_contains($statusLine, '302') || str_contains($statusLine, '403')) {
        return true;
    }
    return "Expected HTTP 302 or 403, got: $statusLine";
});

// Test 5: Setup script blocks public web execution without setup_token
runTest("Database setup script blocks unauthorized web request with HTTP 403", function() {
    $url = 'http://localhost/pickyx_api/setup_database.php';
    $opts = [
        'http' => [
            'follow_location' => 0,
            'ignore_errors' => true,
            'timeout' => 5
        ]
    ];
    $ctx = stream_context_create($opts);
    $response = @file_get_contents($url, false, $ctx);
    $responseHeaders = $http_response_header ?? [];

    $statusLine = $responseHeaders[0] ?? '';
    if (str_contains($statusLine, '403')) {
        return true;
    }
    return "Expected HTTP 403 Forbidden, got: $statusLine";
});

// Test 6: constants.php loads from .env successfully
runTest("Constants loads environment configuration securely", function() {
    require_once dirname(__DIR__) . '/config/constants.php';
    if (defined('DB_HOST') && defined('DB_NAME') && defined('API_SECRET_KEY')) {
        return true;
    }
    return "Constants DB_HOST, DB_NAME, or API_SECRET_KEY not defined.";
});

// Test 7: Verify login validation with incorrect credentials fails
runTest("Login form rejects invalid credentials", function() {
    $url = 'http://localhost/pickyx_api/admin/index.php';
    $postData = http_build_query([
        'username' => 'admin',
        'password' => 'wrong_password_attempt'
    ]);

    $opts = [
        'http' => [
            'method' => 'POST',
            'header' => "Content-Type: application/x-www-form-urlencoded\r\n",
            'content' => $postData,
            'follow_location' => 0,
            'ignore_errors' => true,
            'timeout' => 5
        ]
    ];
    $ctx = stream_context_create($opts);
    $response = @file_get_contents($url, false, $ctx);

    if ($response && str_contains($response, 'Invalid administrator credentials')) {
        return true;
    }
    return "Expected 'Invalid administrator credentials' message in response";
});

// Test 8: Verify legitimate administrator login succeeds and redirects to dashboard
runTest("Administrator login with valid credentials succeeds and issues session", function() {
    $url = 'http://localhost/pickyx_api/admin/index.php';
    $adminUser = getenv('ADMIN_DEFAULT_USER') ?: ($_ENV['ADMIN_DEFAULT_USER'] ?? 'admin');
    $adminPass = getenv('ADMIN_DEFAULT_PASS') ?: ($_ENV['ADMIN_DEFAULT_PASS'] ?? 'pickyx2026admin');

    $postData = http_build_query([
        'username' => $adminUser,
        'password' => $adminPass
    ]);

    $opts = [
        'http' => [
            'method' => 'POST',
            'header' => "Content-Type: application/x-www-form-urlencoded\r\n",
            'content' => $postData,
            'follow_location' => 0,
            'ignore_errors' => true,
            'timeout' => 5
        ]
    ];
    $ctx = stream_context_create($opts);
    $response = @file_get_contents($url, false, $ctx);
    $responseHeaders = $http_response_header ?? [];

    $statusLine = $responseHeaders[0] ?? '';
    $location = '';
    $hasCookie = false;
    foreach ($responseHeaders as $h) {
        if (stripos($h, 'Location:') === 0) {
            $location = trim(substr($h, 9));
        }
        if (stripos($h, 'Set-Cookie:') === 0 && stripos($h, 'PHPSESSID') !== false) {
            $hasCookie = true;
        }
    }

    if (str_contains($statusLine, '302') && str_contains($location, 'dashboard.php') && $hasCookie) {
        return true;
    }
    return "Expected 302 redirect to dashboard.php with PHPSESSID cookie. Status: $statusLine, Location: $location, Cookie: " . ($hasCookie ? 'YES' : 'NO');
});

// Test 9: Verify .env file is strictly blocked from HTTP downloads
runTest("HTTP request to .env is forbidden by server access controls", function() {
    $url = 'http://localhost/pickyx_api/config/.env';
    $opts = [
        'http' => [
            'follow_location' => 0,
            'ignore_errors' => true,
            'timeout' => 5
        ]
    ];
    $ctx = stream_context_create($opts);
    $response = @file_get_contents($url, false, $ctx);
    $responseHeaders = $http_response_header ?? [];

    $statusLine = $responseHeaders[0] ?? '';
    if (str_contains($statusLine, '403')) {
        return true;
    }
    return "Expected HTTP 403 Forbidden when requesting .env, got: $statusLine";
});

// Test 10: Verify setup.lock file is strictly blocked from HTTP downloads
runTest("HTTP request to setup.lock is forbidden by server access controls", function() {
    $url = 'http://localhost/pickyx_api/setup.lock';
    $opts = [
        'http' => [
            'follow_location' => 0,
            'ignore_errors' => true,
            'timeout' => 5
        ]
    ];
    $ctx = stream_context_create($opts);
    $response = @file_get_contents($url, false, $ctx);
    $responseHeaders = $http_response_header ?? [];

    $statusLine = $responseHeaders[0] ?? '';
    if (str_contains($statusLine, '403')) {
        return true;
    }
    return "Expected HTTP 403 Forbidden when requesting setup.lock, got: $statusLine";
});

echo "----------------------------------------------------\n";
echo "Results: $passCount / $testCount tests passed.\n";
echo "====================================================\n";

if ($passCount === $testCount) {
    exit(0);
} else {
    exit(1);
}
