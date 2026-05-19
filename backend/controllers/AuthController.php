<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once __DIR__ . '/../config/database.php';

class AuthController {

    public function login($data) {
        $dui = $data['dui'] ?? '';
        $contrasena = $data['contrasena'] ?? '';

        if (empty($dui) || empty($contrasena)) {
            return [
                'success' => false,
                'message' => 'DUI y contraseña son requeridos'
            ];
        }

        $url = SUPABASE_URL . '/rest/v1/empleados?dui=eq.' . $dui . '&estado=eq.true&select=*';
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, getSupabaseHeaders());
        $response = curl_exec($ch);
        curl_close($ch);

        $empleados = json_decode($response, true);

        if (empty($empleados)) {
            return [
                'success' => false,
                'message' => 'DUI o contraseña incorrectos'
            ];
        }

        $empleado = $empleados[0];

        if ($empleado['contrasena'] !== $contrasena) {
            return [
                'success' => false,
                'message' => 'DUI o contraseña incorrectos'
            ];
        }

        return [
            'success' => true,
            'message' => 'Login exitoso',
            'data' => [
                'id' => $empleado['id'],
                'nombre' => $empleado['nombre'],
                'cargo' => $empleado['cargo'],
                'dui' => $empleado['dui']
            ]
        ];
    }
}
?>