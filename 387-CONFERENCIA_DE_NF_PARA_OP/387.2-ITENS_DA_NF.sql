SELECT DISTINCT
    ITE.CODPROD,
    PRO.DESCRPROD,
    ITE.QTDNEG,
    PRO.CODVOL AS CODVOL_PADRAO,
    ITE.SEQUENCIA,
    ITE.CONTROLE,
    ITE.CODLOCALORIG,
    ITE.NUNOTA, 
    CAB.NUMNOTA,
    -- PEDIDO DE COMPRA (VAR1)
    (SELECT VAR1.NUNOTAORIG 
     FROM TGFVAR VAR1 
     WHERE VAR1.NUNOTA = ITE.NUNOTA 
     AND VAR1.SEQUENCIA = ITE.SEQUENCIA
     AND VAR1.NUNOTAORIG IS NOT NULL
     AND ROWNUM = 1) AS PEDIDO_COMPRA,
    (SELECT VAR1.QTDATENDIDA 
     FROM TGFVAR VAR1 
     WHERE VAR1.NUNOTA = ITE.NUNOTA 
     AND VAR1.SEQUENCIA = ITE.SEQUENCIA
     AND VAR1.NUNOTAORIG IS NOT NULL
     AND ROWNUM = 1) AS QTD_PEDIDO_COMPRA,
    (SELECT VAR1.SEQUENCIAORIG 
     FROM TGFVAR VAR1 
     WHERE VAR1.NUNOTA = ITE.NUNOTA 
     AND VAR1.SEQUENCIA = ITE.SEQUENCIA
     AND VAR1.NUNOTAORIG IS NOT NULL
     AND ROWNUM = 1) AS SEQ_PEDIDO_COMPRA,
    
    -- SOLICITAÇÃO DE COMPRA (VAR2)
    (SELECT VAR2.NUNOTAORIG 
     FROM TGFVAR VAR2 
     WHERE VAR2.NUNOTA = (SELECT VAR1.NUNOTAORIG 
                          FROM TGFVAR VAR1 
                          WHERE VAR1.NUNOTA = ITE.NUNOTA 
                          AND VAR1.SEQUENCIA = ITE.SEQUENCIA
                          AND VAR1.NUNOTAORIG IS NOT NULL
                          AND ROWNUM = 1)
     AND VAR2.SEQUENCIA = (SELECT VAR1.SEQUENCIAORIG 
                           FROM TGFVAR VAR1 
                           WHERE VAR1.NUNOTA = ITE.NUNOTA 
                           AND VAR1.SEQUENCIA = ITE.SEQUENCIA
                           AND VAR1.NUNOTAORIG IS NOT NULL
                           AND ROWNUM = 1)
     AND ROWNUM = 1) AS SOLICITACAO_COMPRA,
    (SELECT VAR2.QTDATENDIDA 
     FROM TGFVAR VAR2 
     WHERE VAR2.NUNOTA = (SELECT VAR1.NUNOTAORIG 
                          FROM TGFVAR VAR1 
                          WHERE VAR1.NUNOTA = ITE.NUNOTA 
                          AND VAR1.SEQUENCIA = ITE.SEQUENCIA
                          AND VAR1.NUNOTAORIG IS NOT NULL
                          AND ROWNUM = 1)
     AND VAR2.SEQUENCIA = (SELECT VAR1.SEQUENCIAORIG 
                           FROM TGFVAR VAR1 
                           WHERE VAR1.NUNOTA = ITE.NUNOTA 
                           AND VAR1.SEQUENCIA = ITE.SEQUENCIA
                           AND VAR1.NUNOTAORIG IS NOT NULL
                           AND ROWNUM = 1)
     AND ROWNUM = 1) AS QTD_SOLICITACAO_COMPRA,
    
    (SELECT VAR2.SEQUENCIAORIG 
     FROM TGFVAR VAR2 
     WHERE VAR2.NUNOTA = (SELECT VAR1.NUNOTAORIG 
                          FROM TGFVAR VAR1 
                          WHERE VAR1.NUNOTA = ITE.NUNOTA 
                          AND VAR1.SEQUENCIA = ITE.SEQUENCIA
                          AND VAR1.NUNOTAORIG IS NOT NULL
                          AND ROWNUM = 1)
     AND VAR2.SEQUENCIA = (SELECT VAR1.SEQUENCIAORIG 
                           FROM TGFVAR VAR1 
                           WHERE VAR1.NUNOTA = ITE.NUNOTA 
                           AND VAR1.SEQUENCIA = ITE.SEQUENCIA
                           AND VAR1.NUNOTAORIG IS NOT NULL
                           AND ROWNUM = 1)
     AND ROWNUM = 1) AS SEQ_SOLICITACAO_COMPRA,
    
    -- AD_IDIPROC da TGFITE da SOLICITAÇÃO DE COMPRA
    (SELECT ITE_SOLIC.AD_IDIPROC 
     FROM TGFITE ITE_SOLIC
     WHERE ITE_SOLIC.NUNOTA = (SELECT VAR2.NUNOTAORIG 
                               FROM TGFVAR VAR2 
                               WHERE VAR2.NUNOTA = (SELECT VAR1.NUNOTAORIG 
                                                    FROM TGFVAR VAR1 
                                                    WHERE VAR1.NUNOTA = ITE.NUNOTA 
                                                    AND VAR1.SEQUENCIA = ITE.SEQUENCIA
                                                    AND VAR1.NUNOTAORIG IS NOT NULL
                                                    AND ROWNUM = 1)
                               AND VAR2.SEQUENCIA = (SELECT VAR1.SEQUENCIAORIG 
                                                    FROM TGFVAR VAR1 
                                                    WHERE VAR1.NUNOTA = ITE.NUNOTA 
                                                    AND VAR1.SEQUENCIA = ITE.SEQUENCIA
                                                    AND VAR1.NUNOTAORIG IS NOT NULL
                                                    AND ROWNUM = 1)
                               AND ROWNUM = 1)
     AND ITE_SOLIC.SEQUENCIA = (SELECT VAR2.SEQUENCIAORIG 
                                FROM TGFVAR VAR2 
                                WHERE VAR2.NUNOTA = (SELECT VAR1.NUNOTAORIG 
                                                     FROM TGFVAR VAR1 
                                                     WHERE VAR1.NUNOTA = ITE.NUNOTA 
                                                     AND VAR1.SEQUENCIA = ITE.SEQUENCIA
                                                     AND VAR1.NUNOTAORIG IS NOT NULL
                                                     AND ROWNUM = 1)
                                AND VAR2.SEQUENCIA = (SELECT VAR1.SEQUENCIAORIG 
                                                     FROM TGFVAR VAR1 
                                                     WHERE VAR1.NUNOTA = ITE.NUNOTA 
                                                     AND VAR1.SEQUENCIA = ITE.SEQUENCIA
                                                     AND VAR1.NUNOTAORIG IS NOT NULL
                                                     AND ROWNUM = 1)
                                AND ROWNUM = 1)
     AND ROWNUM = 1) AS AD_IDIPROC_SOLICITACAO,
    (SELECT CAB_SOLIC.AD_NPROPOSTA
         FROM TGFCAB CAB_SOLIC
         WHERE CAB_SOLIC.NUNOTA = (SELECT VAR2.NUNOTAORIG 
                                   FROM TGFVAR VAR2 
                                   WHERE VAR2.NUNOTA = (SELECT VAR1.NUNOTAORIG 
                                                        FROM TGFVAR VAR1 
                                                        WHERE VAR1.NUNOTA = ITE.NUNOTA 
                                                        AND VAR1.SEQUENCIA = ITE.SEQUENCIA
                                                        AND VAR1.NUNOTAORIG IS NOT NULL
                                                        AND ROWNUM = 1)
                                   AND VAR2.SEQUENCIA = (SELECT VAR1.SEQUENCIAORIG 
                                                        FROM TGFVAR VAR1 
                                                        WHERE VAR1.NUNOTA = ITE.NUNOTA 
                                                        AND VAR1.SEQUENCIA = ITE.SEQUENCIA
                                                        AND VAR1.NUNOTAORIG IS NOT NULL
                                                        AND ROWNUM = 1)
                                   AND ROWNUM = 1)) AS AD_NPROPOSTA_SOLICITACAO,
    CAB.DTNEG, 
    CAB.DTFATUR, 
    CAB.CODPARC,
    CAB.CODTIPOPER, 
    CAB.TIPMOV,
    CAB.CODTIPVENDA,
    CAB.OBSERVACAO,
    CAB.VLRNOTA,
    CAB.LIBCONF,
    CAB.NUCONFATUAL
FROM TGFITE ITE
INNER JOIN TGFCAB CAB ON ITE.NUNOTA = CAB.NUNOTA
INNER JOIN TGFPRO PRO ON ITE.CODPROD = PRO.CODPROD
WHERE CAB.STATUSNOTA != 'L'
AND CAB.LIBCONF = 'S'
AND CAB.NUNOTA = :A_NUNOTA