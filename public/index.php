<?php

use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

/*
|--------------------------------------------------------------------------
| API Proxy for Local Dev
|--------------------------------------------------------------------------
|
| When running locally without swoole_loader, API requests are proxied
| to the production server so the frontend SPA can talk to a working API
| without CORS issues.
|
*/

$requestUri = $_SERVER['REQUEST_URI'] ?? '/';
$isApiRequest = str_starts_with($requestUri, '/api/');

if ($isApiRequest && file_exists(__DIR__ . '/../.env')) {
    $method = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');

    // ── Cache layer for GET requests (avoid TLS handshake per request) ──
    $cacheDir = __DIR__ . '/../storage/cache/api-proxy';
    $cacheHit  = false;
    if ($method === 'GET') {
        $authHash  = substr(md5($_SERVER['HTTP_AUTHORIZATION'] ?? ''), 0, 10);
        $cacheKey  = md5($requestUri . '|' . $authHash);
        $cacheFile = $cacheDir . '/' . $cacheKey . '.cache';

        // Config-dependent TTL: static data longer, user data shorter
        $cacheTTL = 120; // default 2 min
        if (str_contains($requestUri, '/common/config'))          $cacheTTL = 1800; // 30 min
        elseif (str_contains($requestUri, '/common/getContinents')) $cacheTTL = 600; // 10 min
        elseif (str_contains($requestUri, '/city/lists'))          $cacheTTL = 300; // 5 min
        elseif (str_contains($requestUri, '/user/'))               $cacheTTL = 30;  // 30 sec

        if (! is_dir($cacheDir)) mkdir($cacheDir, 0755, true);

        if (file_exists($cacheFile) && (time() - filemtime($cacheFile)) < $cacheTTL) {
            $cached = file_get_contents($cacheFile);
            $sep    = strpos($cached, "\n--CACHE-SPLIT--\n");
            if ($sep !== false) {
                $rawHeaders = substr($cached, 0, $sep);
                $body       = substr($cached, $sep + 17); // "\n--CACHE-SPLIT--\n" = 17 bytes
                $httpCode   = 200; // cached responses are only stored for 200
                $cacheHit   = true;
            }
        }
    }

    if (! $cacheHit) {
        $targetBase = 'https://api.lumoguide.com';
        $targetUrl  = $targetBase . $requestUri;

        $ch = curl_init($targetUrl);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER    => true,
            CURLOPT_HEADER            => true,
            CURLOPT_TIMEOUT           => 60,
            CURLOPT_CONNECTTIMEOUT    => 10,
            CURLOPT_FOLLOWLOCATION    => true,
            CURLOPT_CUSTOMREQUEST     => $method,
            CURLOPT_HTTPHEADER        => [
                'Accept: application/json',
                'Content-Type: application/json',
            ],
        ]);

        // Forward auth token so JWT-protected routes work
        if (! empty($_SERVER['HTTP_AUTHORIZATION'])) {
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                'Accept: application/json',
                'Content-Type: application/json',
                'Authorization: ' . $_SERVER['HTTP_AUTHORIZATION'],
            ]);
        }

        // Forward POST/PUT/PATCH body
        if (in_array($method, ['POST', 'PUT', 'PATCH'], true)) {
            $body = file_get_contents('php://input');
            curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
        }

        $response   = curl_exec($ch);
        $httpCode   = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $headerSize = curl_getinfo($ch, CURLINFO_HEADER_SIZE);
        $error      = curl_error($ch);
        curl_close($ch);

        if ($error) {
            http_response_code(502);
            header('Content-Type: application/json');
            echo json_encode([
                'code'    => 502,
                'message' => 'API proxy error: ' . $error,
                'data'    => [],
            ]);
            exit;
        }

        // Split headers from body
        $rawHeaders = substr($response, 0, $headerSize);
        $body       = substr($response, $headerSize);

        // Cache successful GET responses
        if ($method === 'GET' && $httpCode === 200) {
            @file_put_contents($cacheFile, $rawHeaders . "\n--CACHE-SPLIT--\n" . $body);
        }
    }

    // Forward response headers (skip transfer-encoding / connection)
    foreach (explode("\r\n", $rawHeaders) as $headerLine) {
        $headerLine = trim($headerLine);
        if ($headerLine === '' || str_starts_with($headerLine, 'HTTP/')) {
            continue;
        }
        if (stripos($headerLine, 'Transfer-Encoding:') !== false) continue;
        if (stripos($headerLine, 'Connection:') !== false) continue;
        if (stripos($headerLine, 'Content-Encoding:') !== false) continue;
        header($headerLine);
    }

    header('X-Proxy-Cache: ' . ($cacheHit ? 'HIT' : 'MISS'));
    http_response_code($httpCode);
    echo $body;
    exit;
}

// ──────────────────────────────────────────────
// Below: standard Laravel bootstrap (unchanged)
// ──────────────────────────────────────────────

if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

require __DIR__.'/../vendor/autoload.php';

$app = require_once __DIR__.'/../bootstrap/app.php';

$kernel = $app->make(Kernel::class);

$response = $kernel->handle(
    $request = Request::capture()
)->send();

$kernel->terminate($request, $response);
