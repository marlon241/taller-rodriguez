<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, PUT, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Accept, Authorization');
header('Access-Control-Max-Age: 3600');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'controllers/AuthController.php';
require_once 'controllers/EmpleadoController.php';


$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = explode('/', $uri);

$method = $_SERVER['REQUEST_METHOD'];

$data = json_decode(file_get_contents('php://input'), true);

$auth = new AuthController();
$empleado = new EmpleadoController();

switch(true) {
    case $method === 'POST' && in_array('login', $uri):
        echo json_encode($auth->login($data));
        break;

    case $method === 'POST' && in_array('registro', $uri):
        echo json_encode($empleado->registro($data));
        break;

    case $method === 'PUT' && in_array('perfil', $uri):
        echo json_encode($empleado->editarPerfil($data));
        break;

    default:
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Ruta no encontrada']);
        break;
}
?>