-- =====================================================================
-- Datos semilla (seed) — basados en los datos mock actuales del frontend.
-- Ejecutar DESPUÉS de 0001_init.sql. Solo incluye tablas independientes
-- de auth.users (services, providers, promotions). Las mascotas y
-- reservas de ejemplo requieren un usuario real (ver sección al final).
-- =====================================================================

insert into public.services
    (name, description, price, icon, category)
values
    ('Peluquería', 'Baño, corte y estilismo para tu mascota.', 35.00, '✂️', 'grooming'),
    ('Visita Veterinaria', 'Consulta médica profesional en tu hogar.', 60.00, '🩺', 'veterinary_visit'),
    ('Paseo de Perros', 'Paseos diarios con cuidadores certificados.', 20.00, '🐕', 'walking'),
    ('Alojamiento', 'Hospedaje cómodo y seguro para tu mascota.', 45.00, '🏠', 'boarding'),
    ('Visita a Domicilio', 'Cuidado personalizado en la comodidad de tu casa.', 30.00, '🏡', 'home_visit');

-- Proveedor de ejemplo sin perfil asociado todavía (profile_id se asigna
-- después, cuando un usuario real se registre con rol "provider" — ver
-- instrucciones al final de este archivo).
insert into public.providers
    (id, name, type, daily_capacity, active)
values
    ('00000000-0000-0000-0000-000000000001', 'PetCare Staff Central', 'employee', 8, true);

insert into public.provider_services
    (provider_id, category)
values
    ('00000000-0000-0000-0000-000000000001', 'grooming'),
    ('00000000-0000-0000-0000-000000000001', 'veterinary_visit'),
    ('00000000-0000-0000-0000-000000000001', 'walking'),
    ('00000000-0000-0000-0000-000000000001', 'boarding'),
    ('00000000-0000-0000-0000-000000000001', 'home_visit');

insert into public.promotions
    (name, scope, provider_id, discount_percentage, valid_from, valid_until)
values
    (
        'Bienvenida PetCare',
        'local',
        '00000000-0000-0000-0000-000000000001',
        15.00,
        now(),
        now() + interval
'90 days'
);

-- =====================================================================
-- Para probar el flujo completo con datos reales de dueño/proveedor:
-- 1. Registra un usuario owner desde la app (rol por defecto).
-- 2. Registra un segundo usuario y actualiza su rol a 'provider':
--      update public.profiles set role = 'provider' where email = 'proveedor@ejemplo.com';
-- 3. Vincula ese perfil a un proveedor existente (o crea uno nuevo):
--      update public.providers set profile_id = (
--        select id from public.profiles where email = 'proveedor@ejemplo.com'
--      ) where id = '00000000-0000-0000-0000-000000000001';
-- 4. Desde la app, el owner agrega una mascota y reserva un servicio;
--    el provider verá la reserva en tiempo real en su dashboard.
-- =====================================================================
