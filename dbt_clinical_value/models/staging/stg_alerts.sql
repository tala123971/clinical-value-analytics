WITH deduplicated AS (

    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY alert_id
            ORDER BY created_at
        ) AS row_num

    FROM {{ source('bronze', 'bronze_alerts') }}

),

cleaned AS (

    SELECT
        alert_id,
        patient_id,
        product,
        priority,
        created_at,

        patient_id IS NOT NULL AS is_valid_patient_id,

        priority IN ('LOW', 'MEDIUM', 'HIGH') AS is_valid_priority,

        product IN ('Stroke', 'PE', 'ICH') AS is_valid_product

    FROM deduplicated

    WHERE row_num = 1

)

SELECT
    *,
    is_valid_patient_id
        AND is_valid_priority
        AND is_valid_product AS is_valid

FROM cleaned