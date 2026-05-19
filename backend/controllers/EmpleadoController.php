<?php
require_once __DIR__ . '/../config/database.php';

class EmpleadoController {

    public function registro($data) {
        if (empty($data['nombre']) || empty($data['dui']) || 
            empty($data['contrasena']) || empty($data['telefono']) || 
            empty($data['fecha_contratacion']) || empty($data['sueldo_base'])) {
            return [
                'success' => false,
                'message' => 'Todos los campos son requeridos'
            ];
        }

        $url = SUPABASE_URL . '/rest/v1/empleados?dui=eq.' . $data['dui'] . '&select=id';
        
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, getSupabaseHeaders());
        $response = curl_exec($ch);
        curl_close($ch);

        $existe = json_decode($response, true);

        if (!empty($existe)) {
            return [
                'success' => false,
                'message' => 'Ya existe un empleado con ese DUI'
            ];
        }

        $empleado = [
            'nombre'             => $data['nombre'],
            'dui'                => $data['dui'],
            'telefono'           => $data['telefono'],
            'fecha_contratacion' => $data['fecha_contratacion'],
            'sueldo_base'        => $data['sueldo_base'],
            'contrasena'         => $data['contrasena'],
            'cargo'              => $data['cargo'] ?? 'Empleado',
            'estado'             => true
        ];

        $url = SUPABASE_URL . '/rest/v1/empleados';

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'PATCH');
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($empleado));
        curl_setopt($ch, CURLOPT_HTTPHEADER, getSupabaseHeaders());
        $response = curl_exec($ch);
        curl_close($ch);

        return [
            'success' => true,
            'message' => 'Perfil actualizado exitosamente'
        ];
    }
}
    