<?php
/**
 * LuMo Guide — Database Schema Exporter
 *
 * 使用方式:
 * 1. 将此文件上传到服务器 public/ 目录（如 public/dump-schema.php）
 * 2. 浏览器访问: https://your-domain.com/dump-schema.php?token=lumo2025
 * 3. 下载生成的 schema_dump.sql 文件
 *
 * 安全: 需要 token 参数验证，用完后请立即删除此文件
 */

// ── 安全验证 ──
$validToken = 'lumo2025';
if (($_GET['token'] ?? '') !== $validToken) {
    http_response_code(403);
    die('Forbidden — token required');
}

// ── 数据库连接 (从 .env 读取) ──
$envFile = __DIR__ . '/../.env';
$dbConfig = [];
if (file_exists($envFile)) {
    foreach (file($envFile) as $line) {
        $line = trim($line);
        if (empty($line) || $line[0] === '#') continue;
        if (str_starts_with($line, 'DB_')) {
            [$key, $val] = explode('=', $line, 2);
            $dbConfig[substr($key, 3)] = trim($val);
        }
    }
}

$host       = $dbConfig['HOST'] ?? '127.0.0.1';
$port       = $dbConfig['PORT'] ?? '3306';
$database   = $dbConfig['DATABASE'] ?? 'lumo_guide';
$username   = $dbConfig['USERNAME'] ?? 'root';
$password   = $dbConfig['PASSWORD'] ?? '';

try {
    $pdo = new PDO(
        "mysql:host=$host;port=$port;dbname=$database;charset=utf8mb4",
        $username,
        $password,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
} catch (PDOException $e) {
    http_response_code(500);
    die('Database connection failed: ' . $e->getMessage());
}

// ── 输出模式 ──
$output = ($_GET['output'] ?? '') === 'sql' ? 'sql' : 'browser';

if ($output === 'sql') {
    header('Content-Type: application/sql');
    header('Content-Disposition: attachment; filename="lumo_guide_schema_' . date('Ymd_His') . '.sql"');
} else {
    header('Content-Type: text/html; charset=utf-8');
    echo '<!DOCTYPE html><html lang="zh"><head><meta charset="utf-8"><title>DB Schema</title>';
    echo '<style>body{font:14px monospace;background:#1a1a2e;color:#e0e0e0;padding:20px;max-width:1200px;margin:auto}
h1{color:#666FFF}h2{color:#F59E0B;margin-top:30px;border-bottom:1px solid #333;padding-bottom:5px}
table{border-collapse:collapse;width:100%;margin:10px 0;font-size:12px}
th{background:#16213e;color:#aaf;padding:6px 8px;text-align:left}
td{padding:4px 8px;border-bottom:1px solid #333}
.type{color:#4ecdc4}.null{color:#ff6b6b}.default{color:#aaa}.comment{color:#f0ad4e}
.sql{background:#111;color:#0f0;padding:10px;border-radius:4px;margin:10px 0;white-space:pre-wrap;overflow-x:auto}
a{color:#666FFF}</style></head><body>';
    echo '<h1>LuMo Guide — Database Schema</h1>';
    echo '<p>Database: <strong>' . htmlspecialchars($database) . '</strong> | Tables: <strong id="count"></strong></p>';
    echo '<p><a href="?token=' . $validToken . '&output=sql">📥 Download as SQL</a></p>';
}

// ── 获取所有表 ──
$tables = $pdo->query("SHOW TABLES")->fetchAll(PDO::FETCH_COLUMN);

if ($output === 'browser') {
    echo '<script>document.getElementById("count").textContent=' . count($tables) . ';</script>';
}

$fullDump = "-- LuMo Guide Database Full Schema\n";
$fullDump .= "-- Generated: " . date('Y-m-d H:i:s') . "\n";
$fullDump .= "-- Database: $database\n";
$fullDump .= "-- Tables: " . count($tables) . "\n\n";
$fullDump .= "CREATE DATABASE IF NOT EXISTS `$database`\n";
$fullDump .= "  DEFAULT CHARACTER SET utf8mb4\n";
$fullDump .= "  COLLATE utf8mb4_unicode_ci;\n\n";
$fullDump .= "USE `$database`;\n\n";

foreach ($tables as $table) {
    if ($output === 'sql') {
        // SQL 格式: 输出 CREATE TABLE 语句
        $create = $pdo->query("SHOW CREATE TABLE `$table`")->fetch(PDO::FETCH_ASSOC);
        $fullDump .= "-- ============================================================\n";
        $fullDump .= "-- Table: $table\n";
        $fullDump .= "-- ============================================================\n";
        $fullDump .= $create['Create Table'] . ";\n\n";
    } else {
        // 浏览器格式: 显示表结构表格
        echo "<h2>$table</h2>";

        $columns = $pdo->query("SHOW FULL COLUMNS FROM `$table`")->fetchAll(PDO::FETCH_ASSOC);
        echo '<table><tr>
            <th>Field</th><th>Type</th><th>Null</th><th>Key</th><th>Default</th><th>Extra</th><th>Comment</th>
        </tr>';

        foreach ($columns as $col) {
            $null = $col['Null'] === 'YES' ? '<span class="null">YES</span>' : 'NO';
            $default = $col['Default'] !== null ? '<span class="default">' . htmlspecialchars((string)$col['Default']) . '</span>' : '<span class="null">NULL</span>';
            $comment = $col['Comment'] ? '<span class="comment">' . htmlspecialchars($col['Comment']) . '</span>' : '';
            echo '<tr>';
            echo '<td><strong>' . htmlspecialchars($col['Field']) . '</strong></td>';
            echo '<td class="type">' . htmlspecialchars($col['Type']) . '</td>';
            echo '<td>' . $null . '</td>';
            echo '<td>' . htmlspecialchars($col['Key'] ?: '') . '</td>';
            echo '<td>' . $default . '</td>';
            echo '<td>' . htmlspecialchars($col['Extra'] ?: '') . '</td>';
            echo '<td>' . $comment . '</td>';
            echo '</tr>';
        }
        echo '</table>';

        // 行数统计
        $count = $pdo->query("SELECT COUNT(*) FROM `$table`")->fetchColumn();
        echo '<p style="color:#888;font-size:11px">Rows: ' . number_format($count) . '</p>';
    }
}

if ($output === 'sql') {
    // 追加索引信息
    $fullDump .= "-- ============================================================\n";
    $fullDump .= "-- Indexes Summary\n";
    $fullDump .= "-- ============================================================\n";
    foreach ($tables as $table) {
        $indexes = $pdo->query("SHOW INDEX FROM `$table`")->fetchAll(PDO::FETCH_ASSOC);
        $seen = [];
        foreach ($indexes as $idx) {
            if (isset($seen[$idx['Key_name']])) continue;
            $seen[$idx['Key_name']] = true;
            if ($idx['Key_name'] === 'PRIMARY') continue; // already in CREATE TABLE
            $fullDump .= "-- $table: {$idx['Key_name']} (unique: {$idx['Non_unique']})\n";
        }
    }

    echo $fullDump;
} else {
    echo '<hr style="margin-top:40px;border-color:#333">';
    echo '<p style="color:#666">Generated at ' . date('Y-m-d H:i:s') . ' | <a href="?token=' . $validToken . '&output=sql">Download SQL</a></p>';
    echo '</body></html>';
}
