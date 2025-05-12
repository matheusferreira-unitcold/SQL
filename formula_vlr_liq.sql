SELECT
    (
        CASE
            WHEN TGFITE.QTDNEG = 0 THEN
                0
            ELSE
                (
                    CASE
                        WHEN CAB.TIPMOV IN('O', 'C', 'E') THEN
                            TGFITE.VLRTOT - TGFITE.VLRDESC - TGFITE.VLRREPRED
                        ELSE
                            (
                                CASE
                                    WHEN NULLVALUE((
                                        SELECT
                                            INTEIRO
                                        FROM
                                            TSIPAR
                                        WHERE
                                            CHAVE = 'TIPTABPRECO'
                                    ), 0) <> 9 THEN
                                        TGFITE.VLRTOT - TGFITE.VLRDESC - TGFITE.VLRREPRED
                                    ELSE
                                        (TGFITE.VLRTOT - TGFITE.VLRDESC - TGFITE.VLRREPRED) + TGFITE.VLRSUBST + ((
                                            CASE
                                                WHEN TGFITE.VLRIPI > 0 AND NULLVALUE((
                                                    SELECT
                                                        SOMARIPI
                                                    FROM
                                                        TGFTOP TP
                                                    WHERE
                                                        TP.CODTIPOPER = CAB.CODTIPOPER
                                                        AND TP.DHALTER = CAB.DHTIPOPER
                                                ), 'N') <> 'N' THEN
                                                    TGFITE.VLRIPI
                                                ELSE
                                                    0
                                            END))
                                END)
                    END) / TGFITE.QTDNEG
        END)
FROM
    TGFCAB CAB
WHERE
    CAB.NUNOTA = TGFITE.NUNOTA