<?php
// backend/config/constants.php

// Application Constants
define('APP_NAME', 'Picky X API');
define('APP_VERSION', '2.0.0');

// Database Configuration (Default XAMPP)
define('DB_HOST', '127.0.0.1');
define('DB_PORT', '3306');
define('DB_NAME', 'pickyx_db');
define('DB_USER', 'root');
define('DB_PASS', '');

// Game Defaults
define('MAX_LIVES', 5);
define('LIFE_REGEN_MINUTES', 20);
define('STARTING_COINS', 100);
define('STARTING_GEMS', 10);
define('STARTING_PEEK', 2);
define('STARTING_FREEZE', 2);
define('STARTING_WAND', 2);
define('STARTING_SHUFFLE', 2);

// Security Secret
define('API_SECRET_KEY', 'picky_x_super_secret_jwt_key_2026_mesh');
