SELECT
    DISTINCT TGFCAB.NUNOTA,
    TGFCAB.NUMNOTA,
    TGFCAB.AD_NPROPOSTA,
    TGFCAB.DTPREVENT,
    TGFCAB.DTNEG,
    CASE
        WHEN TGFCAB.PENDENTE = 'S' THEN
            TO_CHAR(TRUNC(SYSDATE - TGFCAB.DTNEG))
        WHEN TGFCAB.PENDENTE = 'N' THEN
            'Atendido'
    END                 AS DIAS_EM_ABERTO,
    TGFCAB.CODTIPOPER,
    TGFTOP.DESCROPER,
    TGFITE.CODPROD,
    TGFPRO.DESCRPROD,
    CASE
        WHEN TGFPRO.USOPROD = '1' THEN
            'Subproduto'
        WHEN TGFPRO.USOPROD = '2' THEN
            'Produto Intermediário'
        WHEN TGFPRO.USOPROD = '4' THEN
            'Demonstração'
        WHEN TGFPRO.USOPROD = 'B' THEN
            'Brinde'
        WHEN TGFPRO.USOPROD = 'C' THEN
            'Consumo'
        WHEN TGFPRO.USOPROD = 'D' THEN
            'Revenda (por fórmula)'
        WHEN TGFPRO.USOPROD = 'E' THEN
            'Embalagem'
        WHEN TGFPRO.USOPROD = 'F' THEN
            'Brinde (NF)'
        WHEN TGFPRO.USOPROD = 'I' THEN
            'Imobilizado'
        WHEN TGFPRO.USOPROD = 'M' THEN
            'Matéria prima'
        WHEN TGFPRO.USOPROD = 'O' THEN
            'Outros insumos'
        WHEN TGFPRO.USOPROD = 'P' THEN
            'Em Processo'
        WHEN TGFPRO.USOPROD = 'R' THEN
            'Revenda'
        WHEN TGFPRO.USOPROD = 'T' THEN
            'Terceiros'
        WHEN TGFPRO.USOPROD = 'V' THEN
            'Venda (fabricação própria)'
        ELSE
            'Serviço' -- Caso haja algum valor não mapeado
    END                 AS USOPRODUTO,
    TGFITE.QTDNEG,
    TGFPRO.CODVOL,
    TGFITE.SEQUENCIA,
    CASE
        WHEN TGFITE.PENDENTE = 'N' THEN
            'Não Pendente'
        WHEN TGFITE.PENDENTE = 'S' THEN
            'Pendente'
    END                 AS PENDENTE,
    CASE
        WHEN (TGFITE.QTDNEG - TGFITE.QTDENTREGUE) <=0 THEN
            0
        ELSE
            (TGFITE.QTDNEG - TGFITE.QTDENTREGUE)
    END                 AS QTDPENDENTE,
    (
        SELECT
            SUM(ESTOQUE)
        FROM
            TGFEST
        WHERE
            CODPROD = TGFITE.CODPROD
            AND CODEMP = TGFCAB.CODEMP
    ) AS ESTOQUE_TOTAL,
    (
        SELECT
            SUM(RESERVADO)
        FROM
            TGFEST
        WHERE
            CODPROD = TGFITE.CODPROD
            AND CODEMP = TGFCAB.CODEMP
    ) AS ESTOQUE_RESERV,
    (
        SELECT
            SUM(ESTOQUE - RESERVADO)
        FROM
            TGFEST
        WHERE
            CODPROD = TGFITE.CODPROD
            AND CODEMP = TGFCAB.CODEMP
    ) AS ESTOQUE_DISP,
    (
        SELECT
            TGFVAR.NUNOTA
        FROM
            TGFVAR
        WHERE
            TGFVAR.NUNOTAORIG = TGFCAB.NUNOTA
            AND TGFVAR.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
    ) AS NOTA_DESTINO,
    (
        SELECT
            TGFVAR.SEQUENCIA
        FROM
            TGFVAR
        WHERE
            TGFVAR.NUNOTAORIG = TGFCAB.NUNOTA
            AND TGFVAR.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
    ) AS SEQUENCIA_DESTINO,
    (
        SELECT
            DESTINOITEM.QTDNEG
        FROM
            TGFVAR DESTINOVAR
            LEFT JOIN TGFITE DESTINOITEM
            ON DESTINOVAR.NUNOTA = DESTINOITEM.NUNOTA
            AND DESTINOVAR.SEQUENCIA = DESTINOITEM.SEQUENCIA
        WHERE
            DESTINOVAR.NUNOTAORIG = TGFCAB.NUNOTA
            AND DESTINOVAR.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
    ) AS QTD_NEG_DESTINO,
    (
        SELECT
            DESTINOITEM.QTDENTREGUE
        FROM
            TGFVAR DESTINOVAR
            LEFT JOIN TGFITE DESTINOITEM
            ON DESTINOVAR.NUNOTA = DESTINOITEM.NUNOTA
            AND DESTINOVAR.SEQUENCIA = DESTINOITEM.SEQUENCIA
        WHERE
            DESTINOVAR.NUNOTAORIG = TGFCAB.NUNOTA
            AND DESTINOVAR.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
    ) AS QTD_ENTREGUE_DESTINO,
    (
        SELECT
            DESTINOCAB.CODPARC
        FROM
            TGFVAR DESTINOVAR
            LEFT JOIN TGFCAB DESTINOCAB
            ON DESTINOVAR.NUNOTA = DESTINOCAB.NUNOTA
        WHERE
            DESTINOVAR.NUNOTAORIG = TGFCAB.NUNOTA
            AND DESTINOVAR.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
    ) AS CODPARC_DESTINO,
    (
        SELECT
            TGFPAR.NOMEPARC
        FROM
            TGFVAR DESTINOVAR
            LEFT JOIN TGFCAB DESTINOCAB
            ON DESTINOVAR.NUNOTA = DESTINOCAB.NUNOTA
            INNER JOIN TGFPAR
            ON TGFPAR.CODPARC = DESTINOCAB.CODPARC
        WHERE
            DESTINOVAR.NUNOTAORIG = TGFCAB.NUNOTA
            AND DESTINOVAR.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
    ) AS NOMEPARC_DESTINO,
    (
        SELECT
            DESTINOCAB.DTPREVENT
        FROM
            TGFVAR DESTINOVAR
            LEFT JOIN TGFCAB DESTINOCAB
            ON DESTINOVAR.NUNOTA = DESTINOCAB.NUNOTA
        WHERE
            DESTINOVAR.NUNOTAORIG = TGFCAB.NUNOTA
            AND DESTINOVAR.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
    ) AS DTPREVENT_DESTINO,
    (
        SELECT
            TGFDTP.DTPREV
        FROM
            TGFVAR
            INNER JOIN TGFDTP
            ON TGFDTP.NUNOTA = TGFVAR.NUNOTA
            AND TGFDTP.SEQUENCIA = TGFVAR.SEQUENCIA
        WHERE
            TGFVAR.NUNOTAORIG = TGFCAB.NUNOTA
            AND TGFVAR.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
    ) AS DTPREVENT_DESTINO_ITEM,
    CASE
        WHEN (
            SELECT
                TGFCAB_DEST.PENDENTE
            FROM
                TGFCAB TGFCAB_DEST
            WHERE
                TGFCAB_DEST.NUNOTA = (
                    SELECT
                        TGFVAR.NUNOTA
                    FROM
                        TGFVAR
                    WHERE
                        TGFVAR.NUNOTAORIG = TGFCAB.NUNOTA
                        AND TGFVAR.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
                )
        ) = 'S'
        THEN
            TO_CHAR(TRUNC(SYSDATE -
            (
                SELECT
                    TGFCAB_DEST.DTNEG
                FROM
                    TGFCAB TGFCAB_DEST
                WHERE
                    TGFCAB_DEST.NUNOTA = (
                        SELECT
                            TGFVAR.NUNOTA
                        FROM
                            TGFVAR
                        WHERE
                            TGFVAR.NUNOTAORIG = TGFCAB.NUNOTA
                            AND TGFVAR.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
                    )
            )))
        WHEN (
            SELECT
                TGFCAB_DEST.PENDENTE
            FROM
                TGFCAB TGFCAB_DEST
            WHERE
                TGFCAB_DEST.NUNOTA = (
                    SELECT
                        TGFVAR.NUNOTA
                    FROM
                        TGFVAR
                    WHERE
                        TGFVAR.NUNOTAORIG = TGFCAB.NUNOTA
                        AND TGFVAR.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
                )
        ) = 'N'
        THEN
            'Entregue'
        ELSE
            NULL
    END AS DIAS_EM_ABERTO_NOTA_DESTINO,
    (
        SELECT
            TGFVAR_2.NUNOTA
        FROM
            TGFVAR TGFVAR_1
            LEFT JOIN TGFVAR TGFVAR_2
            ON TGFVAR_1.NUNOTA = TGFVAR_2.NUNOTAORIG
            AND TGFVAR_1.SEQUENCIA = TGFVAR_2.SEQUENCIAORIG
        WHERE
            TGFVAR_1.NUNOTAORIG = TGFCAB.NUNOTA
            AND TGFVAR_1.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
    ) AS PROXIMA_NOTA_DESTINO,
    (
        SELECT
            TGFCAB_1.NUMNOTA
        FROM
            TGFCAB TGFCAB_1
        WHERE
            TGFCAB_1.NUNOTA = (
                SELECT
                    TGFVAR_2.NUNOTA
                FROM
                    TGFVAR TGFVAR_1
                    LEFT JOIN TGFVAR TGFVAR_2
                    ON TGFVAR_1.NUNOTA = TGFVAR_2.NUNOTAORIG
                    AND TGFVAR_1.SEQUENCIA = TGFVAR_2.SEQUENCIAORIG
                WHERE
                    TGFVAR_1.NUNOTAORIG = TGFCAB.NUNOTA
                    AND TGFVAR_1.SEQUENCIAORIG = TGFITE.SEQUENCIA FETCH FIRST 1 ROWS ONLY
            )
            AND TGFCAB.CODEMP = TGFCAB.CODEMP -- Verifica que é da mesma empresa
            FETCH FIRST 1 ROWS ONLY
    ) AS NUMNOTA_DESTINO
FROM
    TGFCAB
    INNER JOIN TGFITE
    ON TGFITE.NUNOTA = TGFCAB.NUNOTA
    INNER JOIN TGFPRO
    ON TGFPRO.CODPROD = TGFITE.CODPROD
    INNER JOIN TGFTOP
    ON (TGFCAB.CODTIPOPER = TGFTOP.CODTIPOPER
    AND TGFCAB.DHTIPOPER = TGFTOP.DHALTER)
    LEFT JOIN TGFDTP
    ON (TGFITE.NUNOTA = TGFDTP.NUNOTA
    AND TGFDTP.SEQUENCIA = TGFITE.SEQUENCIA)
    INNER JOIN TGFPAR
    ON TGFCAB.CODPARC = TGFPAR.CODPARC
WHERE
    TGFCAB.CODTIPOPER = '1964'
    AND TGFTOP.TIPMOV = 'O'
    AND TGFITE.CODPROD = :PRODUTO
    OR :PRODUTO IS NULL
    AND TGFCAB.DTNEG >= :DTINIC
    OR :DTINIC IS NULL
    AND TGFCAB.DTNEG <= :DTFIM
    OR :DTFIM IS NULL
ORDER BY
    TGFCAB.DTNEG,
    TGFCAB.NUMNOTA,
    TGFCAB.NUNOTA