# Plan de Implementación: Reto "Bolsa Infinita"

Añadiremos el reto "Bolsa Infinita (Reutilizables)" que premia el uso de bolsas de tela. Este reto será de tipo "una vez al día" para fomentar el hábito diario.

## Cambios en Base de Datos (Supabase)

Es **necesario** actualizar la función `registrar_accion` para que reconozca el nuevo subtipo, asigne los puntos/CO2 correctos y aplique la validación de "una vez al día".

### Script SQL Sugerido
Se debe ejecutar en el SQL Editor de Supabase para reemplazar la función actual.

```sql
CREATE OR REPLACE FUNCTION public.registrar_accion(
    p_tipo text,
    p_subtipo text,
    p_usuario_id uuid
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_litros NUMERIC := 0;
  v_co2 NUMERIC := 0;
  v_puntos INTEGER := 0;
  v_unidades_rec int := 0;
  v_kwh_en numeric := 0;
  v_resultado JSON;
BEGIN
  -- Validaciones de seguridad
  IF p_tipo NOT IN ('ducha', 'reciclaje', 'energia') THEN
    RAISE EXCEPTION 'Tipo no válido';
  END IF;

  -- Lógica de Repetición (Agregamos bolsa_reutilizable)
  IF p_subtipo IN ('ducha_express', 'cero_desechables', 'vampiros_electricos', 'luz_natural', 'modo_eco', 'bolsa_reutilizable') THEN
      IF EXISTS (
        SELECT 1 FROM public.acciones_usuarios
        WHERE usuario_id = p_usuario_id
          AND subtipo_accion = p_subtipo
          AND registrado_en::date = CURRENT_DATE
      ) THEN
        RAISE EXCEPTION '¡Esta misión ya la completaste hoy, héroe!';
      END IF;
  END IF;

  -- ASIGNACIÓN DE IMPACTOS Y PUNTOS XP
  CASE p_tipo
    WHEN 'ducha' THEN
      CASE p_subtipo
        WHEN 'ducha_express' THEN v_litros := 40; v_co2 := 800; v_puntos := 80;
        WHEN 'cierre_grifo'  THEN v_litros := 5;  v_co2 := 10;  v_puntos := 10;
        WHEN 'guardian_agua' THEN v_litros := 20; v_co2 := 100; v_puntos := 30;
      END CASE;
    WHEN 'reciclaje' THEN
      CASE p_subtipo
        WHEN 'pet_aluminio'      THEN v_unidades_rec := 1; v_co2 := 84;  v_puntos := 15;
        WHEN 'cero_desechables'  THEN v_unidades_rec := 1; v_co2 := 120; v_puntos := 50;
        WHEN 'bolsa_reutilizable' THEN v_unidades_rec := 1; v_co2 := 45;  v_puntos := 25;
      END CASE;
    WHEN 'energia' THEN
      v_kwh_en := 0.2; v_co2 := 300; v_puntos := 40;
  END CASE;

  -- 1. Guardar en el historial
  INSERT INTO public.acciones_usuarios (tipo_accion, subtipo_accion, usuario_id)
  VALUES (p_tipo, p_subtipo, p_usuario_id);

  -- 2. Sumar puntos al héroe
  UPDATE public.app_users
  SET puntos = puntos + v_puntos
  WHERE id = p_usuario_id;

  -- 3. Actualizar Impacto Global Colectivo
  UPDATE public.impacto_global SET
    litros_agua         = litros_agua + v_litros,
    gramos_co2          = gramos_co2 + v_co2,
    unidades_recicladas = unidades_recicladas + v_unidades_rec,
    kwh_energia         = kwh_energia + v_kwh_en,
    updated_at          = NOW()
  WHERE id = 1;

  -- 4. Retornar feedback inmediato
  SELECT json_build_object(
    'puntos_ganados', v_puntos,
    'total_puntos',   (SELECT puntos FROM public.app_users WHERE id = p_usuario_id)
  ) INTO v_resultado;

  RETURN v_resultado;
END;
$$;
```

## Cambios en el Proyecto (Flutter)

### [recycling_provider.dart](file:///C:/Users/Alexander/StudioProjects/biogota/lib/providers/recycling_provider.dart)
- Agregar `'bolsa_reutilizable': 45` al mapa `_co2PorSubtipo`.

### [recycling_page.dart](file:///C:/Users/Alexander/StudioProjects/biogota/lib/pages/recycling/recycling_page.dart)
- Añadir una nueva tarjeta `_QuickActionChallengeCard` para el reto de la bolsa reutilizable.

## Verificación
- Se verificará que el ID del reto coincida con el de la base de datos (`bolsa_reutilizable`).
- Se comprobará que la UI refleje el estado de completado cuando el provider lo indique.
