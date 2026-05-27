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
-- 7. FUNCIÓN: Validar stock_minimo y stock_maximo en inventario
-- ============================================================================

CREATE OR REPLACE FUNCTION validar_stock_inventario()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.stock_minimo < 0 THEN
        RAISE EXCEPTION 'El stock minimo no puede ser negativo';
    END IF;
    
    IF NEW.stock_minimo > NEW.stock_maximo THEN
        RAISE EXCEPTION 'El stock minimo no puede ser mayor al stock maximo';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 8. TRIGGER: Ejecutar validación antes de insertar/actualizar en inventario
-- ============================================================================

DROP TRIGGER IF EXISTS trg_validar_stock_inventario ON inventario;

CREATE TRIGGER trg_validar_stock_inventario
    BEFORE INSERT OR UPDATE ON inventario
    FOR EACH ROW
    EXECUTE FUNCTION validar_stock_inventario();

-- ============================================================================
-- 9. FUNCIÓN: Validar ofertas (descuento e ID producto)
-- ============================================================================

CREATE OR REPLACE FUNCTION validar_oferta()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.porcentaje_descuento <= 0 OR NEW.porcentaje_descuento > 100 THEN
        RAISE EXCEPTION 'El descuento debe ser entre 1 y 100';
    END IF;
    
    IF NEW.id_producto_firebase IS NOT NULL AND NEW.id_producto_firebase <> '' THEN
        IF NEW.id_producto_firebase !~ '^[0-9]+$' THEN
            RAISE EXCEPTION 'El ID del producto debe contener solo numeros';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 10. TRIGGER: Ejecutar validación antes de insertar/actualizar en ofertas
-- ============================================================================

DROP TRIGGER IF EXISTS trg_validar_oferta ON ofertas;

CREATE TRIGGER trg_validar_oferta
    BEFORE INSERT OR UPDATE ON ofertas
    FOR EACH ROW
    EXECUTE FUNCTION validar_oferta();

-- ============================================================================
-- NOTAS:
-- ============================================================================
-- - Los triggers de base de datos son la última línea de defensa
-- - La validación principal debe hacerse en el backend (controller)
-- - La validación secundaria debe hacerse en el frontend
-- - Si hay un conflicto, el mensaje de error será retornado al cliente
-- ============================================================================
