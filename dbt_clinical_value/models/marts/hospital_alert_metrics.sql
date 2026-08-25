SELECT
    p.hospital_id,
    h.hospital_name,

    COUNT(*) AS total_alerts,

    SUM(
        CASE
            WHEN a.is_valid THEN 1
            ELSE 0
        END
    ) AS valid_alerts,

    SUM(
        CASE
            WHEN NOT a.is_valid THEN 1
            ELSE 0
        END
    ) AS invalid_alerts,

    ROUND(
        100.0 * SUM(
            CASE
                WHEN a.is_valid THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS valid_alert_percentage,

    SUM(
        CASE
            WHEN NOT a.is_valid_patient_id THEN 1
            ELSE 0
        END
    ) AS invalid_patient_alerts,

    SUM(
        CASE
            WHEN NOT a.is_valid_priority THEN 1
            ELSE 0
        END
    ) AS invalid_priority_alerts,

    SUM(
        CASE
            WHEN NOT a.is_valid_product THEN 1
            ELSE 0
        END
    ) AS invalid_product_alerts

FROM {{ ref('stg_alerts') }} a

LEFT JOIN {{ source('bronze', 'bronze_patients') }} p
    ON a.patient_id = p.patient_id

LEFT JOIN {{ source('bronze', 'bronze_hospitals') }} h
    ON p.hospital_id = h.hospital_id

GROUP BY
    p.hospital_id,
    h.hospital_name