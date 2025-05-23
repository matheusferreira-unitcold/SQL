SELECT
    TGFPRO.CODPROD,
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
    END AS USOPRODUTO,
    TGFPRO.NCM,
    TGFCAB.DTNEG,
    TGFCAB.NUNOTA,
    TGFCAB.NUMNOTA,
    (
        CASE
            WHEN TGFCAB.STATUSNOTA = 'L' THEN
                'Sim'
            ELSE
                'Não'
        END)AS STATUSNOTA,
    TGFCAB.CODPARC,
    TGFPAR.NOMEPARC,
    TSIUFS.UF,
    TGFITE.QTDNEG,
    TGFDIN.CST,
    TGFITE.CODCFO,
    TGFITE.VLRUNIT,
    TGFITE.VLRTOT,
    TGFITE.VLRIPI,
    TGFITE.BASEIPI,
    TGFITE.ALIQIPI,
    TGFITE.VLRICMS,
    TGFITE.BASEICMS,
    TGFITE.ALIQICMS,
    COALESCE(MAX(
        CASE
            WHEN TGFDIN.CODIMP = 6 THEN
                TGFDIN.ALIQUOTA
        END),
    0)AS ALIQPIS,
    COALESCE(MAX(
        CASE
            WHEN TGFDIN.CODIMP = 7 THEN
                TGFDIN.ALIQUOTA
        END),
    0)AS ALIQCOFINS,
    TGFITE.VLRTOT AS BASEPISCOFINS,
    COALESCE(MAX(
        CASE
            WHEN TGFDIN.CODIMP = 6 THEN
                TGFDIN.ALIQUOTA
        END),
    0) * (TGFITE.VLRTOT / 100)AS VLRPIS,
    COALESCE(MAX(
        CASE
            WHEN TGFDIN.CODIMP = 7 THEN
                TGFDIN.ALIQUOTA
        END),
    0) * (TGFITE.VLRTOT / 100)AS VLRCOFINS,
    TGFCAB.CODTIPOPER,
    TGFTOP.DESCROPER
FROM
    TGFITE
    INNER JOIN TGFPRO
    ON TGFITE.CODPROD = TGFPRO.CODPROD
    INNER JOIN TGFCAB
    ON TGFITE.NUNOTA = TGFCAB.NUNOTA
    INNER JOIN TGFPAR
    ON TGFCAB.CODPARC = TGFPAR.CODPARC
    INNER JOIN TGFTOP
    ON TGFCAB.CODTIPOPER = TGFTOP.CODTIPOPER
    LEFT JOIN TGFDIN
    ON TGFITE.NUNOTA = TGFDIN.NUNOTA
    LEFT JOIN TGFPAEM
    ON TGFPAR.CODPARC = TGFPAEM.CODPARC
    INNER JOIN TSICID
    ON TGFPAR.CODCID = TSICID.CODCID
    INNER JOIN TSIUFS
    ON TSICID.UF = TSIUFS.CODUF
WHERE
    TGFCAB.TIPMOV = 'C'
    AND TGFCAB.CODTIPOPER = ANY :TOP
    AND TGFDIN.CST = ANY :CST
    AND TGFCAB.DTNEG >= :DT_INICIO
    OR :DT_INICIO IS NULL
    AND TGFCAB.DTNEG <= :DT_FIM
GROUP BY
    TGFPRO.CODPROD,
    TGFPRO.DESCRPROD,
    TGFPRO.USOPROD,
    TGFPRO.NCM,
    TGFCAB.DTNEG,
    TGFCAB.NUNOTA,
    TGFCAB.NUMNOTA,
    TGFCAB.STATUSNOTA,
    TGFCAB.CODPARC,
    TGFPAR.NOMEPARC,
    TSIUFS.UF,
    TGFITE.QTDNEG,
    TGFDIN.CST,
    TGFITE.CODCFO,
    TGFITE.VLRUNIT,
    TGFITE.VLRTOT,
    TGFITE.VLRIPI,
    TGFITE.BASEIPI,
    TGFITE.ALIQIPI,
    TGFITE.VLRICMS,
    TGFITE.BASEICMS,
    TGFITE.ALIQICMS,
    TGFCAB.CODTIPOPER,
    TGFTOP.DESCROPER