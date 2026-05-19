<?php

define('SUPABASE_URL', 'https://ukmfbinwpqfribeladhk.supabase.co');
define('SUPABASE_KEY', 'sb_publishable_gEyPG1zyWhM6lGAsTO3mfw_whu_WU5_');

function getSupabaseHeaders() {
    return [
        'Content-Type: application/json',
        'apikey: ' . SUPABASE_KEY,
        'Authorization: Bearer ' . SUPABASE_KEY
    ];
}
?>