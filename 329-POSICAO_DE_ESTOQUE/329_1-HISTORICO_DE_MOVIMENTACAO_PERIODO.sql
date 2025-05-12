WITH MOVIMENTACOES AS (
    SELECT
        DISTINCT 
        TGFITE.CODPROD,
        TGFPRO.DESCRPROD,
        TGFITE.CONTROLE,
        TGFITE.CODLOCALORIG,
        TGFCAB.DTNEG,
        TGFCAB.DTFATUR,
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
        END                                               AS USOPRODUTO,
        TGFITE.NUNOTA,
        TGFTOP.ATUALESTMP * TGFITE.QTDNEG     AS QTD_MOV,
        TGFITE.VLRUNIT,
        TGFITE.VLRTOT * TGFTOP.ATUALESTMP     AS VLR_MOV,
        (TGFITE.VLRTOT * TGFTOP.ATUALESTMP)*TGFITE.QTDNEG AS VLR_TOT_MOV,
        TGFCAB.CODTIPOPER,
        TGFTOP.DESCROPER,
        TGFTOP.TIPMOV,
        TGFITE.SEQUENCIA,
        COALESCE(TGFCUSITE.ENTRADACOMICMS, 0) AS ENTRADACOMICMS,
        COALESCE(TGFCUSITE.ENTRADASEMICMS, 0) AS ENTRADASEMICMS,
        TGFCAB.STATUSNOTA,
        TGFITE.QTDNEG,
        TGFTOP.ATUALESTMP                     AS TIPO_MOVIMENTO
    FROM
        TGFITE
        INNER JOIN TGFCAB
        ON TGFITE.NUNOTA = TGFCAB.NUNOTA
        INNER JOIN TGFTOP
        ON TGFCAB.CODTIPOPER = TGFTOP.CODTIPOPER
        INNER JOIN TGFPRO
        ON TGFITE.CODPROD = TGFPRO.CODPROD
        LEFT JOIN (
            SELECT
                NUNOTA,
                SEQUENCIA,
                CONTROLE,
                ENTRADACOMICMS,
                ENTRADASEMICMS
            FROM
                TGFCUSITE
            WHERE
                (NUNOTA, SEQUENCIA, CONTROLE) IN (
                    SELECT
                        NUNOTA,
                        SEQUENCIA,
                        MAX(CONTROLE)
                    FROM
                        TGFCUSITE
                    GROUP BY
                        NUNOTA,
                        SEQUENCIA
                )
        ) TGFCUSITE
        ON TGFITE.NUNOTA = TGFCUSITE.NUNOTA
        AND TGFITE.SEQUENCIA = TGFCUSITE.SEQUENCIA
        AND TGFITE.CONTROLE = TGFCUSITE.CONTROLE
    WHERE
        TGFTOP.ATUALESTMP IN (1, -1)
        AND TGFTOP.TIPMOV = ANY ('V', 'C', 'F')
        AND TGFCAB.STATUSNOTA = 'L'
)
SELECT
    M.*,
    SUM(M.QTD_MOV) OVER ( PARTITION BY M.CODPROD ORDER BY M.DTNEG, M.SEQUENCIA ROWS BETWEEN UNBOUNDED PRECEDING
    AND CURRENT ROW ) AS SALDO_ACUMULADO,
    M.ENTRADACOMICMS * SUM(M.QTD_MOV) OVER ( PARTITION BY M.CODPROD ORDER BY M.DTNEG, M.SEQUENCIA ROWS BETWEEN UNBOUNDED PRECEDING
    AND CURRENT ROW ) AS ACUMULADOCOMICMS,
    M.ENTRADASEMICMS * SUM(M.QTD_MOV) OVER ( PARTITION BY M.CODPROD ORDER BY M.DTNEG, M.SEQUENCIA ROWS BETWEEN UNBOUNDED PRECEDING
    AND CURRENT ROW ) AS ACUMULADOSEMICMS
FROM
    MOVIMENTACOES M
WHERE
    M.DTNEG >= :DT_INICIO
    AND M.DTNEG <= :DT_SALDO
    AND M.CODPROD = :P_CODPROD
    OR :P_CODPROD IS NULL
ORDER BY
    M.CODPROD,
    M.DTNEG