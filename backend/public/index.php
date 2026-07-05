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
    $targetBase = 'https://api.lumoguide.com';
    $targetUrl  = $targetBase . $requestUri;

    $ch = curl_init($targetUrl);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER    => true,
        CURLOPT_HEADER            => true,
        CURLOPT_TIMEOUT           => 60,
        CURLOPT_CONNECTTIMEOUT    => 10,
        CURLOPT_FOLLOWLOCATION    => true,
        CURLOPT_CUSTOMREQUEST     => $_SERVER['REQUEST_METHOD'] ?? 'GET',
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
    $method = strtoupper($_SERVER['REQUEST_METHOD'] ?? 'GET');
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
