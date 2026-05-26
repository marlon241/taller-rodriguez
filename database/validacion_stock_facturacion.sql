-- ============================================================================
-- VALIDACIÓN DE STOCK EN FACTURACIÓN - SUPABASE
-- ============================================================================
-- Este documento contiene las constraints y triggers necesarios para validar
-- que no se pueda facturar más producto del disponible en inventario.
-- ============================================================================

-- ============================================================================
-- 1. FUNCIÓN: Validar stock antes de insertar en detalles_factura
-- ============================================================================

CREATE OR REPLACE FUNCTION validar_stock_detalle_factura()
RETURNS TRIGGER AS $$
DECLARE
    v_tipo_producto VARCHAR;
    v_stock_actual INTEGER;
    v_stock_minimo INTEGER;
BEGIN
    SELECT tipo, stock, stock_minimo
    INTO v_tipo_producto, v_stock_actual, v_stock_minimo
    FROM inventario
    WHERE id = NEW.id_producto;

    IF v_tipo_producto = 'Producto' THEN
        IF v_stock_actual < NEW.cantidad THEN
            RAISE EXCEPTION 'Stock insuficiente. Producto: %, Stock disponible: %, Cantidad solicitada: %',
                NEW.nombre_producto, v_stock_actual, NEW.cantidad;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 2. TRIGGER: Ejecutar validación antes de insertar en detalles_factura
-- ============================================================================

DROP TRIGGER IF EXISTS trg_validar_stock_detalle_factura ON detalles_factura;

CREATE TRIGGER trg_validar_stock_detalle_factura
    BEFORE INSERT ON detalles_factura
    FOR EACH ROW
    EXECUTE FUNCTION validar_stock_detalle_factura();

-- ============================================================================
-- 3. FUNCIÓN: Restar stock después de insertar en detalles_factura
-- ============================================================================

CREATE OR REPLACE FUNCTION restar_stock_detalle_factura()
RETURNS TRIGGER AS $$
DECLARE
    v_tipo_producto VARCHAR;
BEGIN
    SELECT tipo INTO v_tipo_producto
    FROM inventario
    WHERE id = NEW.id_producto;

    IF v_tipo_producto = 'Producto' THEN
        UPDATE inventario
        SET stock = stock - NEW.cantidad,
            ultima_actualizacion = NOW()
        WHERE id = NEW.id_producto;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 4. TRIGGER: Ejecutar resta de stock después de insertar en detalles_factura
-- ============================================================================

DROP TRIGGER IF EXISTS trg_restar_stock_detalle_factura ON detalles_factura;

CREATE TRIGGER trg_restar_stock_detalle_factura
    AFTER INSERT ON detalles_factura
    FOR EACH ROW
    EXECUTE FUNCTION restar_stock_detalle_factura();

-- ============================================================================
-- 5. FUNCIÓN: Restaurar stock al eliminar un detalle de factura
-- ============================================================================

CREATE OR REPLACE FUNCTION restaurar_stock_detalle_factura()
RETURNS TRIGGER AS $$
DECLARE
    v_tipo_producto VARCHAR;
BEGIN
    SELECT tipo INTO v_tipo_producto
    FROM inventario
    WHERE id = OLD.id_producto;

    IF v_tipo_producto = 'Producto' THEN
        UPDATE inventario
        SET stock = stock + OLD.cantidad,
            ultima_actualizacion = NOW()
        WHERE id = OLD.id_producto;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 6. TRIGGER: Restaurar stock al eliminar un detalle de factura
-- ============================================================================

DROP TRIGGER IF EXISTS trg_restaurar_stock_detalle_factura ON detalles_factura;

CREATE TRIGGER trg_restaurar_stock_detalle_factura
    AFTER DELETE ON detalles_factura
    FOR EACH ROW
    EXECUTE FUNCTION restaurar_stock_detalle_factura();

-- ============================================================================
-- NOTAS:
-- ============================================================================
-- - Los triggers de base de datos son la última línea de defensa
-- - La validación principal debe hacerse en el backend (controller)
-- - La validación secundaria debe hacerse en el frontend
-- - Si hay un conflicto, el mensaje de error será retornado al cliente
-- ============================================================================
